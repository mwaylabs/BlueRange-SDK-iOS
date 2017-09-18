//
//  BREddystoneUidMessage.m
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
