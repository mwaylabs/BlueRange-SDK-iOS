//
//  BRBeaconActionLocker.m
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

#import "BRBeaconActionLocker.h"
#import "BRBeaconAction.h"
#import "BRRunningFlag.h"

// Private methods
@interface BRBeaconActionLocker()

- (void) constantlyRemoveExpiredLocks;
- (void) releaseExpiredLocks;
- (void) waitAWhile;

@end

// BRConstants
const long POLLING_TIME_FOR_CHECKING_LOCKS_IN_MS = 500L;

@implementation BRBeaconActionLocker

- (id) initWithRunningFlag: (BRRunningFlag*) runningFlag {
    if (self = [super init]) {
        self->_runningFlag = runningFlag;
        self->_actionLocks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL) actionIsCurrentlyLocked: (BRBeaconAction*) action {
    // If at least one action exists, that is locked and has the same id,
    // the passed action is considered to be locked.
    @synchronized(self->_actionLocks) {
        for (BRBeaconAction *actionLock in self->_actionLocks) {
            BRBeaconAction *referenceAction = actionLock;
            if ([action.actionId isEqualToString:referenceAction.actionId]) {
                return true;
            }
        }
    }
    return false;
}

- (void) rememberLock: (BRBeaconAction*) action {
    // If at least one action exists, that is locked and has the same id,
    // the passed action is considered to be locked.
    @synchronized(self->_actionLocks) {
        for (BRBeaconAction* actionLock in self->_actionLocks) {
            BRBeaconAction* referenceAction = actionLock;
            if ([action.actionId isEqualToString:referenceAction.actionId]) {
                action.startLockDate = actionLock.startLockDate;
                action.lockReleaseDate = actionLock.lockReleaseDate;
            }
        }
    }
}

- (void) addActionLock: (BRBeaconAction*) action {
    // To lock an action, remember the release date
    // and save the action to the actionLocks list.
    @synchronized(self->_actionLocks) {
        // Remember the release date.
        NSDate *now = [NSDate date];
        NSTimeInterval nowInMs = [now timeIntervalSince1970];
        NSTimeInterval lockDurationInMs = [action releaseLockAfterMs];
        NSTimeInterval releaseLockDateInMs = nowInMs + lockDurationInMs;
        NSDate *releaseLockDate = [NSDate dateWithTimeIntervalSince1970:releaseLockDateInMs];
        action.startLockDate = [NSDate date];
        action.lockReleaseDate = releaseLockDate;
        // Add it to the list.
        [self->_actionLocks addObject:action];
    }
}

- /* override */ (void) main {
    [self constantlyRemoveExpiredLocks];
}

- (void) constantlyRemoveExpiredLocks {
    while ([self->_runningFlag running] && ![self isCancelled]) {
        // 1. Release expired locks.
        [self releaseExpiredLocks];
        // 2. Sleep a while
        [self waitAWhile];
    }
}

- (void) releaseExpiredLocks {
    // Check all action locks, whether they should be released.
    // Release them, if this is the case.
    @synchronized(self->_actionLocks) {
        NSMutableArray* discardedLocks = [[NSMutableArray alloc] init];
        for (BRBeaconAction* actionLock in self->_actionLocks) {
            if (actionLock.lockExpired) {
                [discardedLocks addObject:actionLock];
            }
        }
        [self->_actionLocks removeObjectsInArray:discardedLocks];
    }
}

- (void) waitAWhile {
    [NSThread sleepForTimeInterval:((double)POLLING_TIME_FOR_CHECKING_LOCKS_IN_MS) / 1000];
}

@end
