//
//  BRRelutionHeatmapSender.m
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

#import "BRRelutionHeatmapSender.h"
#import "BRBeaconMessageReport.h"
#import "BRRelutionHeatmapReport.h"
#import "BRBeaconMessageReportSender.h"
#import "BRJsonUtils.h"
#import "BRRelution.h"


@implementation BRRelutionHeatmapSender

- (id) initWithRelution: (BRRelution*) relution {
    if (self = [super init]) {
        self->_relution = relution;
    }
    return self;
}

- /* override */ (BOOL) receiverAvailable {
    return [self->_relution isServerAvailable];
}

- /* override */ (void) sendReport: (id<BRBeaconMessageReport>) report {
    NSObject *reportObject = (NSObject*)report;
    if ([reportObject isKindOfClass:[BRRelutionHeatmapReport class]]) {
        BRRelutionHeatmapReport* relutionHeatmapReport = (BRRelutionHeatmapReport*)report;
        NSDictionary* jsonReport = [relutionHeatmapReport jsonReport];
        @try {
            [self->_relution sendAnalyticsReport:jsonReport];
        } @catch (NSException* e) {
            @throw [BRSendReportException exceptionWithName:@"" reason:@"" userInfo:nil];
        }
    }
}

@end
