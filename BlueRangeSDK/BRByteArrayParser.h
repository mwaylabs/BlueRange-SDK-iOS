//
//  BRByteArrayParser.h
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

@interface BRByteArrayParser : NSObject {
    int _pointer;
}

- (id) initWithOffset: (int) offset;
- (int) readUnsignedShort: (uint8_t*) bytes;
- (int) readSwappedUnsignedShort: (uint8_t*) bytes;
- (long long) readSwappedUnsignedInteger: (uint8_t*) bytes;
- (short) readSwappedShort: (uint8_t*) bytes;
- (short) readSwappedBitsOfByteWithLockedPointer: (uint8_t*) bytes andStartBit: (int) startBit andEndBit: (int) endBit;
- (short) readSwappedBitsOfByte: (uint8_t*) bytes andStartBit: (int) startBit andEndBit: (int) endBit;
- (short) readSwappedUnsignedByte: (uint8_t*) bytes;
- (short) readSwappedByte: (uint8_t*) bytes;

@end
