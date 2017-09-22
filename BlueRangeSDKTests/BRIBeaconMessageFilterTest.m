//
//  BRIBeaconMessageFilterTest.m
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
