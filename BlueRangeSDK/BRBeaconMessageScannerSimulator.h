//
//  BRBeaconMessageScannerSimulator.h
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
