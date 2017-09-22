//
//  BRRelutionTagMessageGeneratorV1.m
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

#import "BRRelutionTagMessageGeneratorV1.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BRConstants.h"
#import "BRRelutionTagMessageV1.h"

@interface BRRelutionTagMessageGeneratorV1()

// Private methods
- (int) getTxPower: (NSDictionary*) advertisementData;
- (BOOL) containsTag: (long) tag;
- (BOOL) tagsAreSame: (NSArray*) tags1 tags2: (NSArray*) tags2;

@end

@implementation BRRelutionTagMessageGeneratorV1

- (id) init {
    if (self = [super init]) {
        self->_tagFilteringEnabled = false;
    }
    return self;
}

- (id) initWithTags: (NSArray*) tags {
    if (self = [super init]) {
        self->_tags = [tags copy];
        self->_tagFilteringEnabled = true;
    }
    return self;
}

- (BOOL) matches: (NSDictionary*) advertisementData {
    @try {
        // Extract manufacturer specific data out of the advertisement data.
        NSData* manufacturerData = [advertisementData valueForKey:CBAdvertisementDataManufacturerDataKey];
        
        // If no manufacturer specific data are available, this is not a valid beacon
        if (manufacturerData == nil) {
            return false;
        }
        
        // Parse advertisement data
        uint8_t* manufacturerDataPointer = (uint8_t*)[manufacturerData bytes];
        uint16_t companyId = manufacturerDataPointer[0] + (manufacturerDataPointer[1] << 8);
        
        // If company identifier does not match, it is not a beacon message that matches
        // the RelutionTagMessageV1.
        if (companyId != kMwayCompanyIdentifier) {
            return false;
        }
        
        // Relution Tag message type
        uint8_t messageType = manufacturerDataPointer[2];
        if (messageType != 0x01) {
            return false;
        }
        
        if (!self->_tagFilteringEnabled) {
            return true;
        }
        
        // If at least one tag matches, the beacon matches the message filter.
        @autoreleasepool {
            NSArray *tags = [self getTags:advertisementData];
            for (NSNumber* tag in tags) {
                if ([self containsTag:[tag longValue]]) {
                    return true;
                }
            }
        }
        
        return false;
    }
    @catch (NSException *exception) {
        // If something went wront, we consider this data not to
        // match with this message generator.
        return false;
    }
}

- (NSArray*) getTags: (NSDictionary*) advertisementData
{
    NSMutableArray __autoreleasing *tags = [[NSMutableArray alloc] init];
    
    // Extract manufacturer specific data out of the advertisement data.
    NSData* manufacturerData = [advertisementData valueForKey:CBAdvertisementDataManufacturerDataKey];
    
    // Parse advertisement data
    uint8_t* manufacturerDataPointer = (uint8_t*)[manufacturerData bytes];
    uint8_t manufacturerSpecificDataLength = [manufacturerData length];
    
    // The number of tags varies according to the message lengt
    // Subtract company id (2 byte), message type (1 byte), txPower (1 byte), reserved (1 byte)
    // Then divide by three because a tag is a uint24_t
    const int kRelutionTagByteLength = kRelutionTagBitLength / 8;
    uint8_t numberOfTags = (manufacturerSpecificDataLength - 5) / kRelutionTagByteLength;
    
    // If the Relution Tags do not match, the beacon does not match to the message generator.
    for (int i = 0; i<numberOfTags; i++) {
        int pos = i * kRelutionTagByteLength;
        long tagId = (long)
              ((manufacturerDataPointer[5+pos] << 0)
            + (manufacturerDataPointer[6+pos] << 8)
            + (manufacturerDataPointer[7+pos] << 16));
        
        NSNumber *tag = [NSNumber numberWithLong:tagId];
        [tags addObject:tag];
    }
    return tags;
}

- (int) getTxPower: (NSDictionary*) advertisementData
{
    // Extract manufacturer specific data out of the advertisement data.
    NSData* manufacturerData = [advertisementData valueForKey:CBAdvertisementDataManufacturerDataKey];
    
    // Parse advertisement data
    uint8_t* manufacturerDataPointer = (uint8_t*)[manufacturerData bytes];
    int8_t txPower = manufacturerDataPointer[3];
    
    return txPower;
}

- (BOOL) containsTag: (long) tag {
    for (NSNumber* t in self->_tags) {
        if ([t longValue] == tag) {
            return true;
        }
    }
    return false;
}

- (BRBeaconMessage*) newMessage: (NSDictionary*) advertisementData withRssi: (int) rssi {
    NSArray *tags = [self getTags:advertisementData];
    short txPower = [self getTxPower:advertisementData];
    // Since the method name starts with "new" the ownership of this object is
    // transferred to the calling method.
    BRRelutionTagMessageV1 *message = [[BRRelutionTagMessageV1 alloc] initWithTags:tags andRssi: rssi andTxPower:txPower];
    return message;
}

- (BOOL) isEqual:(id)object {
    if (!([object isKindOfClass:[BRRelutionTagMessageGeneratorV1 class]])) {
        return false;
    }
    BRRelutionTagMessageGeneratorV1 *generator = (BRRelutionTagMessageGeneratorV1*)object;
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
