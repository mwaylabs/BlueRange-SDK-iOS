//
//  BRRelutionHeatmapReportBuilderTest.m
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

#import <XCTest/XCTest.h>
#import "BRRelutionHeatmapReportBuilder.h"
#import "BRBeaconJoinMeMessage.h"
#import "BRRelutionHeatmapReport.h"
#import "BRJsonUtils.h"
#import <objc/runtime.h>

@interface BRRelutionHeatmapReportBuilderTest : XCTestCase

@property BRRelutionHeatmapReportBuilder* builder;

@end

@implementation BRRelutionHeatmapReportBuilderTest

- (void)setUp {
    [super setUp];
    self.builder = [[BRRelutionHeatmapReportBuilder alloc] initWithOrganizationUuid:@"cc6fe26f-64ad-443a-b3d5-8474fe1c8577"];
    // Initial builder configuration
    [self.builder setIntervalDurationInMs:30000];
}

- (void)tearDown {
    [super tearDown];
}

- (void) testBuildResultWithOneJoinMeMessage {
    // Start new report
    [self.builder newReport];
    // Add messages
    [self addArbitraryJoinMeMessage:[NSDate dateWithTimeIntervalSince1970:0] andRssi:-50];
    // Build report
    BRRelutionHeatmapReport* actualReport = [self.builder buildReport];
    // Verify report
    NSDictionary* expectedReport =
    @{
      @"organizationUUID": @"cc6fe26f-64ad-443a-b3d5-8474fe1c8577",
      @"report": @[
              @{
                  @"discoveredNodes": @[
                          @{
                              @"avgRssi": @"-50",
                              @"nodeId": @0,
                              @"packetCount": @1
                              }
                          ],
                  @"endTime": @0,
                  @"startTime": @0
                  }
              ]
    };
    [self verifyReport:actualReport andExpectedJson:expectedReport];
}

- (void) addArbitraryJoinMeMessage: (NSDate*) date andRssi: (int) rssi {
    BRBeaconJoinMeMessage* message = [self createArbitraryJoinMeMessage: date andRssi: rssi];
    [self.builder addBeaconMessage:message];
}

- (BRBeaconJoinMeMessage*) createArbitraryJoinMeMessage: (NSDate*) date andRssi: (int) rssi {
    int sender = 0;
    int networkId = 0;
    long clusterId = 0;
    short clusterSize = 0;
    short freeInConnections = 0;
    short freeOutConnections = 0;
    short batteryRuntime = 0;
    short txPower = 0;
    short deviceType = 0;
    int hopsToSink = 0;
    int meshWriteHandle = 0;
    int ackField = 0;
    BRBeaconJoinMeMessage* message = [[BRBeaconJoinMeMessage alloc] initWithDate:date andNetworkId:networkId andSender:sender andClusterId:clusterId andClusterSize:clusterSize andFreeInConnections:freeInConnections andFreeOutConnections:freeOutConnections andBatteryRuntime:batteryRuntime andTxPower:txPower andDeviceType:deviceType andHopsToSink:hopsToSink andMeshWriteHandle:meshWriteHandle andAckField: ackField andRssi:rssi];
    return message;
}

- (void) verifyReport: (BRRelutionHeatmapReport*) actualReport andExpectedJson: (NSDictionary*) expectedJson {
    NSDictionary* actualJsonReport = [actualReport jsonReport];
    NSDictionary* expectedJsonObject = expectedJson;
    XCTAssertTrue(areEqual(expectedJsonObject, actualJsonReport));
    NSLog(@"%@", actualJsonReport);
}

BOOL areEqual(NSObject* a, NSObject* b) {
    
    unsigned int count = 0, i;
    objc_property_t *props = class_copyPropertyList([b class], &count);
    for (i=0; i<count; ++i) {
        objc_property_t property = props[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        
        id aValue = [a valueForKey: name];
        id bValue = [b valueForKey: name];
        
        if ([aValue isKindOfClass: [a class]]) {
            if (!areEqual((id)aValue, (id)bValue)) {
                return NO;
            }
        } else {
            if (![aValue isEqual: bValue]) {
                return NO;
            }
        }
    }
    return YES;
}

@end
