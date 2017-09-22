//
//  BRBeaconMessagePersistorImpl.m
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

#import "BRBeaconMessagePersistorImpl.h"
#import "BRFileAccessor.h"
#import "BRFileAccessorImpl.h"
#import "BRTracer.h"
#import "BRBeaconMessageLog.h"
#import "BRLogIterator.h"
#import "BRBeaconMessagePersistorImplLogIterator.h"
#import "BRZipCompression.h"

// BRConstants

NSString * const BEACON_MESSAGE_PERSISTOR_LOG_TAG = @"BRBeaconMessagePersistorImpl";
// By default we limit the log size to about 100 MB,
// if the log was saved without compression.
// We assume an average message size of 100 byte per message.
// Therefore we set the default maximum log size to 1000000 messages.
const int PERSISTOR_DEFAULT_MAX_LOG_SIZE = 1000000;
const int PERSISTOR_DEFAULT_CHUNK_SIZE = 1000;
NSString* const PERSISTOR_FILE_NAME_PREFIX = @"scanlog_";

// Private methods
@interface BRBeaconMessagePersistorImpl()

- (void) deleteChunk: (NSString*) fileName;
- (void) saveChunk;
- (void) writeChunk;
- (int) getBytesCount: (NSInputStream*) inputStream;

@end

@implementation BRBeaconMessagePersistorImpl

// Instantiation
- (id) init {
    return [self initWithFileAccessor:[[BRFileAccessorImpl alloc] init] andChunkSize:PERSISTOR_DEFAULT_CHUNK_SIZE];
}

- (id) initWithFileAccessor: (id<BRFileAccessor>) fileAccessor {
    return [self initWithFileAccessor:fileAccessor andChunkSize:PERSISTOR_DEFAULT_CHUNK_SIZE];
}

- (id) initWithFileAccessor: (id<BRFileAccessor>) fileAccessor andChunkSize: (int) chunkSize {
    if (self = [super init]) {
        // First init
        self->_maxLogSize = PERSISTOR_DEFAULT_MAX_LOG_SIZE;
        self->_tracer = [BRTracer getInstance];
        self->_cachedMessages = [[NSMutableArray alloc] init];
        self->_chunkSize = PERSISTOR_DEFAULT_CHUNK_SIZE;
        self->_fileAccessor = nil;
        self->_chunkFileNames = [[NSMutableArray alloc] init];
        self->_zippingEnabled = true;
        // Second init
        self->_fileAccessor = fileAccessor;
        [self->_chunkFileNames addObjectsFromArray:[self->_fileAccessor getFiles]];
        self->_chunkSize = chunkSize;
    }
    return self;
}

// Read operations
- /* override */ (BRBeaconMessageLog*) readLog {
    // We use the Iterator to prevent race conditions.
    NSMutableArray* messages = [[NSMutableArray alloc] init];
    id<BRLogIterator> iterator = [self getLogIterator];
    while ([iterator hasNext]) {
        BRBeaconMessage* beaconMessage = [iterator next];
        [messages addObject:beaconMessage];
    }
    BRBeaconMessageLog* __autoreleasing log = [[BRBeaconMessageLog alloc] initWithMessages:messages];
    return log;
}

- /* override */ (id<BRLogIterator>) getLogIterator {
    return [[BRBeaconMessagePersistorImplLogIterator alloc] initWithFileAccessor:self->_fileAccessor andChunkFileNames:self->_chunkFileNames andFileNamePrefix:PERSISTOR_FILE_NAME_PREFIX andPersistorImpl:self andCachedMessages:self->_cachedMessages];
}

- /* override */ (int) getTotalMessages {
    int totalFiles = (int)[self->_chunkFileNames count];
    int totalMessagesInLog = self->_chunkSize*totalFiles + (int)[self->_cachedMessages count];
    return totalMessagesInLog;
}

