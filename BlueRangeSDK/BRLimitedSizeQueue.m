//
//  BRLimitedSizeQueue.m
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

#import "BRLimitedSizeQueue.h"

@implementation BRLimitedSizeQueue

- (id) initWithMaxSize: (int) size {
    if (self = [super init]) {
        self->_maxSize = size;
        self->_array = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) addObject: (id) object {
    [self->_array addObject:object];
    if ([self->_array count] > self->_maxSize) {
       [self->_array removeObjectsInRange:(NSRange){0, [self->_array count] - self->_maxSize}];
    }
    
}

- (id) getYoungest {
    return [self->_array objectAtIndex:([self->_array count] - 1)];
}

- (id) getOldest {
    return [self->_array objectAtIndex:0];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [self->_array objectAtIndex:index];
}

- (NSUInteger) count {
    return [self->_array count];
}

- (NSMutableArray*) array {
    return self->_array;
}

@end
