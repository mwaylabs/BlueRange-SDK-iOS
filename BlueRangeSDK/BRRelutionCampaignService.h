//
//  BRRelutionCampaignService.h
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

#import <Foundation/Foundation.h>

@protocol BRIBeaconMessageActionMapper;
@protocol BRRelutionTagMessageActionMapper;
@protocol RelutionUUIDRegistry;
@protocol BRBeaconActionListener;
@protocol BRBeaconActionDebugListener;
@class BRRelutionTagMessageActionMapperEmptyStub;
@class BRIBeaconMessageScanner;
@class BRBeaconMessageActionTrigger;
@class BRRelution;

/**
 * A Relution campaign service can trigger actions defined in a Relution campaign. Internally
 * this class uses the {@link BRBeaconMessageActionTrigger} of the SDK's core layer. The action
 * registry obtains all action informations from the Relution system. To start the trigger, just
 * call the {@link #start} method. The start method will periodically update a list of iBeacons
 * each 10 seconds. In future versions actions will also be triggered when Relution tags will be
 * received..
 */
@interface BRRelutionCampaignService : NSObject {
    // Registry
    id<BRIBeaconMessageActionMapper> _iBeaconMessageActionMapper;
    BRRelutionTagMessageActionMapperEmptyStub* _relutionTagMessageActionMapper;
    
    // Message processing graph
    BRIBeaconMessageScanner *_scanner;
    BRBeaconMessageActionTrigger *_trigger;
}

- (id) initWithScanner: (BRIBeaconMessageScanner*) scanner andRelution: (BRRelution*) relution;
- (void) start;
- (void) stop;
- (void) addActionListener: (NSObject<BRBeaconActionListener>*) listener;
- (void) addDebugActionListener: (NSObject<BRBeaconActionDebugListener>*) listener;

@end
