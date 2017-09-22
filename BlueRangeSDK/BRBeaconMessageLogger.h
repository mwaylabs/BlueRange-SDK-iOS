//
//  BRBeaconMessageLogger.h
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
#import "BRBeaconMessagePassingStreamNode.h"
#import "BRLogIterator.h"

@protocol BRITracer;
@protocol BRBeaconMessagePersistor;

@class BRBeaconMessageLog;

/**
 * A beacon message logger persistently logs a stream of {@link BRBeaconMessage}s delivered by the
 * senders and just passes the stream to all of its receivers. The log is saved in an energy
 * efficient manner. To read all messages from the log, you should call the {@link
 * #getLogIterator} or {@link #iterator} method, because calling the {@link #readLog} requires to
 * load the complete log in memory. The iterator, in contrast, reads the log in chunks and,
 * moreover, automatically updates the log, if it has changed while iterating over it. The
 * complete log will be deleted, if you call the {@link #clearLog} method.
 */
@interface BRBeaconMessageLogger : BRBeaconMessagePassingStreamNode {
    // Tracing
    id<BRITracer> _tracer;
    // Persistor
    id<BRBeaconMessagePersistor> _persistor;
}

// Instantiation
- (id) initWithSender:(BRBeaconMessageStreamNode *)sender;
- (id) initWithSender:(BRBeaconMessageStreamNode *)sender andPersistor: (id<BRBeaconMessagePersistor>) persistor andTracer: (id<BRITracer>) tracer;

// Read log
- (BRBeaconMessageLog*) readLog;
- (id<BRLogIterator>) getLogIterator;
- (int) getTotalMessagesInLog;

// Writing log
- (void) clearLog;

// Message processing
- /* override */ (void) preprocessMessage: (BRBeaconMessage*) message;
- /* override */ (void) postprocessMessage: (BRBeaconMessage*) message;

@end
