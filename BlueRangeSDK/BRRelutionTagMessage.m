//
//  BRRelutionTagMessage.m
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

#import "BRRelutionTagMessage.h"
#import "BRByteArrayConverter.h"

NSString* RELUTION_TAG_MESSAGEV2_TAGS_KEY = @"tags";

@interface BRRelutionTagMessage()

+ (uint8_t*) getBytesFromTags: (NSArray*) tags;
+ (NSArray*) getTagsFromInstanceId: (NSString*) instanceId;
+ (uint8_t*) getBytesFromInstance: (NSString*) instanceId;
+ (NSArray*) getTagsFromBytes: (uint8_t*) bytes totalBytes: (int) bytesCount;

@end

@implementation BRRelutionTagMessage

- (id) initWithNamespaceUid:(NSString *)namespaceUid andTags: (NSArray*) tags {
    return [self initWithNamespaceUid:namespaceUid andInstanceId:[BRRelutionTagMessage getInstanceIdFromTags:tags]];
}

- (id) initWithNamespaceUid:(NSString *)namespaceUid andTags: (NSArray*) tags andTxPower: (int) txPower {
    return [self initWithNamespaceUid:namespaceUid andInstanceId:[BRRelutionTagMessage getInstanceIdFromTags:tags] andTxPower:txPower];
}

- (id) initWithNamespaceUid:(NSString *)namespaceUid andTags: (NSArray*) tags andTxPower: (int) txPower andRssi: (int) rssi {
    return [self initWithNamespaceUid:namespaceUid andInstanceId:[BRRelutionTagMessage getInstanceIdFromTags:tags] andTxPower:txPower andRssi:rssi];
}

- (id) initWithNamespaceUid:(NSString *)namespaceUid andInstanceId:(NSString *)instanceId {
    return [self initWithNamespaceUid:namespaceUid andInstanceId:instanceId andTxPower:-60];
}

- (id) initWithNamespaceUid: (NSString* ) namespaceUid andInstanceId: (NSString*) instanceId andTxPower: (int) txPower {
    return [self initWithNamespaceUid:namespaceUid andInstanceId:instanceId andTxPower:txPower andRssi:-55];
}

- (id) initWithNamespaceUid: (NSString* ) namespaceUid andInstanceId: (NSString*) instanceId andTxPower: (int) txPower andRssi: (int) rssi {
    if (self = [super initWithNamespaceUid:namespaceUid andInstanceId:instanceId andTxPower:txPower andRssi:rssi]) {
        
    }
    return self;
}

+ (NSString*) getInstanceIdFromTags: (NSArray*) tags {
    int numBytes = (int)[tags count] * 2;
    uint8_t* bytes = [self getBytesFromTags:tags];
    NSString* identifier = [self getHexStringFromBytes:bytes andStartByte:0 andLength:numBytes];
    return identifier;
}

+ (uint8_t*) getBytesFromTags: (NSArray*) tags {
    @try {
        int numBytes = (int)[tags count] * 2;
        uint8_t* resultBytes = (uint8_t*)malloc(numBytes);
        for (int i = 0;i < [tags count]; i++) {
            int tag = [[tags objectAtIndex:i] intValue];
            resultBytes[i*2+0] = (uint8_t)((tag & 0x0000ff00) >> 8);
            resultBytes[i*2+1] = (uint8_t)((tag & 0x000000ff) >> 0);
        }
        return resultBytes;
    } @catch (NSException* e) {
        @throw [NSException exceptionWithName:@"Tag list cannot be converted. " reason:@"" userInfo:nil];
    }
}

- (NSArray*) tags {
    return [BRRelutionTagMessage getTagsFromInstanceId:self->_instanceId];
}

+ (NSArray*) getTagsFromInstanceId: (NSString*) instanceId {
    NSString* instance = [instanceId uppercaseString];
    uint8_t* bytes = [BRRelutionTagMessage getBytesFromInstance:instance];
    int bytesCount = (int)instance.length / 2;
    NSArray* tags = [BRRelutionTagMessage getTagsFromBytes:bytes totalBytes: bytesCount];
    return tags;
}

+ (uint8_t*) getBytesFromInstance: (NSString*) instanceId {
    NSData* data = [BRByteArrayConverter dataFromHexString:instanceId];
    uint8_t* bytes = (uint8_t*)[data bytes];
    return bytes;
}

+ (NSArray*) getTagsFromBytes: (uint8_t*) bytes totalBytes: (int) bytesCount {
    NSMutableArray* tags = [[NSMutableArray alloc] init];
    for (int i = 0; i < bytesCount; i++) {
        uint8_t b1 = bytes[i+0];
        uint8_t b2 = bytes[i+1];
        int tag = (b1 << 8) + (b2 << 0);
        // Tag 0 is interpreted as padding.
        if (tag != 0) {
            [tags addObject:[NSNumber numberWithInt:tag]];
        }
        i++;
    }
    return tags;
}

- (NSString *) getDescription {
    NSMutableString *outputString = [NSMutableString stringWithFormat:@"RelutionTagMessageV2: tags = "];
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
    BRRelutionTagMessage *clonedMessage = [[BRRelutionTagMessage alloc]
                                           initWithNamespaceUid:self.namespaceUid
                                           andInstanceId:self.instanceId
                                           andTxPower:self.txPower
                                           andRssi:self.rssi];
    return clonedMessage;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    BRRelutionTagMessage *newMessage = [super copyWithZone:zone];
    newMessage->_tags = [self.tags copyWithZone:zone];
    return newMessage;
}

@end
