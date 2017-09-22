//
//  BRBeaconTagAction.m
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

#import "BRBeaconTagAction.h"
#import "BRBeaconTagVisit.h"

@implementation BRBeaconTagAction

NSString* const TYPE_VARIABLE_VISITED = @"VISITED";
NSString* const TAG_CONTENT_PARAMTER = @"content";

- (id) initWithTagVisit: (BRBeaconTagVisit*) tagVisit {
    if (self = [super init]) {
        self->_tag = tagVisit;
    }
    return self;
}

- /* Override */ (NSString*) type {
    return @"visited";
}

- /* Override */ (BRBeaconAction*) newCopy {
    BRBeaconTagAction* tagAction = [[BRBeaconTagAction alloc] init];
    tagAction->_tag = _tag;
    return tagAction;
}

- /* Override */ (NSUInteger) hash {
    return [self.tag.tag hash] + [self.tag.timestamp hash];
}


@end
