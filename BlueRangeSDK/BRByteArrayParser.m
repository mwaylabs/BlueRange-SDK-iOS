//
//  BRByteArrayParser.m
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

#import "BRByteArrayParser.h"

@implementation BRByteArrayParser

- (id) initWithOffset: (int) offset {
    if (self = [super init] ) {
        self->_pointer = offset;
    }
    return self;
}

- (int) readUnsignedShort: (uint8_t*) bytes {
    int i =   ((uint16_t)(bytes[self->_pointer+0]) << 8)
            + ((uint16_t)(bytes[self->_pointer+1]) << 0);
    self->_pointer += 2;
    return i;
}

- (int) readSwappedUnsignedShort: (uint8_t*) bytes {
    int i =   ((uint16_t)(bytes[self->_pointer+0]) << 0)
            + ((uint16_t)(bytes[self->_pointer+1]) << 8);
    self->_pointer += 2;
    return i;
}

- (long long) readSwappedUnsignedInteger: (uint8_t*) bytes {
    long long l =  (((uint32_t)bytes[self->_pointer+0]) << 0)
            + (((uint32_t)bytes[self->_pointer+1]) << 8)
            + (((uint32_t)bytes[self->_pointer+2]) << 16)
            + (((uint32_t)bytes[self->_pointer+3]) << 24);
    self->_pointer += 4;
    return l;
}

- (short) readSwappedShort: (uint8_t*) bytes {
    int i =   ((int16_t)(bytes[self->_pointer+0]) << 0)
            + ((int16_t)(bytes[self->_pointer+1]) << 8);
    self->_pointer += 2;
    return i;
}

- (short) readSwappedBitsOfByteWithLockedPointer: (uint8_t*) bytes andStartBit: (int) startBit andEndBit: (int) endBit {
    const int BYTE_LENGTH = 8;
    uint8_t mask = 0;
    for (int i = 0; i < BYTE_LENGTH; i++) {
        if (i >= startBit && i <= endBit) {
            mask += pow(2, i);
        }
    }
    short s = (short)(((bytes[self->_pointer] & mask)) >> startBit);
    return s;
}

- (short) readSwappedBitsOfByte: (uint8_t*) bytes andStartBit: (int) startBit andEndBit: (int) endBit {
    short s = [self readSwappedBitsOfByteWithLockedPointer:bytes andStartBit:startBit andEndBit:endBit];
    self->_pointer += 1;
    return s;
}

- (short) readSwappedUnsignedByte: (uint8_t*) bytes {
    short s = (uint8_t)(bytes[self->_pointer]);
    self->_pointer += 1;
    return s;
}

- (short) readSwappedByte: (uint8_t*) bytes {
    short s = (int8_t)bytes[self->_pointer];
    self->_pointer += 1;
    return s;
}

@end
