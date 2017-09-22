//
//  BRBeaconMessageScannerConfigTest.m
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
#import <OCMock/OCMock.h>
#import "BlueRangeSDK.h"

@interface BRBeaconMessageScannerConfigTest : XCTestCase

@end

@implementation BRBeaconMessageScannerConfigTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void) testShouldNotRestartScannerOnConfigChangeIfScannerHasNotBeenStarted {
    
    // 1. Configuration before scanning
    BRBeaconMessageScannerSimulator* scanner = [[BRBeaconMessageScannerSimulator alloc] init];
    id mockReceiver = OCMProtocolMock(@protocol(BRBeaconMessageStreamNodeReceiver));
    [scanner addReceiver:mockReceiver];
    
    __block int callCount = 0;
    OCMExpect([mockReceiver onReceivedMessage:OCMOCK_ANY withMessage:OCMOCK_ANY])._andDo(^(NSInvocation *invocation) {
        ++callCount;
    });
    
    BRBeaconMessageScannerConfig* config = [scanner config];
    [config scanIBeacon:@"b2407f30-f5f8-466e-aff9-25556b57fe6d"];
    [scanner simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:1 andMinor:1 andRssi:-50];
    
    XCTAssertEqual(callCount, 0);
}

- (void) testShouldRestartScannerOnConfigChangeIfScannerIsRunning {
    // 1. Configuration before scanning
    BRBeaconMessageScannerSimulator* scanner = [[BRBeaconMessageScannerSimulator alloc] init];
    id mockReceiver = OCMProtocolMock(@protocol(BRBeaconMessageStreamNodeReceiver));
    [scanner addReceiver:mockReceiver];
    
    NSUUID* uuid1 = [[NSUUID alloc] initWithUUIDString:@"b2407f30-f5f8-466e-aff9-25556b57fe6d"];
    NSUUID* uuid2 = [[NSUUID alloc] initWithUUIDString:@"c2407f30-f5f8-466e-aff9-25556b57fe6d"];
    [[mockReceiver expect] onReceivedMessage:OCMOCK_ANY withMessage:[OCMArg checkWithBlock:^BOOL(BRIBeaconMessage* message){
        XCTAssertEqualObjects(message.uuid, uuid1);
        return [message isKindOfClass:[BRIBeaconMessage class]];
    }]];
    [[mockReceiver expect] onReceivedMessage:OCMOCK_ANY withMessage:[OCMArg checkWithBlock:^BOOL(BRIBeaconMessage* message){
        XCTAssertEqualObjects(message.uuid, uuid2);
        return [message isKindOfClass:[BRIBeaconMessage class]];
    }]];
    
    BRBeaconMessageScannerConfig* config = [scanner config];
    
    [config scanIBeacon:[uuid1 UUIDString]];
    [scanner simulateIBeaconWithUuid:uuid1 andMajor:1 andMinor:1];
    [scanner startScanning];
    
    [scanner resetSimulatedBeacons];
    [config scanIBeacon:[uuid2 UUIDString]];
    [scanner simulateIBeaconWithUuid:uuid2 andMajor:1 andMinor:1];
    [scanner startScanning];
    
    OCMVerifyAll(mockReceiver);
}

@end
