//
//  BRRelutionHeatmapService.m
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

#import "BRRelutionHeatmapService.h"
#import "BRRelutionHeatmapSender.h"
#import "BRRelutionHeatmapSenderStub.h"
#import "BRBeaconMessageLogger.h"
#import "BRIBeaconMessageScanner.h"
#import "BRBeaconMessageScannerConfig.h"
#import "BRRelutionHeatmapReportBuilder.h"
#import "BRBeaconMessageReporter.h"
#import "BRRelution.h"

// BRConstants
NSString * const RELUTION_HEATMAP_SERVICE_LOG_TAG = @"BRRelutionHeatmapService";

// Private methods
@interface BRRelutionHeatmapService()

- (void) configureBeaconScanner;
- (void) stopReporter;
- (void) stopLogger;

@end

@implementation BRRelutionHeatmapService

- (id) initWithScanner: (BRIBeaconMessageScanner*) scanner andRelution: (BRRelution*) relution andIntervalDuration: (long long) intervalDurationInMs andTimeBetweenReportsInMs: (long long) timeBetweenReportsInMs andPollingTime: (long long) pollingTimeWaitForReceiverAvailableInMs {
    if (self = [super init]) {
        self->_scanner = scanner;
        self->_relution = relution;
        self->_intervalDurationInMs = intervalDurationInMs;
        self->_timeBetweenReportsInMs = timeBetweenReportsInMs;
        self->_pollingTimeWaitForReceiverAvailableInMs = pollingTimeWaitForReceiverAvailableInMs;
        
        // Stub sender
        //self->_sender = [[BRRelutionHeatmapSenderStub alloc] init];
        
        // Real sender
        self->_sender = [[BRRelutionHeatmapSender alloc] initWithRelution:relution];
    }
    return self;
}

- (void) start {
    // Scanner
    [self configureBeaconScanner];
    // Logger
    _logger = [[BRBeaconMessageLogger alloc] initWithSender:self->_scanner];
    // Reporter
    BRRelutionHeatmapReportBuilder* reportBuilder = [[BRRelutionHeatmapReportBuilder alloc] initWithOrganizationUuid:self->_relution.organizationUuid];
    [reportBuilder setIntervalDurationInMs:(long)self->_intervalDurationInMs];
    _reporter = [[BRBeaconMessageReporter alloc] initWithLogger:_logger andBuilder:reportBuilder andSender:self->_sender];
    [_reporter setTimeBetweenReportsInMs:(long)self->_timeBetweenReportsInMs];
    [_reporter setPollingTimeWaitForReceiverAvailableInMs:(long)self->_pollingTimeWaitForReceiverAvailableInMs];
    // Start reporting
    [_reporter startReporting];
}

- (void) stop {
    [self stopReporter];
    [self stopLogger];
}

- (void) stopReporter {
    [self->_reporter stopReporting];
}

- (void) stopLogger {
    // Nothing has to be stopped.
}

- (void) configureBeaconScanner {
    BRBeaconMessageScannerConfig* config = [self->_scanner config];
    [config scanJoinMeMessages];
}

@end
