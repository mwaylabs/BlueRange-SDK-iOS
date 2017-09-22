//
//  BRBeaconActionRegistry.m
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

#import "BRBeaconActionRegistry.h"
#import "BRIBeaconMessageActionMapper.h"
#import "BRRelutionTagMessageActionMapper.h"
#import "BRRelutionActionInformation.h"
#import "BRBeaconMessage.h"
#import "BRBeaconActionBuilder.h"
#import "BRBeaconContentActionBuilder.h"
#import "BRBeaconNotificationActionBuilder.h"
#import "BRBeaconTagActionBuilder.h"
#import "BRIBeaconMessage.h"
#import "BRRelutionTagMessage.h"
#import "BRJsonUtils.h"
#import "BRBeaconCampaign.h"
#import "BRITracer.h"
#import "BRBeaconCampaign.h"
#import "BRBeaconAction.h"

// Exception classes
@implementation BRUnsupportedMessageException : NSException
@end

@implementation BRRegistryNotAvailableException : NSException
@end

@implementation BRCorruptResponseException : NSException
@end

// Private methods
@interface BRBeaconActionRegistry()

- (void) initMappers: (id<BRIBeaconMessageActionMapper>) iBeaconMessageActionMapper
                 and: (id<BRRelutionTagMessageActionMapper>) relutionTagMessageActionMapper;
- (void) initBuilders;
- (BRRelutionActionInformation*) getActionInformationForMessage: (BRBeaconMessage* ) message;
- (NSMutableArray*) createActionsFromActionInformation: (BRRelutionActionInformation*) actionInformation andMessage: (BRBeaconMessage*) message;
- (void) addActionBuilder: (BRBeaconActionBuilder*) actionBuilder;

@end

// BRConstants
NSString * const BEACON_ACTION_REGISTRY_LOG_TAG = @"BRBeaconActionRegistry";

@implementation BRBeaconActionRegistry

- (id) initWithTracer: (id<BRITracer>) tracer andIBeaconMapper: (id<BRIBeaconMessageActionMapper>) iBeaconMessageActionMapper
 andRelutionTagMapper: (id<BRRelutionTagMessageActionMapper>) relutionTagMessageActionMapper {
    if (self = [super init]) {
        self->_tracer = tracer;
        self->_actionBuilderChain = nil;
        [self initMappers: iBeaconMessageActionMapper and:relutionTagMessageActionMapper];
        [self initBuilders];
    }
    return self;
}

- (void) initMappers: (id<BRIBeaconMessageActionMapper>) iBeaconMessageActionMapper
                 and: (id<BRRelutionTagMessageActionMapper>) relutionTagMessageActionMapper {
    self->_iBeaconMessageActionMapper = iBeaconMessageActionMapper;
    self->_relutionTagMessageActionMapper = relutionTagMessageActionMapper;
}

- (void) initBuilders {
    [self addActionBuilder:[[BRBeaconContentActionBuilder alloc] init]];
    [self addActionBuilder:[[BRBeaconNotificationActionBuilder alloc] init]];
    [self addActionBuilder:[[BRBeaconTagActionBuilder alloc] init]];
}

- (BOOL) isAvailable: (BRBeaconMessage*) message {
    if ([message isKindOfClass:[BRIBeaconMessage class]]) {
        return [self->_iBeaconMessageActionMapper isAvailable];
    } else if ([message isKindOfClass:[BRRelutionTagMessage class]]) {
        return [self->_relutionTagMessageActionMapper isAvailable];
    }
    @throw [BRUnsupportedMessageException exceptionWithName:@"Unsupported message exception" reason:@"" userInfo:nil];
}

- (NSMutableArray*) getBeaconActionsForMessage: (BRBeaconMessage*) message {
    // 1. Map message to action information
    BRRelutionActionInformation* actionInformation = [self getActionInformationForMessage:message];
    // 2. Build actions from action information.
    NSMutableArray* actions = [self createActionsFromActionInformation:actionInformation andMessage:message];
    return actions;
}

- (BRRelutionActionInformation*) getActionInformationForMessage: (BRBeaconMessage* ) message {
    BRRelutionActionInformation* actionInformation = nil;
    if ([message isKindOfClass:[BRIBeaconMessage class]]) {
        BRIBeaconMessage* iBeaconMessage = (BRIBeaconMessage*)message;
        actionInformation = [self->_iBeaconMessageActionMapper getBeaconActionInformationForMessage:iBeaconMessage];
    } else if ([message isKindOfClass:[BRRelutionTagMessage class]]) {
        BRRelutionTagMessage* relutionTagMessage = (BRRelutionTagMessage*)message;
        actionInformation = [self->_relutionTagMessageActionMapper getBeaconActionInformationForMessage:relutionTagMessage];
    } else {
        @throw [BRUnsupportedMessageException exceptionWithName:@"Unsupported message" reason:@"" userInfo:nil];
    }
    return actionInformation;
}

- (NSMutableArray*) createActionsFromActionInformation: (BRRelutionActionInformation*) actionInformation andMessage: (BRBeaconMessage*) message {
    NSMutableArray* actions = [[NSMutableArray alloc] init];
    @try {
        NSDictionary* jsonObject = actionInformation.actionInformationObject;
        NSArray* campaignsArray = [BRJsonUtils getJsonValueForKey:CAMPAIGNS_PARAMETER andDictionary:jsonObject];
        for (int i = 0; i < [campaignsArray count]; i++) {
            @try {
                // Create campaign
                NSDictionary* campaignObject = [BRJsonUtils getJsonValueAtIndex:i forArray:campaignsArray];
                NSTimeInterval begins = [[BRJsonUtils getJsonValueForKey:BEGINS_PARAMETER andDictionary:campaignObject] doubleValue]/1000;
                NSDate* beginsDate = [NSDate dateWithTimeIntervalSince1970:begins];
                NSTimeInterval ends = [[BRJsonUtils getJsonValueForKey:ENDS_PARAMETER andDictionary:campaignObject] doubleValue]/1000;
                NSDate* endsDate = [NSDate dateWithTimeIntervalSince1970:ends];
                BRBeaconCampaign* campaign = [[BRBeaconCampaign alloc] initWithBeginsDate:beginsDate andEndsDate:endsDate];
                
                // Crate actions
                NSArray* actionsArray = [BRJsonUtils getJsonValueForKey:ACTIONS_PARAMETER andDictionary:campaignObject];
                for (int j = 0; j < [actionsArray count]; j++) {
                    NSDictionary* actionObject = [BRJsonUtils getJsonValueAtIndex:j forArray:actionsArray];
                    BRBeaconAction* action = [self->_actionBuilderChain createActionFromJSON:actionObject andMessage:message];
                    [action setCampaign:campaign];
                    [action setSourceBeaconMessage:message];
                    [actions addObject:action];
                }
            }
            @catch (NSException *exception) {
                // If a campaign does not have actions, just skip it.
                [self->_tracer logDebugWithTag:BEACON_ACTION_REGISTRY_LOG_TAG andMessage:@"Skipped action, because response is corrupt!"];
            }
        }
    }
    @catch (NSException *exception) {
        @throw [BRCorruptResponseException exceptionWithName:@"Corrupt response" reason:@"" userInfo:nil];
    }
    return actions;
}

- (void) addActionBuilder: (BRBeaconActionBuilder*) actionBuilder {
    if (self->_actionBuilderChain == nil) {
        self->_actionBuilderChain = actionBuilder;
    } else {
        [self->_actionBuilderChain addChainElement:actionBuilder];
    }
}

@end
