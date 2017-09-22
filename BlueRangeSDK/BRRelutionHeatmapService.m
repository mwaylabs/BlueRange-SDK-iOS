//
//  BRRelutionHeatmapService.m
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
