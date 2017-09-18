//
//  BRByteArrayParser.m
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
