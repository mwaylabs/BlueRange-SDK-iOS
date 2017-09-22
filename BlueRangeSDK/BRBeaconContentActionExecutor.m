//
//  BRBeaconContentActionExecutor.m
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

#import "BRBeaconContentActionExecutor.h"
#import "BRBeaconAction.h"
#import "BRBeaconContentAction.h"
#import "BRBeaconContentActionListener.h"

// Private methods
@interface BRBeaconContentActionExecutor()

- (void) execute: (BRBeaconContentAction*) contentAction;

@end

@implementation BRBeaconContentActionExecutor

- (id) init {
    if (self = [super init]) {
        self->_listeners = [[NSMutableArray alloc] init];
    }
    return self;
}

- /* protected override */ (void) executeActionIfPossible: (BRBeaconAction* ) action {
    if ([action isKindOfClass:[BRBeaconContentAction class]]) {
        BRBeaconContentAction *contentAction = (BRBeaconContentAction*)action;
        [self execute: contentAction];
    }
}

- (void) execute: (BRBeaconContentAction*) contentAction {
    for (id<BRBeaconContentActionListener> listener in self->_listeners) {
        [listener onActionTriggered:contentAction];
    }
}

- /* protected override */ (BOOL) addListenerIfPossible: (NSObject<BRBeaconActionListener>*) listener {
    if (!([listener conformsToProtocol:@protocol(BRBeaconContentActionListener)])) {
        return false;
    }
    id<BRBeaconContentActionListener> contentActionListener = (id<BRBeaconContentActionListener>)listener;
    [self->_listeners addObject:contentActionListener];
    return true;
}

- /* protected override */ (BOOL) removeListenerIfPossible: (NSObject<BRBeaconActionListener>*) listener {
    if (!([listener conformsToProtocol:@protocol(BRBeaconContentActionListener)])) {
        return false;
    }
    id<BRBeaconContentActionListener> contentActionListener = (id<BRBeaconContentActionListener>)listener;
    [self->_listeners removeObject:contentActionListener];
    return true;
}

@end
