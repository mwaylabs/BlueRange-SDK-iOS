//
//  BRIBeaconMessageFilterTest.m
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
#import "BRBeaconMessageScannerSimulator.h"
#import "BRIBeaconMessageFilter.h"
#import "BRBeaconMessageStreamNode.h"
#import "BRIBeaconMessage.h"

@interface BRIBeaconMessageFilterTest : XCTestCase

@property BRBeaconMessageScannerSimulator* scanner;
@property BRIBeaconMessageFilter* filter;
@property id receiverNode;

@end

@implementation BRIBeaconMessageFilterTest

- (void)setUp {
    [super setUp];
    self.scanner = [[BRBeaconMessageScannerSimulator alloc] init];
    self.filter = [[BRIBeaconMessageFilter alloc] initWithSender:self.scanner];
    self.receiverNode = OCMClassMock([BRBeaconMessageStreamNode class]);
    [self.filter addReceiver:self.receiverNode];
}

- (void)tearDown {
    [super tearDown];
}

- (void) testIBeaconPassingThroughFilter {
    OCMExpect([self.receiverNode onReceivedMessage:OCMOCK_ANY withMessage:[OCMArg checkWithBlock:^BOOL(BRBeaconMessage* message){
        return [message isKindOfClass:[BRIBeaconMessage class]];
    }]]);
    
    // Configurate and start sender
    [self.scanner simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:45 andMinor:1 andRssi:-50];
    [self.scanner startScanning];
    // Verify that message was passed.
    OCMVerifyAll(self.receiverNode);
}

- (void) testNonIBeaconDoesNotPassFilter {
    [[self.receiverNode reject] onReceivedMessage:OCMOCK_ANY withMessage:[OCMArg checkWithBlock:^BOOL(BRBeaconMessage* message){
        return [message isKindOfClass:[BRIBeaconMessage class]];
    }]];
    
    // Configurate and start sender
    [self.scanner simulateJoinMeWithNodeId:123];
    [self.scanner startScanning];
    // Verify that message was passed.
    OCMVerifyAll(self.receiverNode);
}

@end
