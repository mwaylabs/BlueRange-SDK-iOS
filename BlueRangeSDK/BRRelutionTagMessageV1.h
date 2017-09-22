//
//  BRRelutionTagMessageV1.h
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
#import "BRBeaconMessage.h"

/**
 * A Relution Tag message is a Relution specific advertising message that can be delivered by
 * BlueRange SmartBeacons. A Relution tag message contains one or more tag identifiers. The
 * concept of Relution Tag messages is designed for apps that do not require internet access but
 * want to react to tags, that can be assigned dynamically to a beacon using the Relution platform.
 */
@interface BRRelutionTagMessageV1 : BRBeaconMessage

@property (readonly, copy) NSArray* tags;
@property (readonly) short txPower;

- (id) initWithTags: (NSArray*) tags andRssi: (int) rssi andTxPower: (short) txPower;
- (id) initWithCoder:(NSCoder *)coder;
- (NSString *) getDescription;
- (BRBeaconMessage*) newCopy;
- (id)copyWithZone:(struct _NSZone *)zone;
- (BOOL) isEqual:(id)object;
- (void) encodeWithCoder:(NSCoder *)coder;
- /* Override */ (NSUInteger) hash;

@end
