//
//  BRBeaconNotificationActionBuilder.m
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

#import "BRBeaconNotificationActionBuilder.h"
#import "BRBeaconAction.h"
#import "BRBeaconNotificationAction.h"
#import "BRJsonUtils.h"

@implementation BRBeaconNotificationActionBuilder

- (id) init {
    if (self = [super init]) {
        
    }
    return self;
}

- /* protected override */ (BRBeaconAction*) createActionFromJSONIfPossible: (NSDictionary*) jsonActionObject andMessage: (BRBeaconMessage*) message {
    NSString *actionType = [BRJsonUtils getJsonValueForKey:TYPE_PARAMETER andDictionary:jsonActionObject];
    if ([actionType isEqualToString:TYPE_VARIABLE_NOTIFICATION]) {
        BRBeaconNotificationAction *notificationAction = [[BRBeaconNotificationAction alloc] init];
        NSString *content = [BRJsonUtils getJsonValueForKey:NOTIFICATION_CONTENT_PARAMETER andDictionary:jsonActionObject];
        notificationAction.content = content;
        if ([jsonActionObject objectForKey:ICON_PARAMETER] != nil) {
            NSString *iconUrl = [BRJsonUtils getJsonValueForKey:ICON_PARAMETER andDictionary:jsonActionObject];
            notificationAction.iconUrl = iconUrl;
        }
        return notificationAction;
    } else {
        return nil;
    }
}

@end
