//
//  BRBeaconMessageLogger.m
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
