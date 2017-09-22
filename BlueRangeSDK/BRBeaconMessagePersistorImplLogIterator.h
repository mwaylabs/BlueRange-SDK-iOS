//
//  BRBeaconMessagePersistorImplLogIterator.h
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
#import "BRLogIterator.h"

@protocol BRFileAccessor;

@class BRBeaconMessagePersistorImpl;

@interface BRBeaconMessagePersistorImplLogIterator : NSObject<BRLogIterator> {
    // BRFileAccessor
    BRBeaconMessagePersistorImpl* _persistor;
    id<BRFileAccessor> _fileAccessor;
    NSMutableArray *_chunkFileNames;
    NSString* _fileNamePrefix;
    NSMutableArray* _cachedMessages;
    
    // Pointer to the current chunk
    NSString* _currentChunkFileName;
    BOOL _currentChunkIsCacheChunk;
    NSMutableArray *_currentChunk;
    
    // Pointer to the current message inside the chunk
    int _messagePointer;
}

- (id) initWithFileAccessor: (id<BRFileAccessor>) fileAccessor andChunkFileNames: (NSMutableArray*) chunkFileNames andFileNamePrefix: (NSString*) fileNamePrefix andPersistorImpl: (BRBeaconMessagePersistorImpl*) persistor andCachedMessages: (NSMutableArray*) cachedMessages;
- /* override */ (BOOL) hasNext;
- /* override */ (BRBeaconMessage*) next;

@end
