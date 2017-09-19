//
//  BRDummyFileAccessor.m
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

#import "BRDummyFileAccessor.h"

@implementation BRDummyFileAccessor

- (id) init {
    if (self = [super init]) {
        self->_fileNames = [[NSMutableArray alloc] init];
        self->_files = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSMutableArray*) getFiles {
    NSMutableArray* shallowCopy = [[NSMutableArray alloc] initWithArray:self->_fileNames];
    return shallowCopy;
}

- (NSInputStream*) openFileInputStream: (NSString*) fileName {
    int index = (int)[self->_fileNames indexOfObject:fileName];
    if (index == -1) {
        [NSException raise:@"File not found" format:@""];
    }
    NSOutputStream* outFile = [self->_files objectAtIndex:index];
    [outFile open];
    NSData *contents = [outFile propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    [outFile close];
    NSInputStream* inFile = [[NSInputStream alloc] initWithData:contents];
    [inFile open];
    return inFile;
}

- (NSOutputStream*) openFileOutputStream: (NSString*) fileName {
    NSOutputStream* outFile = [[NSOutputStream alloc] initToMemory];
    [self->_fileNames addObject:fileName];
    [self->_files addObject:outFile];
    [outFile open];
    return outFile;
}

- (void) corruptAllFiles {
    uint8_t* corruptFile = (uint8_t*)malloc(1);
    for (int i = 0; i < [self->_files count]; i++) {
        NSOutputStream* file = [[NSOutputStream alloc] initToMemory];
        [file write:corruptFile maxLength:1];
        [self->_files setObject:file atIndexedSubscript:i];
    }
}

- (void) deleteFile: (NSString*) fileName {
    int index = (int)[self->_fileNames indexOfObject:fileName];
    [self->_fileNames removeObjectAtIndex:index];
    [self->_files removeObjectAtIndex:index];
}

- (NSData*) getFile: (NSString*) fileName {
    int index = (int)[self->_fileNames indexOfObject:fileName];
    NSOutputStream* outFile = [self->_files objectAtIndex:index];
    [outFile open];
    NSData *contents = [outFile propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    [outFile close];
    return contents;
}

- (void) writeFile: (NSData*) data withFileName: (NSString*) fileName {
    int index = (int)[self->_fileNames indexOfObject:fileName];
    if (index < 0) {
        [self openFileOutputStream:fileName];
    }
    int index2 = (int)[self->_fileNames indexOfObject:fileName];
    NSOutputStream* outFile = [self->_files objectAtIndex:index2];
    const uint8_t *buf = [data bytes];
    NSUInteger length = [data length];
    [outFile write:buf maxLength:length];
}

@end
