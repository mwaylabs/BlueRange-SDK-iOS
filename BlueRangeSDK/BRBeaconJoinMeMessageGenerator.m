//
//  BRBeaconJoinMeMessageGenerator.m
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

#import "BRBeaconJoinMeMessageGenerator.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BRConstants.h"
#import "BRBeaconJoinMeMessage.h"
#import "BRByteArrayParser.h"

@implementation BRBeaconJoinMeMessageGenerator

- (BOOL) matches: (NSDictionary*) advertisementData {
    
    // Extract manufacturer specific data out of the advertisement data
    NSData* manufacturerData = [advertisementData valueForKey:CBAdvertisementDataManufacturerDataKey];
    uint8_t* manufacturerDataPointer = (uint8_t*)[manufacturerData bytes];
    
    // 0. If no manufacturer specific data are available, this is not a valid beacon
    if (manufacturerData == nil) {
        return false;
    }
    
    // 1. Company identifier must be the M-Way identifier.
    uint16_t companyId = manufacturerDataPointer[0] + (manufacturerDataPointer[1] << 8);
    if (companyId != kMwayCompanyIdentifier) {
        return false;
    }
    
    // 2. Mesh identifier must be "f0"
    const uint8_t EXPECTED_MESH_IDENTIFIER = 0xf0;
    uint8_t meshIdentifier = manufacturerDataPointer[2];
    if (meshIdentifier != EXPECTED_MESH_IDENTIFIER) {
        return false;
    }
    
    // 3. Message type must be the "JoinMe" message type.
    const uint8_t EXPECTED_MESSAGE_TYPE_JOIN_ME = 1;
    uint8_t messageType = manufacturerDataPointer[5];
    if (messageType != EXPECTED_MESSAGE_TYPE_JOIN_ME) {
        return false;
    }
    
    // In all other cases, this beacon message is a join me message.
    return true;
}

- (BRBeaconMessage*) newMessage: (NSDictionary*) advertisementData withRssi: (int) rssi {
    
    // Extract manufacturer specific data out of the advertisement data
    NSData* manufacturerData = [advertisementData valueForKey:CBAdvertisementDataManufacturerDataKey];
    uint8_t* manufacturerDataPointer = (uint8_t*)[manufacturerData bytes];
    
    BRByteArrayParser *parser = [[BRByteArrayParser alloc] initWithOffset:3];
    // BlueRange advertising message header
    int networkId = [parser readSwappedUnsignedShort:manufacturerDataPointer];
    [parser readSwappedByte:manufacturerDataPointer]; // message type
    // Join me payload
    int nodeId = [parser readSwappedUnsignedShort:manufacturerDataPointer];
    long long clusterId = [parser readSwappedUnsignedInteger:manufacturerDataPointer];
    short clusterSize = [parser readSwappedShort:manufacturerDataPointer];
    short freeInConnections = [parser readSwappedBitsOfByteWithLockedPointer:manufacturerDataPointer andStartBit:0 andEndBit:2];
    short freeOutConnections = [parser readSwappedBitsOfByte:manufacturerDataPointer andStartBit:3 andEndBit:7];
    
    short batteryRuntime = [parser readSwappedUnsignedByte:manufacturerDataPointer];
    short txPower = [parser readSwappedUnsignedByte:manufacturerDataPointer];
    short deviceType = [parser readSwappedUnsignedByte:manufacturerDataPointer];
    int hopsToSink = [parser readSwappedShort:manufacturerDataPointer];
    int meshWriteHandle = [parser readSwappedShort:manufacturerDataPointer];
    long long ackField = [parser readSwappedUnsignedInteger:manufacturerDataPointer];
    
    // Create a new Join me message instance.
    BRBeaconJoinMeMessage __autoreleasing *message = [[BRBeaconJoinMeMessage alloc]
        initWithNetworkId:networkId
        andSender:nodeId
        andClusterId:clusterId
        andClusterSize:clusterSize
        andFreeInConnections:freeInConnections
        andFreeOutConnections:freeOutConnections
        andBatteryRuntime:batteryRuntime
        andTxPower:txPower
        andDeviceType:deviceType
        andHopsToSink:hopsToSink
        andMeshWriteHandle:meshWriteHandle
        andAckField:ackField
        andRssi:rssi];
    
    return message;
}

- (BOOL) isEqual:(id)object {
    if (!([object isKindOfClass:[BRBeaconJoinMeMessageGenerator class]])) {
        return false;
    }
    // All join me message generators are the same.
    return true;
}

@end
