//
//  BRRelutionScanConfigLoaderImpl.m
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
