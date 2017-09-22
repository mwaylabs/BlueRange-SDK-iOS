//
//  BlueRangeSDK.h
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

#import <UIKit/UIKit.h>

//! Project version number for BlueRangeSDK.
FOUNDATION_EXPORT double BlueRangeSDKVersionNumber;

//! Project version string for BlueRangeSDK.
FOUNDATION_EXPORT const unsigned char BlueRangeSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <BlueRangeSDK/PublicHeader.h>

// Common
#import <BlueRangeSDK/BRConstants.h>

// Advertising
#import <BlueRangeSDK/BRBeaconAdvertiser.h>

// Averaging
#import <BlueRangeSDK/BRMovingAverageFilter.h>
#import <BlueRangeSDK/BRSimpleMovingAverageFilter.h>
#import <BlueRangeSDK/BRLinearWeightedMovingAverageFilter.h>
#import <BlueRangeSDK/BRBeaconMessageAggregate.h>
#import <BlueRangeSDK/BRBeaconMessageAggregator.h>
#import <BlueRangeSDK/BRBeaconMessagePacketAggregate.h>
#import <BlueRangeSDK/BRBeaconMessageSlidingWindowAggregate.h>

// Distancing
#import <BlueRangeSDK/BRDistanceEstimator.h>
#import <BlueRangeSDK/BRAnalyticalDistanceEstimator.h>
#import <BlueRangeSDK/BREmpiricalDistanceEstimator.h>

// Filtering
#import <BlueRangeSDK/BRBeaconMessageFilter.h>
#import <BlueRangeSDK/BRIBeaconMessageFilter.h>
#import <BlueRangeSDK/BRRelutionTagMessageFilter.h>

// Logging
#import <BlueRangeSDK/BRBeaconMessageLog.h>
#import <BlueRangeSDK/BRBeaconMessagePersistor.h>
#import <BlueRangeSDK/BRLogIterator.h>
#import <BlueRangeSDK/BRBeaconMessageLogger.h>
#import <BlueRangeSDK/BRBeaconMessagePersistorImpl.h>
#import <BlueRangeSDK/BRBeaconMessagePersistorImplLogIterator.h>

// Reporting
#import <BlueRangeSDK/BRBeaconMessageReport.h>
#import <BlueRangeSDK/BRBeaconMessageReportBuilder.h>
#import <BlueRangeSDK/BRBeaconMessageReporter.h>
#import <BlueRangeSDK/BRBeaconMessageReportSender.h>

// Streaming
#import <BlueRangeSDK/BRBeaconMessageStreamNode.h>
#import <BlueRangeSDK/BRBeaconMessageStreamNodeReceiver.h>
#import <BlueRangeSDK/BRBeaconMessageStreamNodeDefaultReceiver.h>
#import <BlueRangeSDK/BRBeaconMessagePassingStreamNode.h>
#import <BlueRangeSDK/BRBeaconMessageQueuedStreamNode.h>

// Scanning
#import <BlueRangeSDK/BRIBeaconMessageScannerImpl.h>
#import <BlueRangeSDK/BRDefaultBeaconMessageScannerImpl.h>
#import <BlueRangeSDK/BRBeaconMessageScanner.h>
#import <BlueRangeSDK/BRBeaconMessageScannerConfig.h>
#import <BlueRangeSDK/BRBeaconMessageScannerImpl.h>
#import <BlueRangeSDK/BRIBeaconMessageScanner.h>
#import <BlueRangeSDK/BRBeaconMessageScannerSimulator.h>

// Messages
#import <BlueRangeSDK/BRBeaconMessageGenerator.h>
#import <BlueRangeSDK/BRBeaconJoinMeMessage.h>
#import <BlueRangeSDK/BRBeaconJoinMeMessageGenerator.h>
#import <BlueRangeSDK/BRIBeaconMessage.h>
#import <BlueRangeSDK/BRIBeacon.h>
#import <BlueRangeSDK/BRIBeaconMessageGenerator.h>
#import <BlueRangeSDK/BREddystoneMessage.h>
#import <BlueRangeSDK/BREddystoneMessageGenerator.h>
#import <BlueRangeSDK/BREddystoneUidMessage.h>
#import <BlueRangeSDK/BREddystoneUidMessageGenerator.h>
#import <BlueRangeSDK/BREddystoneUrlMessage.h>
#import <BlueRangeSDK/BREddystoneUrlMessageGenerator.h>
#import <BlueRangeSDK/BRRelutionTagMessage.h>
#import <BlueRangeSDK/BRRelutionTagMessageGenerator.h>
#import <BlueRangeSDK/BRRelutionTagMessageV1.h>
#import <BlueRangeSDK/BRRelutionTagMessageGeneratorV1.h>
#import <BlueRangeSDK/BRBeaconMessage.h>

