//
//  BRBeaconMessage.h
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

/**
 * The base class of all beacon messages.
 */
@interface BRBeaconMessage : NSObject<NSCopying>

@property (copy) NSDate* timestamp;
@property int rssi;

// Public
- (id) init;
- (id) initWithTimestamp: (NSDate*) timestamp;
- (id) initWithTimestamp: (NSDate*) timestamp andRssi: (int) rssi;
- (id) initWithCoder:(NSCoder *)coder;
- (NSString*) getType;
- (BOOL) isEqual:(id)object;
- (NSString *) description;
- (id) copy;
- (id)copyWithZone:(struct _NSZone *)zone;
- (void) encodeWithCoder:(NSCoder *)coder;

// Protected
- (NSString *) getDescription;
- (BRBeaconMessage*) newCopy;
- /* abstract */ (short) txPower;
- /* abstract */ (NSUInteger) hash;

@end
