//
//  BRIBeaconMessageScannerImpl.m
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

#import "BRIBeaconMessageScannerImpl.h"
#import "BRConstants.h"
#import "BRIBeaconMessage.h"
#import "BRIBeaconMessageGenerator.h"
#import "BRTracer.h"
#import <CoreLocation/CoreLocation.h>

static NSString* IBEACON_SCANNER_IMPL_LOG_TAG = @"BRIBeaconMessageScannerImpl";

// Private methods
@interface BRIBeaconMessageScannerImpl()

- (NSString*) uniqueString;

@end

@implementation BRIBeaconMessageScannerImpl

- (id) initWithTracer: (id<BRITracer>) tracer {
    if (self = [super init]) {
        // Tracing
        self->_tracer = tracer;
        
        // Filtering
        self->_messageGenerators = [[NSMutableArray alloc] init];
        
        // Configure location manager.
        self->_locationManager = [[CLLocationManager alloc] init];
        self->_locationManager.delegate = self;
        [self->_locationManager requestAlwaysAuthorization];
    }
    return self;
}

- (void) addMessageGenerator: (BRIBeaconMessageGenerator*) messageGenerator {
    @synchronized (self) {
        [self->_messageGenerators addObject:messageGenerator];
    }
}

- (void) setObserver: (id<BRBeaconMessageScannerImplObserver>) observer
{
    self->_observer = observer;
}

-(void)startScanning {
    @synchronized (self) {
        // Start scanning each iBeacon.
        for (BRIBeaconMessageGenerator* messageGenerator in self->_messageGenerators) {
            CLBeaconRegion* beaconRegion = [self getRegionForGenerator:messageGenerator];
            //This allows us to monitor the region in the foreground or background
            //[self.locationmanager startMonitoringForRegion:self.beaconRegion];
            //If we want additional proximity detection for iBeacons, we can use this call (only in foreground)
            [self->_locationManager startRangingBeaconsInRegion:beaconRegion];
        }
    }
}

- (CLBeaconRegion*) getRegionForGenerator: (BRIBeaconMessageGenerator*) generator {
    NSUUID *uuid = generator.uuid;
    int major = generator.major;
    int minor = generator.minor;
    NSString *identifier = [self uniqueString];
    CLBeaconRegion *beaconRegion = nil;
    if ([generator majorFilteringEnabled] && [generator minorFilteringEnabled]) {
        beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:identifier];
    } else if ([generator majorFilteringEnabled]) {
        beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major identifier:identifier];
    } else {
        beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:identifier];
    }
    
    return beaconRegion;
}

- (NSString *)uniqueString {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge_transfer NSString *)uuidStringRef;
}

// After this call, we have the appropriate permissions
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [[BRTracer getInstance] logDebugWithTag:IBEACON_SCANNER_IMPL_LOG_TAG andMessage:@"Auth status changed"];
    if(status > 3){
        // Check if we have to start monitoring beacons
        [[BRTracer getInstance] logDebugWithTag:IBEACON_SCANNER_IMPL_LOG_TAG andMessage:@"Do we need to initialise after auth given?"];
        //[self initialiseLocations];
    }
}

//What should happen on region enter? This is also called in the background
-(void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    
}

//Region exit
-(void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    
}

- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    for (CLBeacon *beacon in beacons) {
        BRIBeaconMessageGenerator* matchingGenerator = nil;
        
        @synchronized (self) {
            for (BRIBeaconMessageGenerator* messageGenerator in self->_messageGenerators) {
                if ([messageGenerator matches:beacon]) {
                    matchingGenerator = messageGenerator;
                    break;
                }
            }
        }
        
        if (matchingGenerator != nil) {
            // If the RSSI could not be determined (rssi = 0), we discard this message.
            if ((int)beacon.rssi != 0) {
                BRIBeaconMessage *beaconMessage = [[BRIBeaconMessage alloc]
                                                 initWithUUID:beacon.proximityUUID major:[beacon.major intValue]
                                                 minor:[beacon.minor intValue]
                                                 rssi: (int)beacon.rssi];
                [self->_observer onBeaconMessageUpdate:beaconMessage];
                //NSLog(@"iBeacon");
            }
        }
    }
}

//Error handling
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [[BRTracer getInstance] logDebugWithTag:IBEACON_SCANNER_IMPL_LOG_TAG andMessage:@"Failed monitoring region"];
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[BRTracer getInstance] logDebugWithTag:IBEACON_SCANNER_IMPL_LOG_TAG andMessage:@"Error"];
}

- (void) stopScanning {
    @synchronized (self) {
        for (BRIBeaconMessageGenerator* messageGenerator in self->_messageGenerators) {
            CLBeaconRegion* beaconRegion = [self getRegionForGenerator:messageGenerator];
            [self->_locationManager stopRangingBeaconsInRegion:beaconRegion];
        }
        [self->_messageGenerators removeAllObjects];
    }
}

@end
