//
//  BRRelutionScanConfigLoaderImpl.m
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

#import "BRRelutionScanConfigLoaderImpl.h"
#import "BRAdvertisingMessagesConfiguration.h"
#import "BRITracer.h"
#import "BRRelution.h"
#import "BRBeaconMessageScannerConfig.h"
#import "BRIBeaconMessageScanner.h"

// BRConstants
const long long DEFAULT_SYNC_FREQUENCY_IN_MS;
NSString* RELUTION_SCAN_CONFIG_LOADER_LOG_TAG = @"BRRelutionScanConfigLoaderImpl";

// Private methods
@interface BRRelutionScanConfigLoaderImpl()

- (void) startScannerConfigSynchronization;
- (void) trySynchronizeScanConfiguration;
- (void) waitUntilNextSynchronization;
- (void) synchronizeScanConfiguration;

- (void) synchronizeScanConfigWithRelution;
- (void) parseJSONArrayAndChangeScanConfig: (BRAdvertisingMessagesConfiguration*) configuration;
- (void) configRelutionTagMessages: (NSString*) relutionTagV2Namespace;
- (void) configIBeaconUuids: (NSArray*) iBeaconUuids;
- (void) configEddystoneNamespaces: (NSArray*) eddystoneNamespaces;

@end

@implementation BRRelutionScanConfigLoaderImpl

- (id) initWithTracer: (id<BRITracer>) tracer andRelution: (BRRelution*) relution
           andScanner: (BRIBeaconMessageScanner*) scanner andSyncFrequency: (long long) syncFrequencyMs {
    if (self = [super init]) {
        self->_tracer = tracer;
        self->_relution = relution;
        self->_scanner = scanner;
        self->_syncFrequencyMs = syncFrequencyMs;
    }
    return self;
}

- (void) start {
    self->_scannerConfigSynchronizationThread
        = [[NSThread alloc] initWithTarget:self selector:@selector(startScannerConfigSynchronization) object:nil];
    [self->_scannerConfigSynchronizationThread start];
}

- (void) startScannerConfigSynchronization {
    // Periodically update scanner's configuration.
    while (![self->_scannerConfigSynchronizationThread isCancelled]) {
        [self trySynchronizeScanConfiguration];
        [self waitUntilNextSynchronization];
    }
}

- (void) trySynchronizeScanConfiguration {
    @try {
        [self synchronizeScanConfiguration];
    } @catch (NSException* e) {
        [self->_tracer logWarningWithTag:RELUTION_SCAN_CONFIG_LOADER_LOG_TAG
                              andMessage:@"A problem occurred while synchronizing scan configuraiton."];
    }
}

- (void) waitUntilNextSynchronization {
   [NSThread sleepForTimeInterval:((double)_syncFrequencyMs) / 1000];
}

- (void) synchronizeScanConfiguration {
    [self synchronizeScanConfigWithRelution];
}

- (void) synchronizeScanConfigWithRelution {
    BRAdvertisingMessagesConfiguration* configuration = [self->_relution getAdvertisingMessagesConfiguration];
    [self parseJSONArrayAndChangeScanConfig:configuration];
}

- (void) parseJSONArrayAndChangeScanConfig: (BRAdvertisingMessagesConfiguration*) configuration {
    @try {
        NSArray* jsonArray = [configuration jsonArray];
        NSDictionary* result = [jsonArray objectAtIndex:0];
        
        NSString* relutionTagV2Namespace = [result objectForKey:@"relutionTagV2Namespace"];
        [self configRelutionTagMessages:relutionTagV2Namespace];
        
        NSArray* iBeaconUuids = [result objectForKey:@"iBeaconUuids"];
        [self configIBeaconUuids:iBeaconUuids];
        
        NSArray* eddystoneNamespaces = [result objectForKey:@"eddystoneNamespaces"];
        [self configEddystoneNamespaces:eddystoneNamespaces];
        
    } @catch (NSException* e) {
        [self->_tracer logWarningWithTag:RELUTION_SCAN_CONFIG_LOADER_LOG_TAG
                              andMessage:@"Error while parsing scan configuration."];
    }
}

- (void) configRelutionTagMessages: (NSString*) relutionTagV2Namespace {
    BRBeaconMessageScannerConfig* config = [self->_scanner config];
    [config scanRelutionTags:relutionTagV2Namespace];
}

- (void) configIBeaconUuids: (NSArray*) iBeaconUuids {
    NSMutableArray* uuids = [[NSMutableArray alloc] init];
    for (int i = 0; i < [iBeaconUuids count]; i++) {
        @try {
            NSString* iBeaconUuid = [iBeaconUuids objectAtIndex:i];
            [uuids addObject:iBeaconUuid];
        } @catch (NSException* e) {
            [self->_tracer logWarningWithTag:RELUTION_SCAN_CONFIG_LOADER_LOG_TAG
                                  andMessage:@"Error while parsing json array of iBeacon UUIDs."];
        }
    }
    BRBeaconMessageScannerConfig* config = [self->_scanner config];
    [config scanIBeaconUuids:uuids];
}

- (void) configEddystoneNamespaces: (NSArray*) eddystoneNamespaces {
    NSMutableArray* namespaces = [[NSMutableArray alloc] init];
    for (int i = 0; i < [eddystoneNamespaces count]; i++) {
        @try {
            NSString* namespaceUid = [eddystoneNamespaces objectAtIndex:i];
            [namespaces addObject:namespaceUid];
        } @catch (NSException* e) {
            [self->_tracer logWarningWithTag:RELUTION_SCAN_CONFIG_LOADER_LOG_TAG
                                  andMessage:@"Error while parsing json array of Eddystone namespaces."];
        }
    }
    BRBeaconMessageScannerConfig* config = [self->_scanner config];
    [config scanEddystoneUidWithNamespaces:namespaces];
}

- (void) stop {
    [self->_scannerConfigSynchronizationThread cancel];
}


@end
