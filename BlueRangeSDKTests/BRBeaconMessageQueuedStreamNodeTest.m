//
//  BRBeaconMessageQueuedStreamNodeTest.m
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
#import "BRBeaconMessageScannerSimulator.h"
#import "BRBeaconMessageQueuedStreamNode.h"
#import "BRIBeaconMessage.h"
#import "BRIBeacon.h"
#import "BRTestBlocker.h"
#import "BRTestFailure.h"

@interface BRBeaconMessageQueuedStreamNodeTest : XCTestCase

@property BRBeaconMessageScannerSimulator* scanner;
@property BRBeaconMessageQueuedStreamNode* queue;

@end

@implementation BRBeaconMessageQueuedStreamNodeTest

- (void)setUp {
    [super setUp];
    // Create scanner -> queue graph
    self.scanner = [[BRBeaconMessageScannerSimulator alloc] init];
    self.queue = [[BRBeaconMessageQueuedStreamNode alloc] initWithSender:self.scanner];
}

- (void)tearDown {
    [super tearDown];
}

- (void) testShouldReceiveOneMessageWhenReceivedByQueue {
    // Define iBeacon
    NSUUID* uuid = [[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"];
    BRIBeacon* iBeacon = [[BRIBeacon alloc] initWithUuid:uuid andMajor:1 andMinor:1];
    // Prepare scanner
    [self.scanner simulateIBeacon:iBeacon];
    // Simulate scanner
    [self.scanner startScanning];
    // Pull messages
    BRIBeaconMessage* actualMessage = (BRIBeaconMessage*)[self.queue pullBeaconMessage];
    // Verify
    XCTAssertEqualObjects(iBeacon, [actualMessage iBeacon]);
}

- (void) testShouldReceiveTwoMessagesWhenTwoMessagesReceiveQueue {
    // Define iBeacon
    NSUUID* uuid1 = [[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"];
    BRIBeacon* iBeacon1 = [[BRIBeacon alloc] initWithUuid:uuid1 andMajor:1 andMinor:1];
    NSUUID* uuid2 = [[NSUUID alloc] initWithUUIDString:@"c9407f30-f5f8-466e-aff9-25556b57fe6d"];
    BRIBeacon* iBeacon2 = [[BRIBeacon alloc] initWithUuid:uuid2 andMajor:1 andMinor:1];
    // Prepare scanner
    [self.scanner simulateIBeacon:iBeacon1];
    [self.scanner simulateIBeacon:iBeacon2];
    // Simulate scanner
    [self.scanner startScanning];
    // Pull messages
    BRIBeaconMessage* actualMessage1 = (BRIBeaconMessage*)[self.queue pullBeaconMessage];
    BRIBeaconMessage* actualMessage2 = (BRIBeaconMessage*)[self.queue pullBeaconMessage];
    // Verify
    XCTAssertEqualObjects(iBeacon1, [actualMessage1 iBeacon]);
    XCTAssertEqualObjects(iBeacon2, [actualMessage2 iBeacon]);
}

- (void) testShouldNotReceiveTwoMessagesIfMaximumMessagesIsOne {
    BRTestFailure* failure = [[BRTestFailure alloc] init];
    
    NSThread* thread = [[NSThread alloc] initWithBlock:^{
        [self.queue setMaximumSize:1];
        // Define iBeacon
        NSUUID* uuid1 = [[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"];
        BRIBeacon* iBeacon1 = [[BRIBeacon alloc] initWithUuid:uuid1 andMajor:1 andMinor:1];
        NSUUID* uuid2 = [[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"];
        BRIBeacon* iBeacon2 = [[BRIBeacon alloc] initWithUuid:uuid2 andMajor:1 andMinor:1];
        // Prepare scanner
        [self.scanner simulateIBeacon:iBeacon1];
        [self.scanner simulateIBeacon:iBeacon2];
        // Simulate scanner
        [self.scanner startScanning];
        // Pull messages
        [self.queue pullBeaconMessage];
        [self.queue pullBeaconMessage];
        // We assume not to reach this code line
        [failure setFailed:true];
    }];
    [thread start];
    
    // Wait a second
    BRTestBlocker* testBlocker = [[BRTestBlocker alloc] init];
    [testBlocker blockTest:1000];
    
    XCTAssertFalse([failure failed]);
}

@end
