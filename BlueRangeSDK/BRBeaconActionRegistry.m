//
//  BRBeaconActionRegistry.m
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
