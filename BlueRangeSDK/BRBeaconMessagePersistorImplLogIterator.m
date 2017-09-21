//
//  BRBeaconMessagePersistorImplLogIterator.m
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
