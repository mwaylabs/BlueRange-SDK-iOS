//
//  BRBeaconMessageScannerConfigTest.m
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
