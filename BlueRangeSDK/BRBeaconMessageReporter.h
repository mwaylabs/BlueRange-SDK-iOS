//
//  BRBeaconMessageReporter.h
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
