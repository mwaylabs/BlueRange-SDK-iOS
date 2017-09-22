//
//  BRBeaconMessageScannerConfig.h
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

@class BRIBeaconMessageScanner;

/**
 * This class encapsulates the {@link BRBeaconMessageScanner}'s configuration. If the configuration
 * is changed, while the scanner is running, the scanner will be restarted automatically with the
 * updated configuration. To add messages the scanner should scan for, call the methods that
 * start with 'scan'. The scanPeriod defines the interval duration of each scan cycle. The lower
 * this value is, the more messages can be processed in a certain time. However setting this
 * value too low, might decrease the overall performance of your application, since all
 * components of the message processing architecture, might depend on the duration of a scan
 * cycle. Moreover, you should consider, that a low value will increase the battery consumption
 * due to the increased CPU utilization.
 */
@interface BRBeaconMessageScannerConfig : NSObject {
    // Back reference to the scanner.
    BRIBeaconMessageScanner* __weak _scanner;
    // Message generators
    NSMutableArray *_iBeaconMessageGenerators;
    NSMutableArray *_defaultScannerMessageGenerators;
    // The periodic time that is spent collecting beacon messages until they are inspected.
    long _scanPeriodInMs;
    // The time between the scan periods where no beacons will be detected.
    long _betweenScanPeriodInMs;
}

// Construction

/**
 Creates a new beacon scanner configuration.

 @param scanner The scanner which the configuration is bound to.
 @return The newly created scanner configuration
 */
- (id) initWithScanner: (BRIBeaconMessageScanner*) scanner;


// iBeacon messages

/**
 Configures the scanner to scan for iBeacon messages containing
 the given @code{uuid}, @code{major} and @code{minor}.

 @param uuid The iBeacon's UUID
 @param major The iBeacon's major
 @param minor The iBeacon's minor
 */
- (void) scanIBeacon: (NSString*) uuid major: (int) major minor: (int) minor;


/**
 Configures the scanner to scan for iBeacon messages with the given
 UUID and major neglecting the minor.

 @param uuid The iBeacon's UUID
 @param major The iBeacon's major
 */
- (void) scanIBeacon: (NSString*) uuid major: (int) major;


/**
 Configures the scanner to scan for iBeacon messages with the given UUID.
 Major and minor will be neglected.

 @param uuid The iBeacon's UUID
 */
- (void) scanIBeacon: (NSString*) uuid;


/**
 Configures the scanner to scan for iBeacon messages matching one
 of the given UUIDs.

 @param uuidStrings An array containing the iBeacon UUIDs as @code{NSString}
 */
- (void) scanIBeaconUuids: (NSArray*) uuidStrings;


/**
 Configures the scanner to scan for iBeacon messages matching one
 of the given iBeacon regions.

 @param iBeacons An array containing iBeacon regions (UUID, major, minor).
 */
- (void) scanIBeacons: (NSArray*) iBeacons;


// Relution Tag messages V1


/**
 Configures the scanner to scan for Relution Tag messages (V1) containing
 at least on of the given tags. @link{RelutionTagMessageV1} is deprecated
 and should not be used anymore.

 @param tags An array of @link{NSNumber} objects containing the Relution tag IDs.
 */
- (void) scanRelutionTagsV1: (NSArray*) tags;


/**
 Configures the scanner to scan for all Relution Tag messages (V1).
 @link{RelutionTagMessageV1} is deprecated and should not be used anymore.
 */
- (void) scanRelutionTagsV1;


// Relution Tag messages V2

/**
 Configures the scanner to scan for Relution Tag messages (V2).

 @param namespaceUid The namespaceUID (is determined by the Relution Organization UUID).
 */
- (void) scanRelutionTags: (NSString*) namespaceUid;


/**
 Configures the scanner to scan for Relution Tag messages (V2) containing
 at least one of the given tags.

 @param namespaceUid The namespaceUID (is determined by the Relution Organization UUID).
 @param tags An array of @link{NSNumber} objects containing the Relution Tag IDs.
 */
- (void) scanRelutionTags: (NSString*) namespaceUid andTags: (NSArray*) tags;

// Eddystone messages

/**
 Configures the scanner to scan for all Eddystone UID messages.
 */
- (void) scanEddystoneUid;


/**
 Configures the scanner to scan for Eddystone UID messages matching the
 given Namespace UID.

 @param namespaceUid The namespace UID given as @link{NSString}.
 */
- (void) scanEddystoneUidWithNamespace: (NSString*) namespaceUid;


/**
 Configures the scanner to scan for Eddystone UID messages matching one
 of the given Namespace UIDs.

 @param namespaceUids An array containing the Namespace UIDs (@link{NSString}).
 */
- (void) scanEddystoneUidWithNamespaces: (NSArray*) namespaceUids;


/**
 Configures the scanner to scan for Eddystone UID messages matching the
 given Namespace UID and Instance ID.

 @param namespaceUid The namespace UID given as @link{NSString}.
 @param instanceId The Eddystone UID instance identifier.
 */
- (void) scanEddystoneUidWithNamespace: (NSString*) namespaceUid andInstanceId: (NSString*) instanceId;


/**
 Configures the scanner to scan for Eddystone UID messages matching the
 given Namespace UID and one of the Instance IDs.

 @param namespaceUid The namespace UID given as @link{NSString}.
 @param instanceIds An array containing the Eddystone Instance IDs (@link{NSString}).
 */
- (void) scanEddystoneUidWithNamespace: (NSString*) namespaceUid andInstanceIds: (NSArray*) instanceIds;


/**
 Configures the scanner to scan for all Eddystone URL messages.
 */
- (void) scanEddystoneUrls;


/**
 Configures the scanner to scan for Eddystone URL messages matching
 the given URL.

 @param url The Eddystone URL.
 */
- (void) scanEddystoneUrl: (NSString*) url;


/**
 Configures the scanner to scan for Eddystone URL messages matching
 one of the given URLs.

 @param urls An array containt the Eddystone URLs (@link{NSString}).
 */
- (void) scanEddystoneUrls: (NSArray*) urls;

// JoinMe messages

/**
 Configures the scanner to scan for JoinMe messages. JoinMe messages
 can be used to detect and analyze Relution SmartBeacons.
 */
- (void) scanJoinMeMessages;

// Configuration


/**
 Sets the duration of one scan cycle.

 @param scanPeriodInMs The scan cycle in milliseconds.
 */
- (void) setScanPeriodInMs:(long)scanPeriodInMs;


/**
 Returns the scanner's scan cycle duration.

 @return The scan cycle duration in milliseconds.
 */
- (long) scanPeriodInMs;


/**
 Sets the sleep duration between each scan cycle.
 The higher this value is the more energy can be saved.
 However a high value will result in a higher beacon detection delay!

 @param betweenScanPeriodInMs the sleep duration between each scan cycle in milliseconds.
 */
- (void) setBetweenScanPeriodInMs:(long)betweenScanPeriodInMs;


/**
 Returns the sleep duration between each scan cycle.

 @return The sleep duration in milliseconds.
 */
- (long) betweenScanPeriodInMs;


// Protected methods

- /*protected*/ (NSArray*) getIBeaconMessageGenerators;
- /*protected*/ (NSArray*) getDefaultScannerMessageGenerators;

@end
