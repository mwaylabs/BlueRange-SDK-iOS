//
//  BRIBeaconMessageActionMapperStub.m
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

#import "BRIBeaconMessageActionMapperStub.h"
#import "BRIBeacon.h"
#import "BRJsonUtils.h"
#import "BRRelutionActionInformation.h"
#import "BRIBeaconMessage.h"
#import "BRBeaconActionRegistry.h"
#import "BRBeaconAction.h"
#import "BRBeaconContentAction.h"
#import "BRBeaconNotificationAction.h"
#import "BRBeaconTagAction.h"

// Private methods
@interface BRIBeaconMessageActionMapperStub()

- (void) initIBeaconActionMap;
- (NSDictionary*) addContentActionNotExpired: (BRIBeacon*) iBeacon;
- (NSDictionary*) addNotificationAction: (BRIBeacon*) iBeacon;
- (NSDictionary*) addContentActionWithExpiredValidity: (BRIBeacon*) iBeacon;
- (NSDictionary*) addContentActionWithDelayedValidity: (BRIBeacon*) iBeacon;
- (NSDictionary*) addContentActionWithMissingParameters: (BRIBeacon*) iBeacon;
- (NSDictionary*) addContentActionWithHighRepeatEveryParameter: (BRIBeacon*) iBeacon;
- (NSDictionary*) addDelayedNotificationAction: (BRIBeacon*) iBeacon;
- (NSDictionary*) addLockedNotificationAction: (BRIBeacon*) iBeacon;
- (NSDictionary*) addContentActionWithLowRepeatEveryParameter: (BRIBeacon*) iBeacon;
- (NSDictionary*) addContentActionWithHighDistanceThreshold: (BRIBeacon*) iBeacon;
- (NSDictionary*) addContentActionWithNoSpecifiedDistanceThreshold: (BRIBeacon*) iBeacon;
- (NSDictionary*) addTagActionWithCheckoutTag: (BRIBeacon*) iBeacon;
- (NSDictionary*) addTagActionWithFoyerTag: (BRIBeacon*) iBeacon;
- (NSDictionary*) addContentActionWithExpiredCampaign: (BRIBeacon*) iBeacon;
- (NSDictionary*) addContentActionWithInactiveCampaign: (BRIBeacon*) iBeacon;
- (NSDictionary*) addTwoContentActionsInDifferentCampaigns: (BRIBeacon*) iBeacon;
- (NSDictionary*) addTagActionWithFruitsAndVegetablesTag: (BRIBeacon*) iBeacon;
- (NSDictionary*) addContentActionWithHTMLContent: (BRIBeacon*) iBeacon;
- (NSDictionary*) addNotificationActionWithHighDistanceThreshold: (BRIBeacon*) iBeacon;
- (NSDictionary*) addContentActionWithLongDelayedValidity: (BRIBeacon*) iBeacon;
- (NSDictionary*) addContentActionWithLockAndDelay: (BRIBeacon*) iBeacon;

@end

@implementation BRIBeaconMessageActionMapperStub

- (id) init {
    if (self = [super init]) {
        self->_iBeaconActionMap = [[NSMutableDictionary alloc] init];
        self->_corruptJsonResponses = false;
        [self initIBeaconActionMap];
    }
    return self;
}

