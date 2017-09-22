//
//  BREddystoneUidMessage.m
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

#import "BREddystoneUidMessage.h"
#import "BREddystoneMessage.h"
#import "BRBeaconMessage.h"

// BRConstants
const int EDDYSTONE_UID_NAMESPACE_BYTE_LENGTH = 10;
const int EDDYSTONE_UID_INSTANCE_BYTE_LENGTH = 6;

NSString * const EDDYSTONE_UID_MESSAGE_NAMESPACE_KEY = @"namespaceUid";
NSString * const EDDYSTONE_UID_MESSAGE_INSTANCE_KEY = @"instanceId";

// Private methods
@interface BREddystoneUidMessage ()

- (NSString*) getPrettyIdentifier: (NSString*) identifier;

@end

@implementation BREddystoneUidMessage

- (id) initWithNamespaceUid: (NSString* ) namespaceUid andInstanceId: (NSString*) instanceId {
    return [self initWithNamespaceUid:namespaceUid andInstanceId:instanceId andTxPower:-50];
}

- (id) initWithNamespaceUid: (NSString* ) namespaceUid andInstanceId: (NSString*) instanceId andTxPower: (int) txPower {
    return [self initWithNamespaceUid:namespaceUid andInstanceId:instanceId andTxPower:txPower andRssi:-70];
}

- (id) initWithNamespaceUid: (NSString* ) namespaceUid andInstanceId: (NSString*) instanceId andTxPower: (int) txPower andRssi: (int) rssi {
    if (self = [super init]) {
        self->_namespaceUid = [BREddystoneUidMessage getNormalizedStringIdentifierForIdentifier:
                               namespaceUid targetByteLength: EDDYSTONE_UID_NAMESPACE_BYTE_LENGTH];
        self->_instanceId = [BREddystoneUidMessage getNormalizedStringIdentifierForIdentifier:
                             instanceId targetByteLength:EDDYSTONE_UID_INSTANCE_BYTE_LENGTH];
        self->_txPower = txPower;
        [self setRssi:rssi];
    }
    return self;
}

+ (NSString*) getHexStringFromBytes: (uint8_t*) bytes andStartByte: (int) startByte andLength: (int) length {
    unsigned char *dataBuffer = (unsigned char *)malloc(length);
    for (int i = 0; i < length; i++) {
        dataBuffer[i] = (unsigned char)(bytes[i+startByte]);
    }
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger dataLength  = length;
    NSMutableString* hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    
    return [NSString stringWithString:hexString];
}

+ (NSString*) getNormalizedStringIdentifierForIdentifier: (NSString*) identifier targetByteLength: (int) targetByteLength {
    NSString* result = [NSString stringWithFormat:@"%@", identifier];
    int targetStringLength = targetByteLength*2;
    int numZerosToAdd = targetStringLength - (int)[result length];
    for (int i = 0; i < numZerosToAdd; i++) {
        result = [NSString stringWithFormat:@"0%@", result];
    }
    result = [result uppercaseString];
    return result;
}

- (id) initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        NSString* namespaceUid = [coder decodeObjectForKey:EDDYSTONE_UID_MESSAGE_NAMESPACE_KEY];
        NSString* instanceId = [coder decodeObjectForKey:EDDYSTONE_UID_MESSAGE_INSTANCE_KEY];
        self->_namespaceUid = namespaceUid;
        self->_instanceId = instanceId;
    }
    return self;
}

- (NSString *) getDescription {
    return [NSString stringWithFormat:@"Eddystone UID: Namespace: %@, instance: %@",
            self->_namespaceUid, self->_instanceId];
}

- (BRBeaconMessage*) newCopy {
    BREddystoneUidMessage *clonedMessage
        = [[BREddystoneUidMessage alloc] initWithNamespaceUid:self->_namespaceUid andInstanceId:self->_instanceId];
    return clonedMessage;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    BREddystoneUidMessage *newMessage = [super copyWithZone:zone];
    return newMessage;
}

- (BOOL) isEqual:(id)object {
    if (!([object isKindOfClass:[BREddystoneUidMessage class]])) {
        return false;
    }
    BREddystoneUidMessage *message = (BREddystoneUidMessage*)object;
    return [[message namespaceUid] isEqual:[self namespaceUid]]
        && [[message instanceId] isEqual:[self instanceId]];
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self->_namespaceUid forKey:EDDYSTONE_UID_MESSAGE_NAMESPACE_KEY];
    [coder encodeObject:self->_instanceId forKey:EDDYSTONE_UID_MESSAGE_INSTANCE_KEY];
}

- /* Override */ (short) txPower {
    return self->_txPower;
}

- /* Override */ (NSUInteger) hash {
    return [self.namespaceUid hash] + [self.instanceId hash];
}

- (NSString*) namespaceUid {
    return [self getPrettyIdentifier:self->_namespaceUid];
}

- (NSString*) instanceId {
    return [self getPrettyIdentifier:self->_instanceId];
}

- (NSString*) getPrettyIdentifier: (NSString*) identifier {
    int numSignsToRemove = 0;
    for (int i = 0; i < [identifier length]; i++) {
        if ([identifier characterAtIndex:i] == '0') {
            numSignsToRemove++;
        } else {
            break;
        }
    }
    // Do not remove zeros if it belongs to a non-zero byte in the string.
    // -> Remove only tuples of zeros.
    if (numSignsToRemove % 2 != 0) {
        numSignsToRemove--;
    }
    return [identifier substringFromIndex:numSignsToRemove];
}

@end
