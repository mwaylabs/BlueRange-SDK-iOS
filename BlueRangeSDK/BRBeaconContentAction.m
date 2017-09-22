//
//  BRBeaconContentAction.m
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

#import "BRBeaconContentAction.h"

@implementation BRBeaconContentAction

NSString* const TYPE_VARIABLE_CONTENT = @"HTML_CONTENT";
NSString* const CONTENT_PARAMETER = @"content";

- (id) init {
    if (self = [super init]) {
        self->_timestamp = [NSDate date];
    }
    return self;
}

- /* Override */ (NSString*) type {
    return @"content";
}

- /* Override */ (BRBeaconAction*) newCopy {
    BRBeaconContentAction* contentAction = [[BRBeaconContentAction alloc] init];
    contentAction->_timestamp = _timestamp;
    contentAction->_content = _content;
    return contentAction;
}

- /* Override */ (NSUInteger) hash {
    return [self->_timestamp hash] + [self->_content hash];
}

@end
