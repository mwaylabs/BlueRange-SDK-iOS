//
//  BRBeaconMessageActionMapperStub.m
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

#import "BRBeaconMessageActionMapperStub.h"
#import "BRBeaconCampaign.h"

@implementation BRBeaconMessageActionMapperStub

- /* protected */ (void) addDefaultCampaign: (NSMutableDictionary*) jsonObject andActions: (NSMutableArray*) actionsArray {
    NSMutableDictionary *campaign = [self getDefaultCampaign:actionsArray];
    NSMutableArray *campaignArray = [[NSMutableArray alloc] init];
    [campaignArray addObject:campaign];
    [jsonObject setObject:campaignArray forKey:CAMPAIGNS_PARAMETER];
}

- /* protected */ (void) addExpiredCampaign: (NSMutableDictionary*) jsonObject andActions: (NSMutableArray*) actionsArray {
    NSMutableDictionary* campaign = [[NSMutableDictionary alloc] init];
    [campaign setObject:[NSNumber numberWithDouble: BEGINS_DEFAULT_VALUE] forKey:BEGINS_PARAMETER];
    // We want the campaign to be expired.
    [campaign setObject:[NSNumber numberWithDouble:0] forKey:ENDS_PARAMETER];
    [campaign setObject:actionsArray forKey:ACTIONS_PARAMETER];
    NSMutableArray* campaignArray = [[NSMutableArray alloc] init];
    [campaignArray addObject:campaign];
    [jsonObject setObject:campaignArray forKey:CAMPAIGNS_PARAMETER];
}

- /* protected */ (void) addInactiveCampaign: (NSMutableDictionary*) jsonObject andActions: (NSMutableArray*) actionsArray {
    NSMutableDictionary* campaign = [[NSMutableDictionary alloc] init];
    // We want the campaign to be inactive.
    [campaign setObject:[NSNumber numberWithDouble: BEGINS_DEFAULT_VALUE] forKey:BEGINS_PARAMETER];
    [campaign setObject:[NSNumber numberWithDouble: ENDS_DEFAULT_VALUE] forKey:ENDS_PARAMETER];
    [campaign setObject:actionsArray forKey:ACTIONS_PARAMETER];
    NSMutableArray* campaignArray = [[NSMutableArray alloc] init];
    [campaignArray addObject:campaign];
    [jsonObject setObject:campaignArray forKey:CAMPAIGNS_PARAMETER];
}

- /* protected */ (NSMutableDictionary*) getDefaultCampaign: (NSMutableArray*) actionsArray {
    NSMutableDictionary* campaign = [[NSMutableDictionary alloc] init];
    [campaign setObject:[NSNumber numberWithDouble: BEGINS_DEFAULT_VALUE] forKey:BEGINS_PARAMETER];
    [campaign setObject:[NSNumber numberWithDouble: ENDS_DEFAULT_VALUE] forKey:ENDS_PARAMETER];
    [campaign setObject:actionsArray forKey:ACTIONS_PARAMETER];
    return campaign;
}

@end
