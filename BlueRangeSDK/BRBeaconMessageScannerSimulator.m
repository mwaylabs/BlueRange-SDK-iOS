//
//  BRBeaconMessageScannerSimulator.m
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

#import "BRBeaconMessageScannerSimulator.h"
#import "BRBeaconMessageScannerConfig.h"
#import "BRIBeaconMessage.h"
#import "BRIBeacon.h"
#import "BREddystoneUidMessage.h"
#import "BREddystoneUrlMessage.h"
#import "BRRelutionTagMessage.h"
#import "BRRelutionTagMessageV1.h"
#import "BRBeaconJoinMeMessage.h"
#import "BRBeaconMessageStreamNodeReceiver.h"
#import "BRCoreMath.h"

@interface BRBeaconMessageScannerSimulator()

- (void) startRepeatScanInParallel;
- (void) startRepeatScan;
- (void) startOneTimeScan;
- (NSArray*) getClonedMessages;

@end

@implementation BRBeaconMessageScannerSimulator

const int DEFAULT_RSSI = -50;
const int DEFAULT_TXPOWER = -60;

- (id) init {
    if (self = [super init]) {
        self->_beaconMessages = [[NSMutableArray alloc] init];
        self->_repeat = false;
        self->_repeatInterval = 0L;
        self->_config = [[BRBeaconMessageScannerConfig alloc] initWithScanner:self];
        self->_running = false;
        self->_rssiNoise = false;
    }
    return self;
}

- (void) addRssiNoise {
    self->_rssiNoise = true;
}

- (void) simulateIBeacon: (BRIBeacon*) iBeacon {
    [self simulateIBeaconWithUuid:iBeacon.uuid andMajor:iBeacon.major andMinor:iBeacon.minor];
}

- (void) simulateIBeaconWithUuid: (NSUUID*) uuid andMajor: (int) major andMinor: (int) minor {
    [self simulateIBeaconWithUuid:uuid andMajor:major andMinor:minor andRssi:DEFAULT_RSSI];
}

- (void) simulateIBeaconWithUuid: (NSUUID*) uuid andMajor: (int) major andMinor: (int) minor andRssi: (int) rssi {
    BRIBeaconMessage *message = [[BRIBeaconMessage alloc] initWithUUID:uuid major:major minor:minor rssi:rssi];
    [self->_beaconMessages addObject:message];
}

- (void) simulateEddystoneUidWithNamespace: (NSString*) namespaceUid andInstanceId: (NSString*) instanceId {
    BREddystoneUidMessage* message = [[BREddystoneUidMessage alloc] initWithNamespaceUid:namespaceUid andInstanceId:instanceId];
    [self->_beaconMessages addObject:message];
}

- (void) simulateEddystoneUidWithNamespace: (NSString*) namespaceUid andInstanceId: (NSString*) instanceId andRssi: (int) rssi {
    BREddystoneUidMessage* message = [[BREddystoneUidMessage alloc] initWithNamespaceUid:namespaceUid andInstanceId:instanceId];
    [message setRssi:rssi];
    [self->_beaconMessages addObject:message];
}

- (void) simulateEddystoneUrl: (NSString*) url {
    BREddystoneUrlMessage* message = [[BREddystoneUrlMessage alloc] initWithUrl:url];
    [self->_beaconMessages addObject:message];
}

- (void) simulateEddystoneUrl: (NSString*) url andRssi: (int) rssi {
    BREddystoneUrlMessage* message = [[BREddystoneUrlMessage alloc] initWithUrl:url];
    [message setRssi:rssi];
    [self->_beaconMessages addObject:message];
}

- (void) simulateRelutionTagsV1: (NSArray*) tags {
    [self simulateRelutionTagsV1WithRssi:tags andRssi:DEFAULT_RSSI];
}

- (void) simulateRelutionTagsV1WithRssi: (NSArray*) tags andRssi: (int) rssi {
    BRRelutionTagMessageV1 *message = [[BRRelutionTagMessageV1 alloc] initWithTags:tags andRssi:rssi andTxPower:DEFAULT_TXPOWER];
    [self->_beaconMessages addObject:message];
}

