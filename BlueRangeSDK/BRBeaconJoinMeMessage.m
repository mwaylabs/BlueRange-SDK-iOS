//
//  BRBeaconJoinMeMessage.m
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

#import "BRBeaconJoinMeMessage.h"

// BRConstants
NSString * const JOIN_ME_NETWORK_ID_KEY = @"networkId";
NSString * const JOIN_ME_NODE_ID_KEY = @"nodeId";
NSString * const JOIN_ME_CLUSTER_ID_KEY = @"clusterId";
NSString * const JOIN_ME_CLUSTER_SIZE_KEY = @"clusterSize";
NSString * const JOIN_ME_FREE_IN_CONNECTIONS_KEY = @"freeInConnections";
NSString * const JOIN_ME_FREE_OUT_CONNECTIONS_KEY = @"freeOutConnections";

NSString * const JOIN_ME_BATTERY_RUNTIME_KEY = @"batteryRuntime";
NSString * const JOIN_ME_TX_POWER_KEY = @"txPower";
NSString * const JOIN_ME_DEVICE_TYPE_KEY = @"deviceType";
NSString * const JOIN_ME_HOPS_TO_SINK_KEY = @"hopsToSink";
NSString * const JOIN_ME_MESH_WRITE_HANDLE_KEY = @"meshWriteHandle";
NSString * const JOIN_ME_ACKFIELD_KEY = @"ackField";

@implementation BRBeaconJoinMeMessage

@synthesize networkId;
@synthesize nodeId;
@synthesize clusterId;
@synthesize clusterSize;
@synthesize freeInConnections;
@synthesize freeOutConnections;

// Version specific content
@synthesize batteryRuntime;
@synthesize txPower;
@synthesize deviceType;
@synthesize hopsToSink;
@synthesize meshWriteHandle;
@synthesize ackField;

- (id) initWithNetworkId: (int) _networkId andSender: (int) _nodeId andClusterId: (long long) _clusterId
    andClusterSize: (short) _clusterSize andFreeInConnections: (short) _freeInConnections
    andFreeOutConnections: (short) _freeOutConnections andBatteryRuntime: (short) _batteryRuntime
    andTxPower: (short) _txPower
    andDeviceType: (short) _deviceType andHopsToSink: (int) _hopsToSink
    andMeshWriteHandle: (int) _meshWriteHandle andAckField: (long long) _ackField
    andRssi: (int) _rssi {
    
    return [self initWithDate:[NSDate date]
                 andNetworkId:_networkId
                 andSender:_nodeId
                 andClusterId:_clusterId
                 andClusterSize:_clusterSize
                 andFreeInConnections:_freeInConnections
                 andFreeOutConnections:_freeOutConnections
                 andBatteryRuntime:_batteryRuntime
                 andTxPower:_txPower
                 andDeviceType:_deviceType
                 andHopsToSink:_hopsToSink
                 andMeshWriteHandle:_meshWriteHandle
                 andAckField:_ackField
                 andRssi:_rssi];
}

