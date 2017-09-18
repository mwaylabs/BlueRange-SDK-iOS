//
//  BRBeaconMessagePersistorImpl.h
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

#import <Foundation/Foundation.h>
#import "BRBeaconMessagePersistor.h"

@protocol BRITracer;
@protocol BRFileAccessor;

/**
 * This class is the default implementation of the {@link BRBeaconMessagePersistor} interface. The
 * log has a default maximum size of {@link #DEFAULT_MAX_LOG_SIZE}. In order to increase
 * performance and compression efficiency and decrease energy consumption, the messages are saved
 * in chunks with a chunk size of {@link #chunkSize}. The persisting strategy is defined by the
 * {@link BRFileAccessor}. By default, each chunk is compressed with the gzip compression algorithm
 * before it is being saved. However, to increase the persisting efficiency, the compression
 * might be turned off.
 */
@interface BRBeaconMessagePersistorImpl : NSObject<BRBeaconMessagePersistor> {
    // Caching
    NSMutableArray* _cachedMessages;
    
    // Persisting
    id<BRFileAccessor> _fileAccessor;
    // Due to performance reasons, we cache the list of chunk file names.
    NSMutableArray* _chunkFileNames;
}

// Tracing
@property id<BRITracer> tracer;

// Configuration
@property int maxLogSize;

// Caching
@property int chunkSize;

// Compressing
@property BOOL zippingEnabled;

// Instantiation
- (id) init;
- (id) initWithFileAccessor: (id<BRFileAccessor>) fileAccessor;
- (id) initWithFileAccessor: (id<BRFileAccessor>) fileAccessor andChunkSize: (int) chunkSize;

// Read operations
- /* override */ (BRBeaconMessageLog*) readLog;
- /* override */ (id<BRLogIterator>) getLogIterator;
- /* override */ (int) getTotalMessages;
- (int) getLogSizeInBytes;

// Write operations
- /* override */ (void) clearMessages;
- /* override */ (void) writeMessage: (BRBeaconMessage*) beaconMessage;

@end