// Triggering
#import <BlueRangeSDK/BRBeaconContentAction.h>
#import <BlueRangeSDK/BRBeaconContentActionBuilder.h>
#import <BlueRangeSDK/BRBeaconContentActionExecutor.h>
#import <BlueRangeSDK/BRBeaconContentActionListener.h>

#import <BlueRangeSDK/BRBeaconNotificationAction.h>
#import <BlueRangeSDK/BRBeaconNotificationActionBuilder.h>
#import <BlueRangeSDK/BRBeaconNotificationExecutor.h>
#import <BlueRangeSDK/BRBeaconNotificationListener.h>

#import <BlueRangeSDK/BRBeaconTagAction.h>
#import <BlueRangeSDK/BRBeaconTagActionBuilder.h>
#import <BlueRangeSDK/BRBeaconTagActionExecutor.h>
#import <BlueRangeSDK/BRBeaconTagActionListener.h>
#import <BlueRangeSDK/BRBeaconTagVisit.h>

#import <BlueRangeSDK/BRBeaconMessageActionMapper.h>
#import <BlueRangeSDK/BRRelutionTagMessageActionMapper.h>
#import <BlueRangeSDK/BRBeaconMessageActionMapperStub.h>
#import <BlueRangeSDK/BRRelutionTagMessageActionMapperEmptyStub.h>
#import <BlueRangeSDK/BRIBeaconMessageActionMapperStub.h>

#import <BlueRangeSDK/BRBeaconActionLocker.h>
#import <BlueRangeSDK/BRRunningFlag.h>

#import <BlueRangeSDK/BRBeaconAction.h>
#import <BlueRangeSDK/BRBeaconCampaign.h>
#import <BlueRangeSDK/BRBeaconActionDebugListener.h>
#import <BlueRangeSDK/BRBeaconActionListener.h>
#import <BlueRangeSDK/BRRelutionActionInformation.h>
#import <BlueRangeSDK/BRBeaconActionBuilder.h>
#import <BlueRangeSDK/BRBeaconActionExecutor.h>
#import <BlueRangeSDK/BRBeaconActionRegistry.h>
#import <BlueRangeSDK/BRBeaconMessageActionTrigger.h>

// Service
#import <BlueRangeSDK/BRRelutionIoTService.h>

// Analytics
#import <BlueRangeSDK/BRRelutionHeatmapReport.h>
#import <BlueRangeSDK/BRRelutionHeatmapReportBuilder.h>
#import <BlueRangeSDK/BRRelutionHeatmapSender.h>
#import <BlueRangeSDK/BRRelutionHeatmapSenderStub.h>
#import <BlueRangeSDK/BRRelutionHeatmapService.h>

// Campaigns
#import <BlueRangeSDK/BRRelutionIBeaconMessageActionMapper.h>
#import <BlueRangeSDK/BRRelutionCampaignService.h>

// Configuration
#import <BlueRangeSDK/BRRelutionScanConfigLoader.h>
#import <BlueRangeSDK/BRRelutionScanConfigLoaderImpl.h>
#import <BlueRangeSDK/BRRelutionScanConfigLoaderStub.h>

// BRRelution
#import <BlueRangeSDK/BRRelution.h>

// Tags
#import <BlueRangeSDK/BRRelutionTagInfo.h>
#import <BlueRangeSDK/BRRelutionTagInfoRegistry.h>
#import <BlueRangeSDK/BRRelutionTagInfoRegistryImpl.h>
#import <BlueRangeSDK/BRRelutionTagInfoRegistryStub.h>

// Trigger
#import <BlueRangeSDK/BRBeaconTrigger.h>

// IO
#import <BlueRangeSDK/BRFileAccessor.h>
#import <BlueRangeSDK/BRFileAccessorImpl.h>
#import <BlueRangeSDK/BRZipCompression.h>

// Time
#import <BlueRangeSDK/BRTimeFormatter.h>

// BRNetwork
#import <BlueRangeSDK/BRNetwork.h>
#import <BlueRangeSDK/BRHttpClient.h>
#import <BlueRangeSDK/BRBluetooth.h>

// Math
#import <BlueRangeSDK/BRCoreMath.h>

// Logging
#import <BlueRangeSDK/BRITracer.h>
#import <BlueRangeSDK/BRTracer.h>

// Lang
#import <BlueRangeSDK/BRAbstract.h>

// Structs
#import <BlueRangeSDK/BRByteArrayParser.h>
#import <BlueRangeSDK/BRJsonUtils.h>
#import <BlueRangeSDK/BRLimitedSizeQueue.h>
#import <BlueRangeSDK/BRByteArrayConverter.h>