- (id) initWithDate: (NSDate*) _timestamp andNetworkId: (int) _networkId andSender: (int) _nodeId andClusterId: (long long) _clusterId
        andClusterSize: (short) _clusterSize andFreeInConnections: (short) _freeInConnections
        andFreeOutConnections: (short) _freeOutConnections andBatteryRuntime: (short) _batteryRuntime
        andTxPower: (short) _txPower
        andDeviceType: (short) _deviceType andHopsToSink: (int) _hopsToSink
        andMeshWriteHandle: (int) _meshWriteHandle andAckField: (long long) _ackField
        andRssi: (int) rssi {
    
    if (self = [super initWithTimestamp:_timestamp andRssi:rssi]) {
        self->networkId = _networkId;
        self->nodeId = _nodeId;
        self->clusterId = _clusterId;
        self->clusterSize = _clusterSize;
        self->freeInConnections = _freeInConnections;
        self->freeOutConnections = _freeOutConnections;
        
        self->batteryRuntime = _batteryRuntime;
        self->txPower = _txPower;
        self->deviceType = _deviceType;
        self->hopsToSink = _hopsToSink;
        self->meshWriteHandle = _meshWriteHandle;
        self->ackField = _ackField;
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self->networkId = [coder decodeIntForKey:JOIN_ME_NETWORK_ID_KEY];
        self->nodeId = [coder decodeIntForKey:JOIN_ME_NODE_ID_KEY];
        self->clusterId = [coder decodeInt64ForKey:JOIN_ME_CLUSTER_ID_KEY];
        self->clusterSize = [coder decodeIntForKey:JOIN_ME_CLUSTER_SIZE_KEY];
        self->freeInConnections = [coder decodeIntForKey:JOIN_ME_FREE_IN_CONNECTIONS_KEY];
        self->freeOutConnections = [coder decodeIntForKey:JOIN_ME_FREE_OUT_CONNECTIONS_KEY];
        
        self->batteryRuntime = [coder decodeIntForKey:JOIN_ME_BATTERY_RUNTIME_KEY];
        self->txPower = [coder decodeIntForKey:JOIN_ME_TX_POWER_KEY];
        self->deviceType = [coder decodeIntForKey:JOIN_ME_DEVICE_TYPE_KEY];
        self->hopsToSink = [coder decodeIntForKey:JOIN_ME_HOPS_TO_SINK_KEY];
        self->meshWriteHandle = [coder decodeIntForKey:JOIN_ME_MESH_WRITE_HANDLE_KEY];
        self->ackField = [coder decodeInt64ForKey:JOIN_ME_ACKFIELD_KEY];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeInt:self.networkId forKey:JOIN_ME_NETWORK_ID_KEY];
    [coder encodeInt:self.nodeId forKey:JOIN_ME_NODE_ID_KEY];
    [coder encodeInt64:self.clusterId forKey:JOIN_ME_CLUSTER_ID_KEY];
    [coder encodeInt:self.clusterSize forKey:JOIN_ME_CLUSTER_SIZE_KEY];
    [coder encodeInt:self.freeInConnections forKey:JOIN_ME_FREE_IN_CONNECTIONS_KEY];
    [coder encodeInt:self.freeOutConnections forKey:JOIN_ME_FREE_OUT_CONNECTIONS_KEY];
    
    [coder encodeInt:self.batteryRuntime forKey:JOIN_ME_BATTERY_RUNTIME_KEY];
    [coder encodeInt:self.txPower forKey:JOIN_ME_TX_POWER_KEY];
    [coder encodeInt:self.deviceType forKey:JOIN_ME_DEVICE_TYPE_KEY];
    [coder encodeInt:self.hopsToSink forKey:JOIN_ME_HOPS_TO_SINK_KEY];
    [coder encodeInt:self.meshWriteHandle forKey:JOIN_ME_MESH_WRITE_HANDLE_KEY];
    [coder encodeInt64:self.ackField forKey:JOIN_ME_ACKFIELD_KEY];
}

- (BOOL) isEqual:(id)object {
    if (!([object isKindOfClass:[BRBeaconJoinMeMessage class]])) {
        return false;
    }
    BRBeaconJoinMeMessage *beaconMessage = (BRBeaconJoinMeMessage*)object;
    return beaconMessage.nodeId == self.nodeId;
}

- (NSString *) getDescription {
    NSString *str = [NSString stringWithFormat:@"BRBeaconJoinMeMessage:nodeId: %d, rssi: %d, txPower: %d",
                     self.nodeId, self.rssi, self.txPower];
    return str;
}

- (BRBeaconMessage*) newCopy {
    BRBeaconJoinMeMessage *clonedMessage = [[BRBeaconJoinMeMessage alloc]
        initWithNetworkId:self.networkId
        andSender:self.nodeId
        andClusterId:self.clusterId
        andClusterSize:self.clusterSize
        andFreeInConnections:self.freeInConnections
        andFreeOutConnections:self.freeOutConnections
        andBatteryRuntime:self.batteryRuntime
        andTxPower:self.txPower
        andDeviceType:self.deviceType
        andHopsToSink:self.hopsToSink
        andMeshWriteHandle:self.meshWriteHandle
        andAckField:self.ackField
        andRssi:self.rssi];
    return clonedMessage;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    BRBeaconJoinMeMessage *newMessage = [super copyWithZone:zone];
    
    newMessage->networkId = self.networkId;
    newMessage->nodeId = self.nodeId;
    newMessage->clusterId = self.clusterId;
    newMessage->clusterSize = self.clusterSize;
    newMessage->freeInConnections = self.freeInConnections;
    newMessage->freeOutConnections = self.freeOutConnections;
    
    newMessage->batteryRuntime = self.batteryRuntime;
    newMessage->txPower = self.txPower;
    newMessage->deviceType = self.deviceType;
    newMessage->hopsToSink = self.hopsToSink;
    newMessage->meshWriteHandle = self.meshWriteHandle;
    newMessage->ackField = self.ackField;
    
    return newMessage;
}

- /* Override */ (NSUInteger) hash {
    return self.nodeId;
}

@end
