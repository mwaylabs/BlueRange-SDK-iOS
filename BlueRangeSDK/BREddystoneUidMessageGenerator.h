//
//  BREddystoneUidMessageGenerator.h
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
#import "BREddystoneMessageGenerator.h"

/**
 * The beacon message generator class for Eddystone UID messages.
 */
@interface BREddystoneUidMessageGenerator : BREddystoneMessageGenerator {
    BOOL _namespaceFilteringEnabled;
    NSString* _namespaceUid;
    NSMutableArray* _blacklistedNamespaces;
    BOOL _instanceFilteringEnabled;
    NSString* _instance;
}

@property (readonly) NSString* namespaceUid;
@property (readonly) NSString* instance;

- (id) init;
- (id) initWithNamespace: (NSString*) namespaceUid;
- (id) initWithNamespace: (NSString*) namespaceUid andInstance: (NSString*) instance;
- /* override */ (BOOL) matches: (NSDictionary*) advertisementData;
- /* override */ (BRBeaconMessage*) newMessage: (NSDictionary*) advertisementData withRssi: (int) rssi;
- /* override */ (BOOL) isEqual:(id)object;
- (void) blacklistNamespace: (NSString*) namespaceUid;

@end
