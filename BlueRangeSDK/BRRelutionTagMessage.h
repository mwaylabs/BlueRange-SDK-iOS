//
//  BRRelutionTagMessage.h
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
#import "BREddystoneUidMessage.h"

@interface BRRelutionTagMessage : BREddystoneUidMessage {
    NSMutableArray* _tags;
}

@property (readonly) NSArray* tags;

- (id) initWithNamespaceUid:(NSString *)namespaceUid andTags: (NSArray*) tags;
- (id) initWithNamespaceUid:(NSString *)namespaceUid andTags: (NSArray*) tags andTxPower: (int) txPower;
- (id) initWithNamespaceUid:(NSString *)namespaceUid andTags: (NSArray*) tags andTxPower: (int) txPower andRssi: (int) rssi;
- (id) initWithNamespaceUid:(NSString *)namespaceUid andInstanceId:(NSString *)instanceId;
- (id) initWithNamespaceUid: (NSString* ) namespaceUid andInstanceId: (NSString*) instanceId andTxPower: (int) txPower;
- (id) initWithNamespaceUid: (NSString* ) namespaceUid andInstanceId: (NSString*) instanceId andTxPower: (int) txPower andRssi: (int) rssi;
- (NSString *) getDescription;
- (BRBeaconMessage*) newCopy;
- (id)copyWithZone:(struct _NSZone *)zone;

+ (NSString*) getInstanceIdFromTags: (NSArray*) tags;

@end
