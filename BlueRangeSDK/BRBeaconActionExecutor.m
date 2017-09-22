//
//  BRBeaconActionExecutor.m
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

#import "BRBeaconActionExecutor.h"
#import "BRAbstract.h"

@implementation BRBeaconActionExecutor

- (id) init {
    if (self = [super init]) {
        self->_successor = nil;
    }
    return self;
}

- (void) addChainElement: (BRBeaconActionExecutor *) chainElement {
    if (self->_successor == nil) {
        self->_successor = chainElement;
    } else {
        [self->_successor addChainElement:chainElement];
    }
}

- (void) executeAction: (BRBeaconAction*) action {
    [self executeActionIfPossible:action];
    // Each handler should have the chance to execute an action,
    // since more than one action could be contained inside the action information.
    if (self->_successor != nil) {
        [self->_successor executeAction:action];
    }
}

- /* protected abstract */ (void) executeActionIfPossible: (BRBeaconAction* ) action {
    mustOverride();
}

- (void) addListener: (NSObject<BRBeaconActionListener>*) listener {
    [self addListenerIfPossible:listener];
    if (self->_successor != nil) {
        [self->_successor addListener:listener];
    }
}

- /* protected abstract */ (BOOL) addListenerIfPossible: (NSObject<BRBeaconActionListener>*) listener {
    mustOverride();
}

- (void) removeListener: (NSObject<BRBeaconActionListener>*) listener {
    [self removeListenerIfPossible:listener];
    if (self->_successor != nil) {
       [self->_successor addListener:listener];
    }
}

- /* protected abstract */ (BOOL) removeListenerIfPossible: (NSObject<BRBeaconActionListener>*) listener {
    mustOverride();
}

@end
