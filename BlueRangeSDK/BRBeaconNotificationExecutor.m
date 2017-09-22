//
//  BRBeaconNotificationExecutor.m
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
