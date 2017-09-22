//
//  BRBeaconMessageReportBuilder.h
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

// Forward declarations
@class BRBeaconMessage;
@protocol BRBeaconMessageReport;

// Exception classes
@interface BRBuildException : NSException

@end

@interface BRNoMessagesException : NSException

@end

/**
 * An interface specifying a builder that constructs report from a stream of beacon messages
 * delivered by subsequently calling the {@link #addBeaconMessage} method.
 */
@protocol BRBeaconMessageReportBuilder

/**
 * Starts with a new report
 * @throws BRBuildException if an error occurred.
 */
- (void) newReport;

/**
 * A builder method that commands the builder to add the beacon message to the report.
 * @param message the message to be added.
 * @throws BRBuildException will be thrown, if an error occurred.
 */
- (void) addBeaconMessage: (BRBeaconMessage*) message;

/**
 * Returns a newly constructed report containing all added messages.
 * @return the newly consturcted beacon message report.
 * @throws BRBuildException will be thrown, if an error occurred.
 */
- (id<BRBeaconMessageReport>) buildReport;

@end
