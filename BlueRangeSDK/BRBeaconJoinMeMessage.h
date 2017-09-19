//
//  BRBeaconJoinMeMessage.h
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
