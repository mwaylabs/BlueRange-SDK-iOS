//
//  BRBeaconNotificationExecutor.m
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

#import <UIKit/UIKit.h>
#import "BRBeaconNotificationExecutor.h"
#import "BRBeaconNotificationAction.h"
#import "BRBeaconNotificationListener.h"

// Private class variables
long VIBRATION_DURATION_IN_MS = 500L;

// Private methods
@interface BRBeaconNotificationExecutor()

- (void) execute: (BRBeaconNotificationAction*) notificationAction;
- (void) notifiyListeners: (BRBeaconNotificationAction*) action;

@end

@implementation BRBeaconNotificationExecutor

- (id) init {
    if (self = [super init]) {
        self->_listeners = [[NSMutableArray alloc] init];
    }
    return self;
}

- /* protected override */ (void) executeActionIfPossible: (BRBeaconAction* ) action {
    if ([action isKindOfClass:[BRBeaconNotificationAction class]]) {
        BRBeaconNotificationAction* notificationAction = (BRBeaconNotificationAction*)action;
        [self execute:notificationAction];
        [self notifiyListeners:notificationAction];
    }
}

- (void) execute: (BRBeaconNotificationAction*) notificationAction {
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    localNotification.alertTitle = @"BlueRange";
    localNotification.alertBody = notificationAction.content;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

- (void) notifiyListeners: (BRBeaconNotificationAction*) action {
    for (id<BRBeaconNotificationListener> listener in self->_listeners) {
        [listener onNotificationActionTriggered:action];
    }
}

- /* protected override */ (BOOL) addListenerIfPossible: (NSObject<BRBeaconActionListener>*) listener {
    if (!([listener conformsToProtocol:@protocol(BRBeaconNotificationListener)])) {
        return false;
    }
    id<BRBeaconNotificationListener> notificationActionListener = (id<BRBeaconNotificationListener>)listener;
    [self->_listeners addObject:notificationActionListener];
    return true;
}

- /* protected override */ (BOOL) removeListenerIfPossible: (NSObject<BRBeaconActionListener>*) listener {
    if (!([listener conformsToProtocol:@protocol(BRBeaconNotificationListener)])) {
        return false;
    }
    id<BRBeaconNotificationListener> notificationActionListener = (id<BRBeaconNotificationListener>)listener;
    [self->_listeners removeObject:notificationActionListener];
    return true;
}

@end