- (void) initIBeaconActionMap {
    int major = 45;
    int minor = 1;
    @try {
        [self addContentActionNotExpired:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addNotificationAction:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"c9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addContentActionWithExpiredValidity:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"d9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addContentActionWithDelayedValidity:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"e9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addContentActionWithMissingParameters:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"f9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addContentActionWithHighRepeatEveryParameter:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"09407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addDelayedNotificationAction:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"19407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addLockedNotificationAction:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"29407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addContentActionWithLowRepeatEveryParameter:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"39407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addContentActionWithHighDistanceThreshold:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"49407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addContentActionWithNoSpecifiedDistanceThreshold:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"59407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addTagActionWithCheckoutTag:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"69407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addTagActionWithFoyerTag:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"79407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addContentActionWithExpiredCampaign:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"89407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addContentActionWithInactiveCampaign:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"99407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addTwoContentActionsInDifferentCampaigns:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"91407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addTagActionWithFruitsAndVegetablesTag:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"92407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addContentActionWithHTMLContent:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"93407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addNotificationActionWithHighDistanceThreshold:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"94407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addContentActionWithLongDelayedValidity:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"95407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
        [self addContentActionWithLockAndDelay:[[BRIBeacon alloc]
                                          initWithUuid:[[NSUUID alloc] initWithUUIDString:@"96407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:major andMinor:minor]];
    } @catch (BRJSONException* e) {
        
    }
}

- /* override */ (BRRelutionActionInformation*) getBeaconActionInformationForMessage: (BRIBeaconMessage*) message {
    BRRelutionActionInformation* actionInformation = [[BRRelutionActionInformation alloc] init];
    BRIBeacon* iBeacon = message.iBeacon;
    NSDictionary* jsonObject = [self->_iBeaconActionMap objectForKey:iBeacon];
    // If iBeacon does not exist, just throw an exception.
    if (jsonObject == nil) {
        @throw [BRUnsupportedMessageException exceptionWithName:@"unsupported message" reason:@"" userInfo:nil];
    }
    if (self->_corruptJsonResponses) {
        // Empty json object is a corrupt json object.
        jsonObject = [[NSMutableDictionary alloc] init];
    }
    //NSString* jsonString = [BRJsonUtils jsonStringForDictionary:jsonObject];
    //NSDictionary* result = [BRJsonUtils getJsonFromString:[BRJsonUtils jsonStringForDictionary:jsonObject]];
    [actionInformation setActionInformationObject:jsonObject];
    return actionInformation;
}

- (NSDictionary*) addContentActionNotExpired: (BRIBeacon*) iBeacon {
    NSMutableDictionary* jsonObject = [[NSMutableDictionary alloc] init];
    NSMutableArray *actionsArray = [[NSMutableArray alloc] init];
    NSMutableDictionary* contentActionObject = [[NSMutableDictionary alloc] init];
    [contentActionObject setObject:[[NSUUID UUID] UUIDString] forKey:ACTION_ID_PARAMETER];
    [contentActionObject setObject:TYPE_VARIABLE_CONTENT forKey:TYPE_PARAMETER];
    [contentActionObject setObject:@"testContent" forKey:CONTENT_PARAMETER];
    [contentActionObject setObject:[NSNumber numberWithInt:0] forKey:POSTPONE_PARAMETER];
    [contentActionObject setObject:[NSNumber numberWithInt:1000] forKey:VALID_UNTIL_PARAMETER];
    [actionsArray addObject:contentActionObject];
    [self addDefaultCampaign:jsonObject andActions:actionsArray];
    [self->_iBeaconActionMap setObject:jsonObject forKey:iBeacon];
    return jsonObject;
}

- (NSDictionary*) addNotificationAction: (BRIBeacon*) iBeacon {
    NSMutableDictionary* jsonObject = [[NSMutableDictionary alloc] init];
    NSMutableArray* actionsArray = [[NSMutableArray alloc] init];
    NSMutableDictionary* notificationActionObject = [[NSMutableDictionary alloc] init];
    [notificationActionObject setObject:[[NSUUID UUID] UUIDString] forKey:ACTION_ID_PARAMETER];
    [notificationActionObject setObject:TYPE_VARIABLE_NOTIFICATION forKey:TYPE_PARAMETER];
    [notificationActionObject setObject:@"testTitle" forKey:CONTENT_PARAMETER];
    [notificationActionObject setObject:@"http://www.mwaysolutions.com/wp-content/media/2015/12/favicon.ico" forKey:ICON_PARAMETER];
    [notificationActionObject setObject:[NSNumber numberWithDouble:MIN_VALIDITY_BEGINS] forKey:POSTPONE_PARAMETER];
    [notificationActionObject setObject:[NSNumber numberWithDouble:MAX_VALIDITY_ENDS] forKey:VALID_UNTIL_PARAMETER];
    [actionsArray addObject:notificationActionObject];
    [self addDefaultCampaign:jsonObject andActions:actionsArray];
    [self->_iBeaconActionMap setObject:jsonObject forKey:iBeacon];
    return jsonObject;
}

- (NSDictionary*) addContentActionWithExpiredValidity: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addContentActionWithDelayedValidity: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addContentActionWithMissingParameters: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addContentActionWithHighRepeatEveryParameter: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addDelayedNotificationAction: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addLockedNotificationAction: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addContentActionWithLowRepeatEveryParameter: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addContentActionWithHighDistanceThreshold: (BRIBeacon*) iBeacon {
    NSMutableDictionary* jsonObject = [[NSMutableDictionary alloc] init];
    NSMutableArray* actionsArray = [[NSMutableArray alloc] init];
    NSMutableDictionary* actionObject = [[NSMutableDictionary alloc] init];
    [actionObject setObject:[[NSUUID UUID] UUIDString] forKey:ACTION_ID_PARAMETER];
    [actionObject setObject:TYPE_VARIABLE_CONTENT forKey:TYPE_PARAMETER];
    [actionObject setObject:@"testDistance" forKey:CONTENT_PARAMETER];
    [actionObject setObject:[NSNumber numberWithDouble:MIN_VALIDITY_BEGINS] forKey:POSTPONE_PARAMETER];
    [actionObject setObject:[NSNumber numberWithDouble:MAX_VALIDITY_ENDS] forKey:VALID_UNTIL_PARAMETER];
    [actionObject setObject:[NSNumber numberWithInt:3] forKey:DISTANCE_THRESHOLD_PARAMETER];
    [actionsArray addObject:actionObject];
    [self addDefaultCampaign:jsonObject andActions:actionsArray];
    [self->_iBeaconActionMap setObject:jsonObject forKey:iBeacon];
    return jsonObject;
}

- (NSDictionary*) addContentActionWithNoSpecifiedDistanceThreshold: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addTagActionWithCheckoutTag: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addTagActionWithFoyerTag: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addContentActionWithExpiredCampaign: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addContentActionWithInactiveCampaign: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addTwoContentActionsInDifferentCampaigns: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addTagActionWithFruitsAndVegetablesTag: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addContentActionWithHTMLContent: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addNotificationActionWithHighDistanceThreshold: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addContentActionWithLongDelayedValidity: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- (NSDictionary*) addContentActionWithLockAndDelay: (BRIBeacon*) iBeacon {
    // Todo
    return nil;
}

- /* override */ (BOOL) isAvailable {
    // Sender is always available
    return true;
}

- (void) corruptJsons {
    self->_corruptJsonResponses = true;
}

@end
