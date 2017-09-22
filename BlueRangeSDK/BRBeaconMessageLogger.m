//
//  BRBeaconMessageLogger.m
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

#import "BRBeaconMessageLogger.h"
#import "BRBeaconMessagePersistorImpl.h"
#import "BRBeaconMessageLog.h"
#import "BRTracer.h"

NSString* const BEACON_MESSAGE_LOGGER_LOG_TAG = @"BRBeaconMessageLogger";

@implementation BRBeaconMessageLogger

// Instantiation
- (id) initWithSender:(BRBeaconMessageStreamNode *)sender {
    return [self initWithSender:sender andPersistor:[[BRBeaconMessagePersistorImpl alloc] init] andTracer:[BRTracer getInstance]];
}

- (id) initWithSender:(BRBeaconMessageStreamNode *)sender andPersistor: (id<BRBeaconMessagePersistor>) persistor andTracer: (id<BRITracer>) tracer {
    if (self = [super initWithSender:sender]) {
        self->_persistor = persistor;
        self->_tracer = tracer;
    }
    return self;
}

// Read log
- (BRBeaconMessageLog*) readLog {
    BRBeaconMessageLog* log = [self->_persistor readLog];
    return log;
}

- (id<BRLogIterator>) getLogIterator {
    return [self->_persistor getLogIterator];
}

- (int) getTotalMessagesInLog {
    return [self->_persistor getTotalMessages];
}

// Writing log
- (void) clearLog {
    [self->_persistor clearMessages];
}

// Message processing
- /* override */ (void) preprocessMessage: (BRBeaconMessage*) message {
    [self->_persistor writeMessage:message];
}

- /* override */ (void) postprocessMessage: (BRBeaconMessage*) message {
    
}

@end
