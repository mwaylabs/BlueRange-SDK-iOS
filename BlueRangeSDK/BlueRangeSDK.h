//
//  BlueRangeSDK.h
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

