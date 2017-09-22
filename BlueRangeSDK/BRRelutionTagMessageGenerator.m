//
//  BRRelutionTagMessageGenerator.m
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

#import "BRRelutionTagMessageGenerator.h"
#import "BRRelutionTagMessage.h"

// Private methods
@interface BRRelutionTagMessageGenerator()

- (BOOL) tagsAreSame: (NSArray*) tags1 tags2: (NSArray*) tags2;

@end

@implementation BRRelutionTagMessageGenerator

- (id) initWithNamespace:(NSString *)namespaceUid {
    if (self = [super initWithNamespace:namespaceUid]) {
        self->_tagFilteringEnabled = false;
    }
    return self;
}

- (id) initWithNamespace:(NSString *)namespaceUid andTags: (NSArray*) tags {
    if (self = [super initWithNamespace:namespaceUid]) {
        self->_tags = tags;
        self->_tagFilteringEnabled = true;
    }
    return self;
}

- (BOOL) matches: (NSDictionary*) advertisementData {
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
        
        // 2. Check if at least one tag matches the filter
        if (self->_tagFilteringEnabled) {
            NSString* hexString = [BREddystoneUidMessage getHexStringFromBytes:(data)
                                                                andStartByte:12 andLength:EDDYSTONE_UID_INSTANCE_BYTE_LENGTH];
            NSString* readInstace = [BREddystoneUidMessage getNormalizedStringIdentifierForIdentifier:
                                     hexString targetByteLength:EDDYSTONE_UID_INSTANCE_BYTE_LENGTH];
            BRRelutionTagMessage* message = [[BRRelutionTagMessage alloc]
                                           initWithNamespaceUid:self->_namespaceUid andInstanceId:readInstace];
            NSArray* tagList = [message tags];
            for (int i = 0; i < [self->_tags count]; i++) {
                if ([tagList containsObject:[self->_tags objectAtIndex:i]]) {
                    return true;
                }
            }
            return false;
        }
    } @catch (NSException* e) {
        return false;
    }
    
    // In all other cases...
    return true;

}

- (BRBeaconMessage*) newMessage: (NSDictionary*) advertisementData withRssi: (int) rssi {
    BRBeaconMessage* message = [super newMessage:advertisementData withRssi:rssi];
    BREddystoneUidMessage* eddystoneUidMessage = (BREddystoneUidMessage*)message;
    BRRelutionTagMessage* relutionTagMessage = [[BRRelutionTagMessage alloc]
                                              initWithNamespaceUid:eddystoneUidMessage.namespaceUid
                                              andInstanceId:eddystoneUidMessage.instanceId
                                              andTxPower:eddystoneUidMessage.txPower
                                              andRssi:eddystoneUidMessage.rssi];
    return relutionTagMessage;
}

- (BOOL) isEqual:(id)object {
    if (![super isEqual:object]) {
        return false;
    }
    
    if (!([object isKindOfClass:[BRRelutionTagMessageGenerator class]])) {
        return false;
    }
    BRRelutionTagMessageGenerator *generator = (BRRelutionTagMessageGenerator*)object;
    
    // If at least one of the generators filters all Relution tags, it is considered
    // to be "the same" generator since it enclosed the other one.
    if ((self->_tagFilteringEnabled && generator->_tagFilteringEnabled)
        && ![self tagsAreSame: generator->_tags tags2: self->_tags]) {
        return false;
    }
    return true;
}

- (BOOL) tagsAreSame: (NSArray*) tags1 tags2: (NSArray*) tags2 {
    if ([tags1 count] != [tags2 count]) {
        return false;
    }
    for (int i = 0; i < [tags1 count]; i++) {
        long tag1 = [[tags1 objectAtIndex:i] longValue];
        BOOL containsTag1 = false;
        for (int j = 0; j < [tags2 count]; j++) {
            long tag2 = [[tags2 objectAtIndex:j] longValue];
            if (tag1 == tag2) {
                containsTag1 = true;
            }
        }
        if (!containsTag1) {
            return false;
        }
    }
    return true;
}

@end