- (void) simulateRelutionTagsWithNamespaceUid: (NSString*) namespaceUid andTags: (NSArray*) tags {
    [self simulateRelutionTagsWithNamespaceUid:namespaceUid andTags:tags andRssi:DEFAULT_RSSI];
}

- (void) simulateRelutionTagsWithNamespaceUid: (NSString*) namespaceUid andTags: (NSArray*) tags andRssi: (int) rssi {
    BRRelutionTagMessage *message = [[BRRelutionTagMessage alloc] initWithNamespaceUid:namespaceUid andTags:tags andTxPower:DEFAULT_TXPOWER andRssi:rssi];
    [self->_beaconMessages addObject:message];
}

- (void) simulateJoinMeWithNodeId: (int) nodeId {
    [self simulateJoinMeWithNodeId:nodeId andRssi:DEFAULT_RSSI];
}

- (void) simulateJoinMeWithNodeId: (int) nodeId andRssi: (int) rssi {
    int networkId = 0;
    int sender = nodeId;
    long clusterId = 0;
    short clusterSize = 0;
    short freeInConnections = 0;
    short freeOutConnections = 0;
    short batteryRuntime = 0;
    short txPower = 0;
    short deviceType = 0;
    int hopsToSink = 0;
    int meshWriteHandle = 0;
    int ackField = 0;
    BRBeaconJoinMeMessage *message = [[BRBeaconJoinMeMessage alloc] initWithNetworkId:networkId andSender:sender andClusterId:clusterId andClusterSize:clusterSize andFreeInConnections:freeInConnections andFreeOutConnections:freeOutConnections andBatteryRuntime:batteryRuntime andTxPower:txPower andDeviceType:deviceType andHopsToSink:hopsToSink andMeshWriteHandle:meshWriteHandle andAckField:ackField andRssi:rssi];
    [self->_beaconMessages addObject:message];
}

- (void) resetSimulatedBeacons {
    [self->_beaconMessages removeAllObjects];
}

// Overridden
- (void) startScanning {
    self->_running = true;
    if (self.repeat) {
        [self startRepeatScanInParallel];
    } else {
        [self startOneTimeScan];
    }
}

- (void) startRepeatScanInParallel {
    [NSThread detachNewThreadSelector:@selector(startRepeatScan) toTarget:self withObject:nil];
}

- (void) startRepeatScan {
    while (self->_running) {
        [self startOneTimeScan];
        [NSThread sleepForTimeInterval:(((double)(self.repeatInterval))/1000)];
    }
}

- (void) startOneTimeScan {
    NSArray *clonedMessages = [self getClonedMessages];
    for (id<BRBeaconMessageStreamNodeReceiver> receiver in self.receivers) {
        for (BRBeaconMessage *beaconMessage in clonedMessages) {
            if (self->_rssiNoise) {
                int rssi = beaconMessage.rssi;
                float noiseStrength = 10;
                double randomValue = [BRCoreMath randomFromZeroToOne];
                float noise = (float)((randomValue * noiseStrength) - noiseStrength/2);
                float noisedRssi = rssi + noise;
                [beaconMessage setRssi:(int)noisedRssi];
            }
            [beaconMessage setTimestamp:[NSDate date]];
            [receiver onReceivedMessage: self withMessage: beaconMessage];
        }
    }
}

- (NSArray*) getClonedMessages {
    NSMutableArray *clonedMessages = [[NSMutableArray alloc] init];
    for (BRBeaconMessage *beaconMessage in self->_beaconMessages) {
        BRBeaconMessage *clonedMessage = [beaconMessage copy];
        [clonedMessages addObject:clonedMessage];
    }
    return clonedMessages;
}

- (void) stopScanning {
    self->_running = false;
}

- (void) onReceivedMessage: (BRBeaconMessageStreamNode *) senderNode withMessage: (BRBeaconMessage*) message {
    // Do not do anything.
}

@end
