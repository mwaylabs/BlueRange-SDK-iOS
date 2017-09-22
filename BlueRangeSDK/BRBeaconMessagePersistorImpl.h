//
//  BRBeaconMessagePersistorImpl.h
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
