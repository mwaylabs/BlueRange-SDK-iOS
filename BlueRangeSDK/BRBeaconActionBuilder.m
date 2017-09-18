//
//  BRBeaconActionBuilder.m
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

#import "BRBeaconActionBuilder.h"
#import "BRBeaconAction.h"
#import "BRAbstract.h"
#import "BRJsonUtils.h"

@interface BRBeaconActionBuilder()

- (void) addCommonParametersOfJsonObject: (NSDictionary*) jsonActionObject toAction: (BRBeaconAction*) action;
- (void) addActionIdParameterOfJsonObject: (NSDictionary*) jsonActionObject toAction: (BRBeaconAction*) action;
- (void) addValidityBeginsParameterOfJsonObject: (NSDictionary*) jsonActionObject toAction: (BRBeaconAction*) action;
- (void) addValidUntilParameterOfJsonObject: (NSDictionary*) jsonActionObject toAction: (BRBeaconAction*) action;
- (void) addRepeatEveryParameterOfJsonObject: (NSDictionary*) jsonActionObject toAction: (BRBeaconAction*) action;
- (void) addDistanceThresholdParameterOfJsonObject: (NSDictionary*) jsonActionObject toAction: (BRBeaconAction*) action;

@end

@implementation BRBeaconActionBuilder

- (id) init {
    if (self = [super init]) {
        self->_successor = nil;
    }
    return self;
}

- (void) addChainElement: (BRBeaconActionBuilder*) chainElement {
    if (self->_successor == nil) {
        self->_successor = chainElement;
    } else {
        [self->_successor addChainElement:chainElement];
    }
}

- (BRBeaconAction*) createActionFromJSON: (NSDictionary*) jsonActionObject andMessage: (BRBeaconMessage*) message {
    BRBeaconAction *action = [self createActionFromJSONIfPossible:jsonActionObject andMessage:message];
    if (action == nil) {
        if (self->_successor != nil) {
            action = [self->_successor createActionFromJSON:jsonActionObject andMessage:message];
        }
    }
    // Besides the action specific parameters, we also add common parameters.
    [self addCommonParametersOfJsonObject: jsonActionObject toAction: action];
    return action;
}

- (void) addCommonParametersOfJsonObject: (NSDictionary*) jsonActionObject toAction: (BRBeaconAction*) action {
    [self addActionIdParameterOfJsonObject:jsonActionObject toAction:action];
    [self addValidityBeginsParameterOfJsonObject:jsonActionObject toAction:action];
    [self addValidUntilParameterOfJsonObject:jsonActionObject toAction:action];
    [self addRepeatEveryParameterOfJsonObject:jsonActionObject toAction:action];
    [self addDistanceThresholdParameterOfJsonObject:jsonActionObject toAction:action];
}

- (void) addActionIdParameterOfJsonObject: (NSDictionary*) jsonActionObject toAction: (BRBeaconAction*) action {
    @try {
        NSString* actionId = [BRJsonUtils getJsonValueForKey:ACTION_ID_PARAMETER andDictionary:jsonActionObject];
        action.actionId = actionId;
    }
    @catch (BRJSONException *exception) {
        // We just take the default values, whenever parameters do
        // not exist or may be corrupt.
    }
}

- (void) addValidityBeginsParameterOfJsonObject: (NSDictionary*) jsonActionObject toAction: (BRBeaconAction*) action {
    @try {
        NSNumber *postponeNumber = [BRJsonUtils getJsonValueForKey:POSTPONE_PARAMETER andDictionary:jsonActionObject];
        NSTimeInterval postpone = [postponeNumber doubleValue];
        NSTimeInterval nowInMs = [[NSDate date] timeIntervalSince1970];
        NSDate *validityBegins = [NSDate dateWithTimeIntervalSince1970:(nowInMs + postpone)];
        action.validityBegins = validityBegins;
    }
    @catch (BRJSONException *exception) {
        // We just take the default values, whenever parameters do
        // not exist or may be corrupt.
    }
}

- (void) addValidUntilParameterOfJsonObject: (NSDictionary*) jsonActionObject toAction: (BRBeaconAction*) action {
    @try {
        NSNumber *validUntilNumber = [BRJsonUtils getJsonValueForKey:VALID_UNTIL_PARAMETER andDictionary:jsonActionObject];
        NSTimeInterval validUntil = [validUntilNumber doubleValue];
        NSTimeInterval nowInMs = [[NSDate date] timeIntervalSince1970];
        NSDate *validityEnds = [NSDate dateWithTimeIntervalSince1970:(nowInMs + validUntil)];
        action.validityEnds = validityEnds;
    }
    @catch (BRJSONException *exception) {
        // We just take the default values, whenever parameters do
        // not exist or may be corrupt.
    }
}

- (void) addRepeatEveryParameterOfJsonObject: (NSDictionary*) jsonActionObject toAction: (BRBeaconAction*) action {
    @try {
        NSNumber *repeatEveryNumber = [BRJsonUtils getJsonValueForKey:REPEAT_EVERY_PARAMETER andDictionary:jsonActionObject];
        long repeatEveryInMs = [repeatEveryNumber longValue];
        // We only want to enable action locking, if repeatEveryInMs > 0
        if (repeatEveryInMs > 0) {
            action.isLockingAction = true;
            action.releaseLockAfterMs = repeatEveryInMs;
        }
    }
    @catch (BRJSONException *exception) {
        // We just take the default values, whenever parameters do
        // not exist or may be corrupt.
    }
}

- (void) addDistanceThresholdParameterOfJsonObject: (NSDictionary*) jsonActionObject toAction: (BRBeaconAction*) action {
    @try {
        NSNumber *distanceThresholdNumber = [BRJsonUtils getJsonValueForKey:DISTANCE_THRESHOLD_PARAMETER andDictionary:jsonActionObject];
        int distanceThreshold = [distanceThresholdNumber intValue];
        action.distanceThreshold = distanceThreshold;
    }
    @catch (BRJSONException *exception) {
        // We just take the default values, whenever parameters do
        // not exist or may be corrupt.
    }
}

// Protected methods
- /* abstract */ (BRBeaconAction*) createActionFromJSONIfPossible: (NSDictionary*) jsonActionObject andMessage: (BRBeaconMessage*) message {
    mustOverride();
}

@end
