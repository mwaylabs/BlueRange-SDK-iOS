//
//  BRRelutionTagInfoRegistryImpl.m
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

#import "BRRelutionTagInfoRegistryImpl.h"
#import "BRRelutionTagInfoRegistry.h"
#import "BRTracer.h"
#import "BRBeaconMessageScannerConfig.h"
#import "BRIBeaconMessageScanner.h"
#import "BRBeaconMessageScanner.h"
#import "BRNetwork.h"
#import "BRJsonUtils.h"
#import "BRRelutionTagInfo.h"
#import "BRRelution.h"

// Private BRConstants
NSString* const RELUTION_TAG_INFO_REGISTRY_IMPL_LOG_TAG = @"BRRelutionTagInfoRegistryImpl";
const long WAIT_TIME_BETWEEN_UUID_REGISTRY_SYNCHRONIZATIONS_IN_MS = 10000L; // 10 seconds
NSString const * RELUTION_TAGS_ENDPOINT_URL = @"/tags";

// Private methods
@interface BRRelutionTagInfoRegistryImpl()

- (void) continuouslyUpdateRegistryInThread;
- (void) tryLoadingRegistry;
- (void) waitUntilNextSynchronization;
- (NSMutableDictionary*) parseJsonObject: (NSArray*) jsonObject;

@end

@implementation BRRelutionTagInfoRegistryImpl

- (id) initWithRelution: (BRRelution*) relution andScanner: (BRIBeaconMessageScanner*) scanner {
    if (self = [super init]) {
        self->_tracer = [BRTracer getInstance];
        self->_updateThread = nil;
        self->_relution = relution;
        self->_tagToInfo = [[NSMutableDictionary alloc] init];
        self->_scanner = scanner;
    }
    return self;
}

- /* override */ (void) continuouslyUpdateRegistry {
    self->_updateThread = [[NSThread alloc] initWithTarget:self selector:@selector(continuouslyUpdateRegistryInThread) object:nil];
    [self->_updateThread start];
}

- (void) continuouslyUpdateRegistryInThread {
    while (![self->_updateThread isCancelled]) {
        [self tryLoadingRegistry];
        [self waitUntilNextSynchronization];
    }
}

- (void) tryLoadingRegistry {
    @try {
        if (![self->_relution isServerAvailable]) {
            [self->_tracer logWarningWithTag:RELUTION_TAG_INFO_REGISTRY_IMPL_LOG_TAG andMessage:@"Server is not available!"];
            return;
        }
        BRRelutionTagInfos* tagInfos = [self->_relution getRelutionTagInfos];
        self->_tagToInfo = [self parseJsonObject:[tagInfos jsonArray]];
        NSString *logMessage = [NSString stringWithFormat:@"Received BRRelution Tag list: %@", self->_tagToInfo.allKeys];
        [self->_tracer logDebugWithTag:RELUTION_TAG_INFO_REGISTRY_IMPL_LOG_TAG andMessage:logMessage];
    } @catch (BRRelutionTagInfoRegistryNotAvailable* e) {
        [self->_tracer logWarningWithTag:RELUTION_TAG_INFO_REGISTRY_IMPL_LOG_TAG andMessage:@"BRRelution tag registry not available!"];
    }
}

- (void) waitUntilNextSynchronization {
    [NSThread sleepForTimeInterval:((double)WAIT_TIME_BETWEEN_UUID_REGISTRY_SYNCHRONIZATIONS_IN_MS) / 1000];
}

- (NSMutableDictionary*) parseJsonObject: (NSArray*) results {
    NSMutableDictionary* __autoreleasing mapping = [[NSMutableDictionary alloc] init];
    @try {
        for (int i = 0; i < [results count];i++) {
            NSDictionary* result = [BRJsonUtils getJsonValueAtIndex:i forArray:results];
            long ID = [[BRJsonUtils getJsonValueForKey:@"id" andDictionary:result] longValue];
            NSString* name = [BRJsonUtils getJsonValueForKey:@"name" andDictionary:result];
            NSString* description = [BRJsonUtils getJsonValueForKey:@"description" andDictionary:result];
            BRRelutionTagInfo *relutionTagInfo = [[BRRelutionTagInfo alloc] init];
            [relutionTagInfo setId:ID];
            [relutionTagInfo setName:name];
            [relutionTagInfo setDescr:description];
            [mapping setObject:relutionTagInfo forKey:[NSNumber numberWithLong:ID]];
        }
        
    } @catch (BRJSONException* e) {
        @throw [BRRelutionTagInfoRegistryNotAvailable
                exceptionWithName:@"Could not parse JSON object of BRRelution Tag Registry." reason:@"" userInfo:nil];
    }
    return mapping;
}

- /* override */ (void) stopUpdatingRegistry {
    [self->_updateThread cancel];
}

- /* override */ (BRRelutionTagInfo*) getRelutionTagInfoForTag: (long) tag {
    BRRelutionTagInfo *relutionTagInfo = [self->_tagToInfo objectForKey:[NSNumber numberWithLong:tag]];
    if (relutionTagInfo == nil) {
        @throw [BRRelutionTagInfoRegistryNoInfoFound exceptionWithName:@"BRRelutionTagInfoRegistryNoInfoFound" reason:@"" userInfo:nil];
    }
    return relutionTagInfo;
}

@end
