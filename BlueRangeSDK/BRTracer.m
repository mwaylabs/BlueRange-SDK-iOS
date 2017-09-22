//
//  BRTracer.m
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

#import "BRTracer.h"
#import "BRConstants.h"

@implementation BRTracer

static BOOL enabled = true;

// Singleton implementation
+ (BRTracer *) getInstance {
    static BRTracer *tracer = nil;
    @synchronized(self) {
        if (tracer == nil)
            tracer = [[self alloc] init];
    }
    return tracer;
}

+ (BOOL) isEnabled {
    return enabled;
}

+ (void) setEnabled: (BOOL) _enabled {
    enabled = _enabled;
}

- (id) init {
    if (self = [super init]) {
    }
    return self;
}

- (void) logInfoWithTag: (NSString *) tag andMessage: (NSString *) message {
    if (enabled) {
        NSString* completeLogTag = [self getCompleteLogTag:tag];
        NSLog(@"%@:%@", completeLogTag, message);
    }
}

- (void) logDebugWithTag: (NSString *) tag andMessage: (NSString *) message {
    if (enabled) {
        NSString* completeLogTag = [self getCompleteLogTag:tag];
        NSLog(@"%@:%@", completeLogTag, message);
    }
}

- (void) logWarningWithTag: (NSString *) tag andMessage: (NSString *) message {
    if (enabled) {
        NSString* completeLogTag = [self getCompleteLogTag:tag];
        NSLog(@"%@:%@", completeLogTag, message);
    }
}

- (void) logErrorWithTag: (NSString *) tag andMessage: (NSString *) message {
    if (enabled) {
        NSString* completeLogTag = [self getCompleteLogTag:tag];
        NSLog(@"%@:%@", completeLogTag, message);
    }
}

- (NSString*) getCompleteLogTag: (NSString*) logTag {
     NSString *completeLogTag = [NSString stringWithFormat:@"%@:%@", TAG, logTag];
    return completeLogTag;
}

@end
