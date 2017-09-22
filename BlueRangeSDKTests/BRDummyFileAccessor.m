//
//  BRDummyFileAccessor.m
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
