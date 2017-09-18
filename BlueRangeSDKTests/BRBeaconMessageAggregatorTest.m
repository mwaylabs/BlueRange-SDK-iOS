//
//  BRBeaconMessageAggregatorTest.m
//  BlueRangeSDK
//
// Copyright (c) 2016-2017, M-Way Solutions GmbH
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the M-Way Solutions GmbH nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY M-Way Solutions GmbH ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL M-Way Solutions GmbH BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "BRITracer.h"
#import "BRBeaconMessageScannerSimulator.h"
#import "BRBeaconMessageAggregator.h"
#import "BRTestBlocker.h"
#import "BRBeaconMessageStreamNodeReceiver.h"
#import "BRDummyTracer.h"
#import "BRSimpleMovingAverageFilter.h"
#import "BRBeaconMessage.h"

@interface BRBeaconMessageAggregatorTest : XCTestCase

@property id<BRITracer> tracer;
@property BRBeaconMessageScannerSimulator* simulator;
@property BRBeaconMessageAggregator* aggregator;
@property BRTestBlocker* testBlocker;
@property id receiver;

@end

@implementation BRBeaconMessageAggregatorTest

- (void)setUp {
    [super setUp];
    self.tracer = [[BRDummyTracer alloc] init];
    self.simulator = [[BRBeaconMessageScannerSimulator alloc] init];
    
    self.aggregator = [[BRBeaconMessageAggregator alloc] initWithTracer:self.tracer andSender:self.simulator];
    [self.aggregator setAggregateDurationInMs:300];
    self.receiver = OCMProtocolMock(@protocol(BRBeaconMessageStreamNodeReceiver));
    [self.aggregator addReceiver:self.receiver];
    [self.aggregator setAverageFilter:[[BRSimpleMovingAverageFilter alloc] init]];
    
    self.testBlocker = [[BRTestBlocker alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void) testOneIncomingMessageShouldResultInOneAggregate {
    OCMExpect([self.receiver onReceivedMessage:OCMOCK_ANY withMessage:[OCMArg checkWithBlock:^BOOL(BRBeaconMessage* message){
        XCTAssertEqual(message.rssi, -50);
        return [message isKindOfClass:[BRBeaconMessage class]];
    }]]);
    
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-50];
    
    [self.simulator startScanning];
    [self.testBlocker blockTest:1000];
    
    OCMVerifyAll(self.receiver);
}

- (void) testTwoEqualMessagesShouldResultInOneAggregate {
    __block int callCount = 0;
    OCMExpect([self.receiver onReceivedMessage:OCMOCK_ANY withMessage:OCMOCK_ANY])._andDo(^(NSInvocation *invocation) {
        ++callCount;
    });
    
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-50];
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-60];
    
    [self.simulator startScanning];
    [self.testBlocker blockTest:1000];
    
    XCTAssertEqual(callCount, 1);
}

- (void) testTwoEqualMessagesShouldResultInTwoAggregatesIfAggregateDurationExpired {
    
    [[self.receiver expect] onReceivedMessage:OCMOCK_ANY withMessage:OCMOCK_ANY];
    [[self.receiver expect] onReceivedMessage:OCMOCK_ANY withMessage:OCMOCK_ANY];
    
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-50];
    [self.simulator startScanning];
    [self.simulator resetSimulatedBeacons];
    [self.testBlocker blockTest:1000];
    
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-60];
    [self.simulator startScanning];
    [self.simulator resetSimulatedBeacons];
    [self.testBlocker blockTest:1000];
    
    [self.receiver verify];
}

- (void) testTwoDifferentMessagesShouldResultInTwoAggregatesEventIfDurationNotExpired {
    [[self.receiver expect] onReceivedMessage:OCMOCK_ANY withMessage:OCMOCK_ANY];
    [[self.receiver expect] onReceivedMessage:OCMOCK_ANY withMessage:OCMOCK_ANY];
    
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-50];
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"c9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-60];
    
    [self.simulator startScanning];
    [self.testBlocker blockTest:1000];
    
    [self.receiver verify];
}

- (void) testRssiAverageInAggregate {
    OCMExpect([self.receiver onReceivedMessage:OCMOCK_ANY withMessage:[OCMArg checkWithBlock:^BOOL(BRBeaconMessage* message){
        XCTAssertEqual(message.rssi, -55);
        return [message isKindOfClass:[BRBeaconMessage class]];
    }]]);
    
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-50];
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-60];
    
    [self.simulator startScanning];
    [self.testBlocker blockTest:1000];
    
    OCMVerifyAll(self.receiver);
}

- (void) testSlidingWindowMode {
    [self.receiver setExpectationOrderMatters:YES];
    OCMExpect([self.receiver onReceivedMessage:OCMOCK_ANY withMessage:[OCMArg checkWithBlock:^BOOL(BRBeaconMessage* message){
        XCTAssertEqual(message.rssi, -50);
        return [message isKindOfClass:[BRBeaconMessage class]];
    }]]);
    OCMExpect([self.receiver onReceivedMessage:OCMOCK_ANY withMessage:[OCMArg checkWithBlock:^BOOL(BRBeaconMessage* message){
        XCTAssertEqual(message.rssi, -55);
        return [message isKindOfClass:[BRBeaconMessage class]];
    }]]);
    
    [self.aggregator setAggregationMode:AGGREGATION_MODE_SLIDING_WINDOW];
    
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-50];
    [self.simulator simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-60];
    
    [self.simulator startScanning];
    [self.testBlocker blockTest:1000];
    
    OCMVerifyAll(self.receiver);
}

@end
