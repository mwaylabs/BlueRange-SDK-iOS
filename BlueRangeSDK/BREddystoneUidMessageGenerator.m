//
//  BREddystoneUidMessageGenerator.m
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

#import "BREddystoneUidMessageGenerator.h"
#import "BREddystoneUidMessage.h"
#import <CoreBluetooth/CoreBluetooth.h>

// Private methods
@interface BREddystoneUidMessageGenerator()

- (void) initialize;

@end

@implementation BREddystoneUidMessageGenerator

- (id) init {
    if (self = [super init]) {
        [self initialize];
        self->_namespaceFilteringEnabled = false;
        self->_instanceFilteringEnabled = false;
    }
    return self;
}

- (id) initWithNamespace: (NSString*) namespaceUid {
    if (self = [super init]) {
        [self initialize];
        self->_namespaceFilteringEnabled = true;
        self->_instanceFilteringEnabled = false;
        self->_namespaceUid = [BREddystoneUidMessage getNormalizedStringIdentifierForIdentifier:
                            namespaceUid targetByteLength:EDDYSTONE_UID_NAMESPACE_BYTE_LENGTH];
    }
    return self;
}

- (id) initWithNamespace: (NSString*) namespaceUid andInstance: (NSString*) instance {
    if (self = [super init]) {
        [self initialize];
        self->_namespaceFilteringEnabled = true;
        self->_instanceFilteringEnabled = true;
        self->_namespaceUid = [BREddystoneUidMessage getNormalizedStringIdentifierForIdentifier:
                            namespaceUid targetByteLength:EDDYSTONE_UID_NAMESPACE_BYTE_LENGTH];
        self->_instance = [BREddystoneUidMessage getNormalizedStringIdentifierForIdentifier:
                            instance targetByteLength:EDDYSTONE_UID_INSTANCE_BYTE_LENGTH];
    }
    return self;
}

- (void) initialize {
    _namespaceFilteringEnabled = false;
    _namespaceUid = nil;
    _blacklistedNamespaces = [[NSMutableArray alloc] init];
    _instanceFilteringEnabled = false;
    _instance = nil;
}

- /* override */ (BOOL) matches: (NSDictionary*) advertisementData {
    if (![super matches:advertisementData]) {
        return false;
    }
    @try {
        // Extract manufacturer specific data out of the advertisement data
        NSData* beaconServiceData = [self getServiceDataForAdvertisementData:advertisementData];
        uint8_t* data = (uint8_t*)[beaconServiceData bytes];
        
        // 0. If no manufacturer specific data are available, this is not a valid beacon
        if (beaconServiceData == nil) {
            return false;
        }
        
        // 1. FrameType
        const uint8_t EXPECTED_FRAME_TYPE = EDDY_FRAME_UID;
        uint8_t frameType = data[0];
        if (frameType != EXPECTED_FRAME_TYPE) {
            return false;
        }
        
        // 2. Check namespace
        if (self->_namespaceFilteringEnabled) {
            NSString* hexString = [BREddystoneUidMessage getHexStringFromBytes:(data)
                                                                andStartByte:2 andLength:EDDYSTONE_UID_NAMESPACE_BYTE_LENGTH];
            NSString* readNamespace = [BREddystoneUidMessage getNormalizedStringIdentifierForIdentifier:
                                       hexString targetByteLength:EDDYSTONE_UID_NAMESPACE_BYTE_LENGTH];
            NSString* actualNamespace = [BREddystoneUidMessage getNormalizedStringIdentifierForIdentifier:
                                         readNamespace targetByteLength:EDDYSTONE_UID_NAMESPACE_BYTE_LENGTH];
            NSString* acceptedNamespace = [BREddystoneUidMessage getNormalizedStringIdentifierForIdentifier:
                                           self->_namespaceUid targetByteLength:EDDYSTONE_UID_NAMESPACE_BYTE_LENGTH];
            if (![actualNamespace isEqualToString:acceptedNamespace]) {
                return false;
            }
            
            // Consider blacklisted namespaces as well
            if ([self->_blacklistedNamespaces containsObject:actualNamespace]) {
                return false;
            }
        }
        
        // 3. Check instance
        if (self->_instanceFilteringEnabled) {
            NSString* hexString = [BREddystoneUidMessage getHexStringFromBytes:(data)
                                                                andStartByte:12 andLength:EDDYSTONE_UID_INSTANCE_BYTE_LENGTH];
            NSString* readInstace = [BREddystoneUidMessage getNormalizedStringIdentifierForIdentifier:
                                       hexString targetByteLength:EDDYSTONE_UID_INSTANCE_BYTE_LENGTH];
            NSString* actualInstance = [BREddystoneUidMessage getNormalizedStringIdentifierForIdentifier:
                                         readInstace targetByteLength:EDDYSTONE_UID_INSTANCE_BYTE_LENGTH];
            NSString* acceptedInstance = [BREddystoneUidMessage getNormalizedStringIdentifierForIdentifier:
                                           self->_instance targetByteLength:EDDYSTONE_UID_INSTANCE_BYTE_LENGTH];
            
            if (![actualInstance isEqualToString:acceptedInstance]) {
                return false;
            }
        }
    } @catch (NSException* e) {
        return false;
    }
    
    // In all other cases...
    return true;
}

