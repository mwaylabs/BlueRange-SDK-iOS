//
//  BRBeaconMessageLoggerTest.m
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
