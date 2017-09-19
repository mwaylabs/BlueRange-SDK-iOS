//
//  BRBeaconTagActionExecutor.m
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

#import "BRBeaconTagActionExecutor.h"
#import "BRBeaconTagAction.h"
#import "BRBeaconTagActionListener.h"

@interface BRBeaconTagActionExecutor()

- (void) execute: (BRBeaconTagAction*) tagAction;

@end

@implementation BRBeaconTagActionExecutor

- (id) init {
    if (self = [super init]) {
        self->_listeners = [[NSMutableArray alloc] init];
    }
    return self;
}

- /* protected override */ (void) executeActionIfPossible: (BRBeaconAction* ) action {
    if ([action isKindOfClass:[BRBeaconTagAction class]]) {
        BRBeaconTagAction *tagAction = (BRBeaconTagAction*)action;
        [self execute:tagAction];
    }
}

- (void) execute: (BRBeaconTagAction*) tagAction {
    // Notify all listeners.
    for (id<BRBeaconTagActionListener> listener in self->_listeners) {
        [listener onTagVisited:tagAction];
    }
}

- /* protected override */ (BOOL) addListenerIfPossible: (NSObject<BRBeaconActionListener>*) listener {
    if (!([listener conformsToProtocol:@protocol(BRBeaconTagActionListener)])) {
        return false;
    }
    id<BRBeaconTagActionListener> tagActionListener = (id<BRBeaconTagActionListener>)listener;
    [self->_listeners addObject:tagActionListener];
    return true;
}

- /* protected override */ (BOOL) removeListenerIfPossible: (NSObject<BRBeaconActionListener>*) listener {
    if (!([listener conformsToProtocol:@protocol(BRBeaconTagActionListener)])) {
        return false;
    }
    id<BRBeaconTagActionListener> tagActionListener = (id<BRBeaconTagActionListener>)listener;
    [self->_listeners removeObject:tagActionListener];
    return true;
}

@end
