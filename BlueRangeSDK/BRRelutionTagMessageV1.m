//
//  BRRelutionTagMessageV1.m
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

#import "BRRelutionTagMessageV1.h"

// BRConstants
NSString * const RELUTION_TAG_MESSAGE_TAGS_KEY = @"tags";
NSString * const RELUTION_TAG_MESSAGE_TXPOWEr_KEY = @"txPower";

@implementation BRRelutionTagMessageV1

- (id) initWithTags: (NSArray*) tags andRssi: (int) rssi andTxPower: (short) txPower {
    if (self = [super initWithTimestamp:[NSDate date] andRssi:rssi]) {
        self->_tags = [tags copy];
        self->_txPower = txPower;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self->_tags = [coder decodeObjectForKey:RELUTION_TAG_MESSAGE_TAGS_KEY];
        self->_txPower = [coder decodeIntForKey:RELUTION_TAG_MESSAGE_TXPOWEr_KEY];
    }
    return self;
}

- (NSString *) getDescription {
    NSMutableString *outputString = [NSMutableString stringWithFormat:@"BRRelutionTagMessageV1: tags = "];
    for (int i = 0; i < [self.tags count]; i++) {
        if (i != 0) {
            [outputString appendString:@", "];
        }
        long tag = [[self.tags objectAtIndex:i] longValue];
        [outputString appendString:[NSString stringWithFormat:@"%ld", tag]];
    }
    [outputString appendFormat:@", txPower = %d", self.txPower];
    return outputString;
}

- (BRBeaconMessage*) newCopy {
    BRRelutionTagMessageV1 *clonedMessage = [[BRRelutionTagMessageV1 alloc] initWithTags:self.tags andRssi:self.rssi andTxPower:self.txPower];
    return clonedMessage;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    BRRelutionTagMessageV1 *newMessage = [super copyWithZone:zone];
    newMessage->_tags = [self.tags copyWithZone:zone];
    newMessage->_txPower = self.txPower;
    return newMessage;
}

- (BOOL) isEqual:(id)object {
    if (!([object isKindOfClass:[BRRelutionTagMessageV1 class]])) {
        return false;
    }
    BRRelutionTagMessageV1 *beaconMessage = (BRRelutionTagMessageV1*)object;
    return [beaconMessage.tags isEqual:self.tags];
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.tags forKey:RELUTION_TAG_MESSAGE_TAGS_KEY];
    [coder encodeInt:self.txPower forKey:RELUTION_TAG_MESSAGE_TXPOWEr_KEY];
}

- /* Override */ (NSUInteger) hash {
    int hash = 0;
    for (int i = 0; i < [self->_tags count]; i++) {
        hash *= [[self->_tags objectAtIndex:i] longValue];
    }
    return hash;
}

@end
