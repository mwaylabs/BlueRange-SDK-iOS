//
//  BRBeaconNotificationActionBuilder.m
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
