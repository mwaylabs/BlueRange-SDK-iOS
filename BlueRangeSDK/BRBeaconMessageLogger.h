//
//  BRBeaconMessageLogger.h
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
