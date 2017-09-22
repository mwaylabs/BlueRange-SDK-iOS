//
//  BRRelutionTagInfoRegistryStub.m
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

#import "BRRelutionTagInfoRegistryStub.h"
#import "BRRelutionTagInfo.h"

@implementation BRRelutionTagInfoRegistryStub

- (id) init {
    if (self = [super init]) {
        self->_tagInfoMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- /* override */ (void) continuouslyUpdateRegistry {
    [self->_tagInfoMap
        setObject:[[BRRelutionTagInfo alloc] initWithId:1 andName:@"name1" andDescription:@"description1"] forKey:[NSNumber numberWithLong:1L]];
    [self->_tagInfoMap
     setObject:[[BRRelutionTagInfo alloc] initWithId:2 andName:@"name2" andDescription:@"description2"] forKey:[NSNumber numberWithLong:2L]];
}

- /* override */ (void) stopUpdatingRegistry {
    // Nothing has to be done.
}

- /* override */ (BRRelutionTagInfo*) getRelutionTagInfoForTag: (long) tag {
    BRRelutionTagInfo* relutionTagInfo = [self->_tagInfoMap objectForKey:[NSNumber numberWithLong:tag]];
    if (relutionTagInfo == nil) {
        @throw [BRRelutionTagInfoRegistryNoInfoFound exceptionWithName:@"BRRelutionTagInfoRegistryNoInfoFound" reason:@"" userInfo:nil];
    }
    return relutionTagInfo;
}

@end
