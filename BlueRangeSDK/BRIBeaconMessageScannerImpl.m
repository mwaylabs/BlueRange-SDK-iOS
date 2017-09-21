//
//  BRIBeaconMessageScannerImpl.m
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
