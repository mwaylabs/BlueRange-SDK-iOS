//
//  BRBeaconJoinMeMessage.h
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
#import "BRBeaconMessage.h"

/**
 * Beacon join me messages are send by BlueRange SmartBeacons, whenever a beacon is able to
 * connect with another one. These messages contain useful information about a beacon which can
 * be used to identify a beacon. Moreover, since they are sent regularly by a beacon these
 * messages might be used for position estimation use cases like indoor navigation.
 */
@interface BRBeaconJoinMeMessage : BRBeaconMessage

@property (readonly) int networkId;
@property (readonly) int nodeId;
@property (readonly) long long clusterId;
@property (readonly) short clusterSize;
@property (readonly)short freeInConnections;
@property (readonly) short freeOutConnections;

// Version specific content
@property (readonly) short batteryRuntime;
@property (readonly) short txPower;
@property (readonly) short deviceType;
@property (readonly) int hopsToSink;
@property (readonly) int meshWriteHandle;
@property (readonly) long long ackField;

- (id) initWithNetworkId: (int) _networkId andSender: (int) _nodeId andClusterId: (long long) _clusterId
           andClusterSize: (short) _clusterSize andFreeInConnections: (short) _freeInConnections
    andFreeOutConnections: (short) _freeOutConnections andBatteryRuntime: (short) _batteryRuntime
               andTxPower: (short) _txPower
            andDeviceType: (short) _deviceType andHopsToSink: (int) _hopsToSink
       andMeshWriteHandle: (int) _meshWriteHandle andAckField: (long long) _ackField
                  andRssi: (int) rssi;

- (id) initWithDate: (NSDate*) _timestamp andNetworkId: (int) _networkId andSender: (int) _nodeId andClusterId: (long long) _clusterId
     andClusterSize: (short) _clusterSize andFreeInConnections: (short) _freeInConnections
andFreeOutConnections: (short) _freeOutConnections andBatteryRuntime: (short) _batteryRuntime
         andTxPower: (short) _txPower
      andDeviceType: (short) _deviceType andHopsToSink: (int) _hopsToSink
 andMeshWriteHandle: (int) _meshWriteHandle andAckField: (long long) _ackField
            andRssi: (int) rssi;

- (id) initWithCoder:(NSCoder *)coder;
- (void) encodeWithCoder:(NSCoder *)coder;

- (BOOL) isEqual:(id)object;
- (NSString *) getDescription;
- (BRBeaconMessage*) newCopy;
- (id)copyWithZone:(struct _NSZone *)zone;
- /* Override */ (NSUInteger) hash;

@end
