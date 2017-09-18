//
//  BRBeaconMessageLoggerTest.m
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
#import "BRBeaconMessageLogger.h"
#import "BRBeaconMessageScannerSimulator.h"
#import "BRDummyFileAccessor.h"
#import "BRBeaconMessagePersistorImpl.h"
#import "BRDummyTracer.h"
#import "BRBeaconMessageStreamNodeReceiver.h"
#import "BRIBeaconMessage.h"
#import "BRBeaconMessageLog.h"
#import "BRLogIterator.h"

@interface BRBeaconMessageLoggerTest : XCTestCase

@property BRBeaconMessageLogger* logger;
@property BRBeaconMessageScannerSimulator* scanner;
@property BRDummyFileAccessor* fileAccessor;
@property BRBeaconMessagePersistorImpl* persistor;
@property BRDummyTracer* tracer;
@property id listenerMock;

@end

@implementation BRBeaconMessageLoggerTest

- (void)setUp {
    [super setUp];
    self.scanner = [[BRBeaconMessageScannerSimulator alloc] init];
    self.fileAccessor = [[BRDummyFileAccessor alloc] init];
    self.persistor = [[BRBeaconMessagePersistorImpl alloc] initWithFileAccessor:self.fileAccessor andChunkSize:1];
    self.tracer = [[BRDummyTracer alloc] init];
    self.logger = [[BRBeaconMessageLogger alloc] initWithSender:self.scanner andPersistor:self.persistor andTracer:self.tracer];
    self.listenerMock = OCMProtocolMock(@protocol(BRBeaconMessageStreamNodeReceiver));
    [self.logger addReceiver:self.listenerMock];
}

- (void) testReadLogWithMessagesThatFillExactlyOneChunk {
    int numMessages = 2;
    NSMutableArray* writtenMessages = [self simulateArbitraryMessages:numMessages];
    [self.scanner startScanning];
    [self.scanner stopScanning];
    NSMutableArray* readMessages = [self getLoggedBeaconMessages];
    XCTAssertEqualObjects(writtenMessages, readMessages);
}

- (void) testOneMessageSaveNotification {
    __block int callCount = 0;
    OCMExpect([self.listenerMock onReceivedMessage:[OCMArg checkWithBlock:^BOOL(id sender){
        return [sender isKindOfClass:[BRBeaconMessageLogger class]];
    }] withMessage:[OCMArg checkWithBlock:^BOOL(BRBeaconMessage* message){
        return [message isKindOfClass:[BRIBeaconMessage class]];
    }]])._andDo(^(NSInvocation *invocation) {
        ++callCount;
    });
    
    int numMessages = 1;
    [self simulateArbitraryMessages:numMessages];
    [self.scanner startScanning];
    
    XCTAssertEqual(callCount, numMessages);
}

- (void) testLogIterator {
    int numMessages = 1;
    NSMutableArray* writtenMessages = [self simulateArbitraryMessages:numMessages];
    [self.scanner startScanning];
    [self.scanner stopScanning];
    NSMutableArray* readMessages = [[NSMutableArray alloc] init];
    id<BRLogIterator> iterator = [self.logger getLogIterator];
    while ([iterator hasNext]) {
        BRBeaconMessage* message = [iterator next];
        [readMessages addObject:message];
    }
    XCTAssertEqualObjects(writtenMessages, readMessages);
}

- (NSMutableArray*) simulateArbitraryMessages: (int) numberOfMessages {
    NSMutableArray* beaconMessages = [[NSMutableArray alloc] init];
    for (int i = 0; i < numberOfMessages; i++) {
        BRIBeaconMessage* beaconMessage = [self simulateArbitraryIBeacon];
        [beaconMessages addObject:beaconMessage];
    }
    return beaconMessages;
}

- (BRIBeaconMessage*) simulateArbitraryIBeacon {
    NSString* uuid = @"b9407f30-f5f8-466e-aff9-25556b57fe6d";
    int major = 45;
    int minor = 1;
    int rssi = -50;
    BRIBeaconMessage* message = [[BRIBeaconMessage alloc] initWithUUID:[[NSUUID alloc] initWithUUIDString:uuid] major:major minor:minor rssi:rssi];
    [self.scanner simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:uuid] andMajor:major andMinor:minor andRssi:rssi];
    return message;
}

- (NSMutableArray*) getLoggedBeaconMessages {
    BRBeaconMessageLog* log = [self.logger readLog];
    NSMutableArray* readMessages = [log beaconMessages];
    return readMessages;
}

- (void)tearDown {
    [super tearDown];
}

@end
