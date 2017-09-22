//
//  BREddystoneUidMessage.h
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
#import "BREddystoneMessage.h"

// Forward declarations
@class BRBeaconMessage;
@class BREddystoneMessage;

// BRConstants
extern const int EDDYSTONE_UID_NAMESPACE_BYTE_LENGTH;
extern const int EDDYSTONE_UID_INSTANCE_BYTE_LENGTH;

/**
 * Represents an Eddystone UID message containing a Namespace UID
 * and an instance identifier.
 */
@interface BREddystoneUidMessage : BREddystoneMessage {
    NSString* _namespaceUid;
    NSString* _instanceId;
    int _txPower;
}

@property (readonly) NSString* namespaceUid;
@property (readonly) NSString* instanceId;

- (id) initWithNamespaceUid: (NSString* ) namespaceUid andInstanceId: (NSString*) instanceId;
- (id) initWithNamespaceUid: (NSString* ) namespaceUid andInstanceId: (NSString*) instanceId andTxPower: (int) txPower;
- (id) initWithNamespaceUid: (NSString* ) namespaceUid andInstanceId: (NSString*) instanceId andTxPower: (int) txPower andRssi: (int) rssi;
- (id) initWithCoder:(NSCoder *)coder;
- (NSString *) getDescription;
- (BRBeaconMessage*) newCopy;
- (id)copyWithZone:(struct _NSZone *)zone;
- (BOOL) isEqual:(id)object;
- (void) encodeWithCoder:(NSCoder *)coder;

- /* Override */ (short) txPower;
- /* Override */ (NSUInteger) hash;

+ (NSString*) getHexStringFromBytes: (uint8_t*) bytes andStartByte: (int) startByte andLength: (int) length;
+ (NSString*) getNormalizedStringIdentifierForIdentifier:
(NSString*) identifier targetByteLength: (int) targetByteLength;

@end