- /* override */ (BRBeaconMessage*) newMessage: (NSDictionary*) advertisementData withRssi: (int) rssi {
    // Extract manufacturer specific data out of the advertisement data
    NSData* beaconServiceData = [self getServiceDataForAdvertisementData:advertisementData];
    uint8_t* data = (uint8_t*)[beaconServiceData bytes];
    
    // 1. TxPower (we add -41 dBm as specified in the Eddystone specification)
    int txPower = (int)((int8_t*)([beaconServiceData bytes]))[1] + -41;
    
    // 2. Namespace
    NSString* namespaceHexString = [BREddystoneUidMessage getHexStringFromBytes:(data)
                                                        andStartByte:2 andLength:EDDYSTONE_UID_NAMESPACE_BYTE_LENGTH];
    NSString* namespaceUid = [BREddystoneUidMessage getNormalizedStringIdentifierForIdentifier:
                               namespaceHexString targetByteLength:EDDYSTONE_UID_NAMESPACE_BYTE_LENGTH];
    
    // 3. Instance
    NSString* instanceHexString = [BREddystoneUidMessage getHexStringFromBytes:(data)
                                                        andStartByte:12 andLength:EDDYSTONE_UID_INSTANCE_BYTE_LENGTH];
    NSString* instanceId = [BREddystoneUidMessage getNormalizedStringIdentifierForIdentifier:
                             instanceHexString targetByteLength:EDDYSTONE_UID_INSTANCE_BYTE_LENGTH];
    
    // Create a new message
    BREddystoneUidMessage __autoreleasing *message = [[BREddystoneUidMessage alloc]
                                                    initWithNamespaceUid:namespaceUid
                                                    andInstanceId:instanceId andTxPower:txPower
                                                    andRssi: rssi];
    
    return message;
}

- /* override */ (BOOL) isEqual:(id)object {
    if (!([object isKindOfClass:[BREddystoneUidMessageGenerator class]])) {
        return false;
    }
    BREddystoneUidMessageGenerator *generator = (BREddystoneUidMessageGenerator*)object;
    
    if ((self->_namespaceFilteringEnabled && generator->_namespaceFilteringEnabled)
        && (![generator->_namespaceUid isEqualToString:self->_namespaceUid])) {
        return false;
    }
    
    if ((self->_instanceFilteringEnabled && generator->_instanceFilteringEnabled)
        && (![generator->_instance isEqualToString:self->_instance])) {
        return false;
    }
    
    return true;
}

- (void) blacklistNamespace: (NSString*) namespaceUid {
    [self->_blacklistedNamespaces addObject:namespaceUid];
}

@end