- (int) getLogSizeInBytes {
    @synchronized(self->_fileAccessor) {
        int numBytes = 0;
        for (NSString* fileName in self->_chunkFileNames) {
            @try {
                NSInputStream* is = [self->_fileAccessor openFileInputStream:fileName];
                int size = [self getBytesCount:is];
                [is close];
                numBytes += size;
            } @catch(NSException *exception) {
                [self->_tracer logErrorWithTag:BEACON_MESSAGE_PERSISTOR_LOG_TAG
                                    andMessage:@"An unexpected error occurred while computing the size of the Beacon Message log."];
            }
        }
        return numBytes;
    }
}

// Write operations
- /* override */ (void) clearMessages {
    // We need to synchronize all threads operating on the chunk files.
    @synchronized(self->_fileAccessor) {
        NSMutableArray* removedFileNames = [[NSMutableArray alloc] init];
        for (NSString* fileName in self->_chunkFileNames) {
            // Delete the chunk
            [self deleteChunk:fileName];
            // Add file name to the list of deleted file names.
            [removedFileNames addObject:fileName];
        }
        [self->_chunkFileNames removeObjectsInArray:removedFileNames];
    }
    // Clear also the cached chunk.
    [self->_cachedMessages removeAllObjects];
}

- (void) deleteChunk: (NSString*) fileName {
    [self->_fileAccessor deleteFile: fileName];
}

- /* override */ (void) writeMessage: (BRBeaconMessage*) beaconMessage {
    // Do only add if log has not reached maximum size.
    if ([self getTotalMessages] < self.maxLogSize) {
        // Add message to the log cache.
        //[self->_tracer logErrorWithTag:BEACON_MESSAGE_PERSISTOR_LOG_TAG andMessage:@"Logged message"];
        [self->_cachedMessages addObject:beaconMessage];
        // Save the whole chunk if it is big enough.
        if ([self->_cachedMessages count] >= self->_chunkSize) {
            //[self->_tracer logErrorWithTag:BEACON_MESSAGE_PERSISTOR_LOG_TAG andMessage:@"Saved chunk"];
            [self saveChunk];
        }
    } else {
        NSString *logMessage = [NSString stringWithFormat:@"Could not persist message to log. Maximum log size of %d bytes reached.", self->_maxLogSize];
        [self->_tracer logErrorWithTag:BEACON_MESSAGE_PERSISTOR_LOG_TAG andMessage:logMessage];
    }
}

- (void) saveChunk {
    // Persist chunk
    [self writeChunk];
    // Clear cache.
    [self->_cachedMessages removeAllObjects];
}

- (void) writeChunk {
    // We need to synchronize all threads
    // operating on the chunk files.
    @synchronized(self->_fileAccessor) {
        // Define file name for current chunk.
        NSString* fileName = [NSString stringWithFormat:@"%@%lu", PERSISTOR_FILE_NAME_PREFIX, (unsigned long)[self->_chunkFileNames count]];
        // Update the chunk file name list.
        [self->_chunkFileNames addObject:fileName];

        @try {
            if (self->_zippingEnabled) {
                NSData *uncompressedData=[NSKeyedArchiver archivedDataWithRootObject:self->_cachedMessages];
                NSData *compressedData = [BRZipCompression compressData:uncompressedData];
                [self->_fileAccessor writeFile:compressedData withFileName:fileName];
            } else {
                NSData *uncompressedData=[NSKeyedArchiver archivedDataWithRootObject:self->_cachedMessages];
                [self->_fileAccessor writeFile:uncompressedData withFileName:fileName];
            }
        } @catch (NSException* exception) {
            [self->_tracer logErrorWithTag:BEACON_MESSAGE_PERSISTOR_LOG_TAG
                                andMessage:@"Error while writing chunk in Beacon message logger."];
        }
    }
}

- (int) getBytesCount: (NSInputStream*) inputStream {
    NSInteger bufferSizeNumber = 524288;
    NSMutableData *myBuffer = [NSMutableData dataWithLength:bufferSizeNumber];
    
    uint8_t *buf = [myBuffer mutableBytes];
    NSInteger len = 0;
    
    len = [inputStream read:buf maxLength:bufferSizeNumber];
    return (int)len;
}

@end
