//
//  BRBeaconMessageReporter.m
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

#import "BRBeaconMessageReporter.h"
#import "BRBeaconMessageReport.h"
#import "BRBeaconMessageLogger.h"
#import "BRBeaconMessageReportSender.h"
#import "BRBeaconMessageReport.h"
#import "BRBeaconMessageReportBuilder.h"
#import "BRBeaconMessage.h"
#import "BRLogIterator.h"
#import "BRTracer.h"

NSString* const REPORTER_LOG_TAG = @"BRBeaconMessageReporter";
const long DEFAULT_WAIT_TIME_BETWEEN_REPORTS_IN_MS = 20000L;
const long DEFAULT_POLLING_TIME_WAIT_FOR_RECEIVER_AVAILABLE_IN_MS = 60000L;

// Private methods
@interface BRBeaconMessageReporter()

- (void) startReportingInBackground;
- (void) startReportingThread;
- (void) waitUntilNextReportRequest;
- (void) waitUntilReportReceiverIsAvailable;
- (id<BRBeaconMessageReport>) tryConstructingReport;
- (id<BRBeaconMessageReport>) buildActivityReport;
- (void) sendReport: (id<BRBeaconMessageReport>) report;
- (void) clearLog;

- (void) stopReportingInBackground;

@end

@implementation BRBeaconMessageReporter

// Instantiation
- (id) initWithLogger: (BRBeaconMessageLogger*) logger andBuilder: (id<BRBeaconMessageReportBuilder>) reportBuilder andSender: (id<BRBeaconMessageReportSender>) sender {
    if (self = [super initWithSender:logger]) {
        self->_tracer = [BRTracer getInstance];
        self->_logger = logger;
        self->_thread = nil;
        self->_reportingEnabled = false;
        self->_timeBetweenReportsInMs = DEFAULT_WAIT_TIME_BETWEEN_REPORTS_IN_MS;
        self->_pollingTimeWaitForReceiverAvailableInMs = DEFAULT_POLLING_TIME_WAIT_FOR_RECEIVER_AVAILABLE_IN_MS;
        self->_reportBuilder = reportBuilder;
        self->_sender = sender;
    }
    return self;
}

// Starting
- (void) startReporting {
    // Another should wait for report request.
    [self startReportingInBackground];
}

- (void) startReportingInBackground {
    // We do not need to synchronize the threads
    // since the reporting thread does not change
    // this variable but only reads it.
    self->_reportingEnabled = true;
    self->_thread = [[NSThread alloc] initWithTarget:self selector:@selector(startReportingThread) object:nil];
    [self->_thread start];
}

- (void) startReportingThread {
    while(self->_reportingEnabled && ![self->_thread isCancelled]) {
        // 1. Wait until next report request.
        [self->_tracer logDebugWithTag:REPORTER_LOG_TAG andMessage:@"Waiting for next report request."];
        [self waitUntilNextReportRequest];
        // 2. Wait until the report receiver is available.
        [self->_tracer logDebugWithTag:REPORTER_LOG_TAG andMessage:@"Waiting until report receiver is available."];
        [self waitUntilReportReceiverIsAvailable];
        @try {
            // 3. Try constructing report.
            [self->_tracer logDebugWithTag:REPORTER_LOG_TAG andMessage:@"Trying to construct report."];
            id<BRBeaconMessageReport> report = [self tryConstructingReport];
            // 4. Clear the log.
            [self->_tracer logDebugWithTag:REPORTER_LOG_TAG andMessage:@"Clearing log."];
            [self clearLog];
            // 5. Send the report.
            if (report != nil) {
                [self->_tracer logDebugWithTag:REPORTER_LOG_TAG andMessage:@"Sending report."];
                [self sendReport:report];
            }
        } @catch(NSException* exception) {
            // If something happened while constructing or sending
            // the report, log this and just continue with the next report.
            NSString *logMessage = [NSString stringWithFormat:@"An error in BRBeaconMessageReporter occurred: %@", exception.description];
            [self->_tracer logErrorWithTag:REPORTER_LOG_TAG andMessage:logMessage];
        }
        // 6. Set the thread available for the next report
        [self->_tracer logDebugWithTag:REPORTER_LOG_TAG andMessage:@"Setting available for next report request."];
    }
}

