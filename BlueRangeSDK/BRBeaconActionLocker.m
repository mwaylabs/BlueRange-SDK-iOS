//
//  BRBeaconActionLocker.m
//  BlueRangeSDK
//
// Copyright (c) 2016-2017, M-Way Solutions GmbH
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the M-Way Solutions GmbH nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY M-Way Solutions GmbH ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL M-Way Solutions GmbH BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
