//
//  BRBeaconMessageScannerSimulator.h
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

#import <Foundation/Foundation.h>
#import "BRIBeaconMessageScanner.h"

@class BRBeaconMessageScannerConfig;
@class BRIBeacon;

/**
 * This class implements the
 * {@link BRIBeaconMessageScanner} interface and can be used to simulate incoming {@link BRBeaconMessage}s.
 */
@interface BRBeaconMessageScannerSimulator : BRIBeaconMessageScanner {
    BOOL _rssiNoise;
}

@property (readonly) NSMutableArray* beaconMessages;
@property BOOL repeat;
@property long repeatInterval;
@property BRBeaconMessageScannerConfig* config;
@property (readonly) BOOL running;

- (id) init;

- (void) addRssiNoise;

- (void) simulateIBeaconWithUuid: (NSUUID*) uuid andMajor: (int) major andMinor: (int) minor;
- (void) simulateIBeaconWithUuid: (NSUUID*) uuid andMajor: (int) major andMinor: (int) minor andRssi: (int) rssi;
- (void) simulateIBeacon: (BRIBeacon*) iBeacon;
- (void) simulateEddystoneUidWithNamespace: (NSString*) namespaceUid andInstanceId: (NSString*) instanceId;
- (void) simulateEddystoneUidWithNamespace: (NSString*) namespaceUid andInstanceId: (NSString*) instanceId andRssi: (int) rssi;
- (void) simulateEddystoneUrl: (NSString*) url;
- (void) simulateEddystoneUrl: (NSString*) url andRssi: (int) rssi;
- (void) simulateRelutionTagsV1: (NSArray*) tags;
- (void) simulateRelutionTagsV1WithRssi: (NSArray*) tags andRssi: (int) rssi;
- (void) simulateRelutionTagsWithNamespaceUid: (NSString*) namespaceUid andTags: (NSArray*) tags;
- (void) simulateRelutionTagsWithNamespaceUid: (NSString*) namespaceUid andTags: (NSArray*) tags andRssi: (int) rssi;
- (void) simulateJoinMeWithNodeId: (int) nodeId;
- (void) simulateJoinMeWithNodeId: (int) nodeId andRssi: (int) rssi;

- (void) resetSimulatedBeacons;

- (void) startScanning;
- (void) stopScanning;
- (void) onReceivedMessage: (BRBeaconMessageStreamNode *) senderNode withMessage: (BRBeaconMessage*) message;



@end
