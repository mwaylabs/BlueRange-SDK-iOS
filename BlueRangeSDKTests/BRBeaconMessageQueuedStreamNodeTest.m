//
//  BRBeaconMessageQueuedStreamNodeTest.m
//  BlueRangeSDK
//
// Copyright (c) 2016-2017, M-Way Solutions GmbH
// All rights reserved.
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
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
