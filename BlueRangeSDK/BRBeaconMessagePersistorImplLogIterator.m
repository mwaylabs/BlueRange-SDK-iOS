//
//  BRBeaconMessagePersistorImplLogIterator.m
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

#import "BRBeaconMessagePersistorImplLogIterator.h"
#import "BRBeaconMessagePersistorImpl.h"
#import "BRFileAccessor.h"
#import "BRZipCompression.h"

// Private methods
@interface BRBeaconMessagePersistorImplLogIterator()

- (BOOL) hasRemainingMessagesInChunk;
- (BOOL) hasRemainingChunks;

- (void) readNextChunkIfNeccessary;
- (void) readNextSavedChunk;
- (NSString*) getNextChunkFileName;
- (NSMutableArray*) readChunk: (NSString*) fileName;
- (void) readCachedChunk;

@end

@implementation BRBeaconMessagePersistorImplLogIterator

- (id) initWithFileAccessor: (id<BRFileAccessor>) fileAccessor andChunkFileNames: (NSMutableArray*) chunkFileNames andFileNamePrefix: (NSString*) fileNamePrefix andPersistorImpl: (BRBeaconMessagePersistorImpl*) persistor andCachedMessages: (NSMutableArray*) cachedMessages {
    if (self = [super init]) {
        self->_persistor = persistor;
        self->_fileAccessor = fileAccessor;
        self->_chunkFileNames = chunkFileNames;
        self->_fileNamePrefix = fileNamePrefix;
        self->_cachedMessages = cachedMessages;
        self->_currentChunkFileName = nil;
        self->_currentChunkIsCacheChunk = false;
        self->_currentChunk = [[NSMutableArray alloc] init];
        self->_messagePointer = 0;
    }
    return self;
}

- /* override */ (BOOL) hasNext {
    // To overcome dirty read problems we need
    // to synchronize all threads accessing the fileAccessor and preload
    // the chunk yet when hasNext is called.
    @synchronized(self->_fileAccessor) {
        [self readNextChunkIfNeccessary];
        return [self hasRemainingMessagesInChunk];
    }
}

- (BOOL) hasRemainingMessagesInChunk {
    return self->_messagePointer < [self->_currentChunk count];
}

- (BOOL) hasRemainingChunks {
    // Returns true if a file exists with the
    // chunk prefix and is lexicographically greater.
    for (NSString* fileName in self->_chunkFileNames) {
        if ([fileName hasPrefix:self->_fileNamePrefix]) {
            if (self->_currentChunkFileName == nil || ([self->_currentChunkFileName compare:fileName] == NSOrderedAscending)) {
                return true;
            }
        }
    }
    return false;
}

- /* override */ (BRBeaconMessage*) next {
    // If hasNext is called always before the next method
    // this condition will never become true
    // because the chunk will always be preloaded
    // in the hasNext method. However, if the
    // user does not call hasNext or call next multiple
    // times, the chunk most be loaded here.
    if (! [self hasNext]) {
        @throw [[NSException alloc] initWithName:@"No such element" reason:@"" userInfo:nil];
    }
    BRBeaconMessage* message = [self->_currentChunk objectAtIndex:self->_messagePointer];
    self->_messagePointer++;
    return message;
}

- (void) readNextChunkIfNeccessary {
    BOOL hasRemainingMessagesInChunk = [self hasRemainingMessagesInChunk];
    BOOL hasRemainingChunks = [self hasRemainingChunks];
    if ((!hasRemainingMessagesInChunk) && hasRemainingChunks) {
        [self readNextSavedChunk];
    } else if((!hasRemainingMessagesInChunk && (!hasRemainingChunks)) && !self->_currentChunkIsCacheChunk) {
        // Some messages may still be in the cache. They should
        // also be considered by the iterator. But the cache chunk
        // should of course only be loaded once.
        [self readCachedChunk];
    }
}

- (void) readNextSavedChunk {
    NSString* nextChunkFileName = nil;
    NSMutableArray* nextChunk = nil;
    nextChunkFileName = [self getNextChunkFileName];
    if (nextChunkFileName != nil) {
        nextChunk = [self readChunk:nextChunkFileName];
    } else {
        @throw [[NSException alloc] init];
    }
    self->_currentChunkFileName = nextChunkFileName;
    self->_currentChunk = nextChunk;
    self->_messagePointer = 0;
}

- (NSString*) getNextChunkFileName{
    for (NSString* fileName in self->_chunkFileNames) {
        if ([fileName hasPrefix:self->_fileNamePrefix]) {
            if (self->_currentChunkFileName == nil ||
                ([self->_currentChunkFileName compare:fileName] == NSOrderedAscending)) {
                return fileName;
            }
        }
    }
    return nil;
}

- (NSMutableArray*) readChunk: (NSString*) fileName{
    NSMutableArray* chunk = [[NSMutableArray alloc] init];
    @try {
        if (self->_persistor.zippingEnabled) {
            NSData* compressedData = [self->_fileAccessor getFile:fileName];
            NSData* uncompressedData = [BRZipCompression uncompressGZip:compressedData];
            chunk = (NSMutableArray*)[NSKeyedUnarchiver unarchiveObjectWithData:uncompressedData];
        } else {
            NSData* uncompressedData = [self->_fileAccessor getFile:fileName];
            chunk = (NSMutableArray*)[NSKeyedUnarchiver unarchiveObjectWithData:uncompressedData];
        }
    } @catch(NSException* exception) {
        // Most of the exceptions can not be reached. So we
        // do not expect anything inappropriate happens.
    }
    return chunk;
}

- (void) readCachedChunk {
    self->_currentChunk = [[NSMutableArray alloc] init];
    // Copy all messages to a secondary cache in order
    // to avoid race conditions.
    self->_currentChunkIsCacheChunk = true;
    [self->_currentChunk addObjectsFromArray:self->_cachedMessages];
    self->_messagePointer = 0;
}


@end
