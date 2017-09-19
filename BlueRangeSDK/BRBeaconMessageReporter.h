//
//  BRBeaconMessageReporter.h
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

// Forward declarations
@protocol BRITracer;
@protocol BRBeaconMessageReportBuilder;
@protocol BRBeaconMessageReportSender;
@class BRBeaconMessageLogger;

/**
 * A beacon message reporter periodically reads the log of a {@link BRBeaconMessageLogger} instance
 * and sends reports to a specified sender. The reports will be sent to the receiver
 * every {@link #timeBetweenReportsInMs} milliseconds.
 */
@interface BRBeaconMessageReporter : BRBeaconMessagePassingStreamNode {
    // Tracing
    id<BRITracer> _tracer;
    
    // Logger
    BRBeaconMessageLogger* _logger;
    
    // Internal state
    NSThread *_thread;
    BOOL _reportingEnabled;
    
    // Configuration
    long _timeBetweenReportsInMs;
    long _pollingTimeWaitForReceiverAvailableInMs;
    
    // Components
    id<BRBeaconMessageReportBuilder> _reportBuilder;
    id<BRBeaconMessageReportSender> _sender;
}

@property long timeBetweenReportsInMs;
@property long pollingTimeWaitForReceiverAvailableInMs;

// Instantiation

/**
 * Creates a new instance using the preconfigured {@link BRBeaconMessageLogger},
 * {@link BRBeaconMessageReportBuilder} and {@link BRBeaconMessageReportSender}.
 * @param logger The preconfigured logger that is used for scanning and persistently
 *               logging {@link BRBeaconMessage}s.
 * @param reportBuilder A builder that transform a stream of {@link BRBeaconMessage}s to a
 *                      {@link BRBeaconMessageReport} object.
 * @param sender The {@link BRBeaconMessageReportSender} object which the reports will be sent to.
 */
- (id) initWithLogger: (BRBeaconMessageLogger*) logger
           andBuilder: (id<BRBeaconMessageReportBuilder>) reportBuilder
           andSender: (id<BRBeaconMessageReportSender>) sender;

// Starting and stopping

/**
 * Starts scanning, persistently logging and periodically
 * sending reports.
 */
- (void) startReporting;
/**
 * Stops scanning, logging and reporting.
 */
- (void) stopReporting;

- /* override */ (void) preprocessMessage: (BRBeaconMessage*) message;
- /* override */ (void) postprocessMessage: (BRBeaconMessage*) message;
- /* override */ (void) onMeshInactive: (BRBeaconMessageStreamNode *) senderNode;

@end
