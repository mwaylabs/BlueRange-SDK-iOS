//
//  BRRelutionHeatmapService.h
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

@class BRIBeaconMessageScanner;
@class BRBeaconMessageReporter;
@class BRBeaconMessageLogger;
@class BRRelution;
@protocol BRBeaconMessageReportSender;

/**
 * This class periodically sends status reports to Relution. The reports contain the received
 * signal strength of all beacons for all time intervals, since this service has been started.
 * Each time interval has a maximum duration of 3 seconds. A report will be sent, whenever the
 * 50th Join me message was received or no beacon has been detected in the last 5 seconds.
 */
@interface BRRelutionHeatmapService : NSObject {
    
    // Relution
    BRRelution* _relution;
    
    // Configuration
    long long _intervalDurationInMs;
    long long _timeBetweenReportsInMs;
    long long _pollingTimeWaitForReceiverAvailableInMs;
    
    // Components
    BRIBeaconMessageScanner* _scanner;
    id<BRBeaconMessageReportSender> _sender;
    BRBeaconMessageLogger* _logger;
    BRBeaconMessageReporter* _reporter;
}

- (id) initWithScanner: (BRIBeaconMessageScanner*) scanner andRelution: (BRRelution*) relution andIntervalDuration: (long long) intervalDurationInMs andTimeBetweenReportsInMs: (long long) timeBetweenReportsInMs andPollingTime: (long long) pollingTimeWaitForReceiverAvailableInMs;
- (void) start;
- (void) stop;

@end
