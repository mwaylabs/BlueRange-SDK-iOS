//
//  BRBeaconActionBuilder.m
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