- (void) waitUntilNextReportRequest {
    [NSThread sleepForTimeInterval:self->_timeBetweenReportsInMs/1000];
}

- (void) waitUntilReportReceiverIsAvailable {
    while (![self->_sender receiverAvailable]) {
        [NSThread sleepForTimeInterval:self->_pollingTimeWaitForReceiverAvailableInMs];
    }
}

- (id<BRBeaconMessageReport>) tryConstructingReport {
    id<BRBeaconMessageReport> report = nil;
    @try {
        report = [self buildActivityReport];
    } @catch (BRBuildException* e) {
        // If an error occurred when building the
        // report we assume that this error could
        // not be fixed by repeating. Therefore,
        // in this case we throw the complete log away
        // in order to give the next scan report a chance.
        // Therefore: Empty catch implementation.
        [self->_tracer logWarningWithTag:REPORTER_LOG_TAG andMessage:@"Failed constructing the status report!"];
    } @catch (BRNoMessagesException* e) {
        // If we did not receive any messages since the
        // last report, we do not have to send anything
        // to the receiver.
        [self->_tracer logDebugWithTag:REPORTER_LOG_TAG andMessage:@"No status report was sent, because no message were received since the last status report."];
    }
    return report;
}

- (id<BRBeaconMessageReport>) buildActivityReport {
    id<BRLogIterator> logIterator = [self->_logger getLogIterator];
    if (![logIterator hasNext]) {
        @throw [BRNoMessagesException exceptionWithName:@"" reason:@"" userInfo:nil];
    }
    
    [self->_reportBuilder newReport];
    
    while ([logIterator hasNext]) {
        BRBeaconMessage* message = [logIterator next];
        [self->_reportBuilder addBeaconMessage:message];
    }
    id<BRBeaconMessageReport> report = [self->_reportBuilder buildReport];
    return report;
}

- (void) sendReport: (id<BRBeaconMessageReport>) report {
    BOOL retrySendingReport = true;
    while (retrySendingReport) {
        @try {
            // Send the report.
            [self->_sender sendReport: report];
            // Set the report sending as finished.
            retrySendingReport = false;
        } @catch (BRSendReportException* exception) {
            // If report cannot be sent, just log this information
            // and do not retry sending the report.
            [self->_tracer logWarningWithTag:REPORTER_LOG_TAG andMessage:@"Failed sending status report! Retry sending report."];
            retrySendingReport = false;
        } @catch (BRUnresolvableSendReportException* exception) {
            // If report cannot be sent, just log this information
            // and do not retry sending the report.
            [self->_tracer logWarningWithTag:REPORTER_LOG_TAG andMessage:@"Failed sending status report! Discard status report."];
            retrySendingReport = false;
        }
    }
}

- (void) clearLog {
    // Since the logger class is thread safe we do not need
    // to add a synchronized block.
    [self->_logger clearLog];
}

- (void) stopReporting {
    // Reporting should be turned off.
    [self stopReportingInBackground];
}

- (void) stopReportingInBackground {
    // We do not need to synchronize the threads
    // since the reporting thread does not change
    // this variable but only reads it.
    self->_reportingEnabled = false;
    [self->_thread cancel];
}

- /* override */ (void) preprocessMessage: (BRBeaconMessage*) message {
    
}

- /* override */ (void) postprocessMessage: (BRBeaconMessage*) message {
    
}

- /* override */ (void) onMeshInactive: (BRBeaconMessageStreamNode *) senderNode {
    [super onMeshInactive:senderNode];
}

@end
