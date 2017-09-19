//
//  BRRelutionIoTService.m
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

#import "BRRelutionIoTService.h"
#import "BRITracer.h"
#import "BRTracer.h"
#import "BRRelutionTagInfoRegistry.h"
#import "BRIBeaconMessageScanner.h"
#import "BRBeaconMessage.h"
#import "BRBeaconTagAction.h"
#import "BRBeaconContentAction.h"
#import "BRBeaconNotificationAction.h"
#import "BRRelutionTagMessage.h"
#import "BRBeaconMessageScannerSimulator.h"
#import "BRBeaconMessageScanner.h"
#import "BRRelutionTagMessage.h"
#import "BRBeaconMessageScannerConfig.h"
#import "BRRelutionCampaignService.h"
#import "BRBeaconActionDebugListener.h"
#import "BRBeaconTagActionListener.h"
#import "BRBeaconContentActionListener.h"
#import "BRBeaconNotificationListener.h"
#import "BRRelutionTagInfoRegistryImpl.h"
#import "BRBeaconAdvertiser.h"
#import "BRRelutionHeatmapService.h"
#import "BRRelution.h"
#import "BRRelutionScanConfigLoaderImpl.h"
#import "BRBeaconTrigger.h"

NSString* RELUTION_IOT_SERVICE_LOG_TAG = @"BRRelutionIoTService";

@interface BRRelutionIoTService()

// Starting
- (void) initTracing;
- (void) login;
- (BRIBeaconMessageScanner*) createScannerSimulator;
- (BRIBeaconMessageScanner*) createScanner;
- (void) startScanConfigLoader;
- (void) startReporter: (BRIBeaconMessageScanner*) scanner;
- (void) startTrigger: (BRIBeaconMessageScanner*) scanner;
- (void) startPolicyTrigger: (BRIBeaconMessageScanner*) scanner;
- (void) startScanner: (BRIBeaconMessageScanner*) scanner;
- (void) initRelutionTagRegistry: (BRIBeaconMessageScanner*) scanner;
- (void) startAdvertiser;

+ (void) publishLoginSucceeded;
+ (void) publishLoginFailed;
+ (void) publishLoginRelutionError;
+ (void) publishBeacons: (BRBeaconMessage*) beaconMessage;
+ (void) publishTagAction: (BRBeaconTagAction*) tagAction;
+ (void) publishTagActionExecuted: (BRBeaconTagAction*) tagAction;
+ (void) publishContentAction: (BRBeaconContentAction*) contentAction;
+ (void) publishContentActionExecuted: (BRBeaconContentAction*) contentAction;
+ (void) publishNotificationAction: (BRBeaconNotificationAction*) notificationAction;
+ (void) publishNotificationActionExecuted: (BRBeaconNotificationAction*) notificationAction;
+ (void) publishRelutionTag: (long) tag andMessage: (BRRelutionTagMessage*) message;
+ (void) publishBeaconActive;
+ (void) publishBeaconInactive;
+ (void) publishDistance: (float) distance;

// Stopping
- (void) stopWithoutRemovingObservers;
- (void) stopRelutionTagRegistry;
- (void) stopAdvertiser;
- (void) stopScanConfigLoader;
- (void) stopScanner;
- (void) stopTrigger;
- (void) stopPolicyTrigger;
- (void) stopReporter;

@end

@implementation BRRelutionIoTService

// Private static variables

static BOOL running = false;

static id<BRITracer> tracer = nil;
static BRRelution* relution = nil;

static NSString* baseUrl = nil;
static NSString* organizationUuid = nil;
static NSString* username = nil;
static NSString* password = nil;

static BOOL loggingEnabled = true;
static BOOL campaignActionTriggerEnabled = true;
static BOOL heatmapGenerationEnabled = true;
static BOOL sendingHeatmapReportsEnabled = true;
static BOOL policyTriggerEnabled = true;

static id<BRRelutionTagInfoRegistry> relutionTagInfoRegistry = nil;

static NSMutableArray* loginObservers;

static NSMutableArray* messageObservers;

static NSMutableArray* tagActionObservers;
static NSMutableArray* contentActionObservers;
static NSMutableArray* notificationActionObservers;

static NSMutableArray* tagActionDebugObservers;
static NSMutableArray* contentActionDebugObservers;
static NSMutableArray* notificationActionDebugObservers;

static NSMutableArray* relutionTagObservers;

static NSMutableArray* policyTriggerObservers;

// Methods

// Observer registrations

+ (void) addLoginObserver: (id<BRLoginObserver>) loginObserver {
    @synchronized (self) {
        [loginObservers addObject:loginObserver];
    }
}

+ (void) addBeaconMessageObserver: (id<BRBeaconMessageObserver>) observer {
    @synchronized(self) {
        [messageObservers addObject:observer];
    }
}

+ (void) addBeaconTagActionObserver: (id<BRBeaconTagActionObserver>) observer {
    @synchronized(self) {
        [tagActionObservers addObject:observer];
    }
}

+ (void) addBeaconContentActionObserver: (id<BRBeaconContentActionObserver>) observer {
    @synchronized(self) {
        [contentActionObservers addObject:observer];
    }
}

+ (void) addBeaconNotificationActionObserver: (id<BRBeaconNotificationActionObserver>) observer {
    @synchronized(self) {
        [notificationActionObservers addObject:observer];
    }
}

+ (void) addBeaconTagActionDebugObserver: (id<BRBeaconTagActionDebugObserver>) observer {
    @synchronized(self) {
        [tagActionDebugObservers addObject:observer];
    }
}

+ (void) addBeaconContentActionDebugObserver: (id<BRBeaconContentActionDebugObserver>) observer {
    @synchronized(self) {
        [contentActionDebugObservers addObject:observer];
    }
}

+ (void) addBeaconNotificationActionDebugObserver:(id<BRBeaconNotificationActionDebugObserver>)observer {
    @synchronized(self) {
        [notificationActionDebugObservers addObject:observer];
    }
}

+ (void) addRelutionTagObserver: (id<BRRelutionTagObserver>) observer {
    @synchronized(self) {
        [relutionTagObservers addObject:observer];
    }
}

+ (void) addPolicyTriggerObserver: (id<BRPolicyTriggerObserver>) observer {
    @synchronized(self) {
        [policyTriggerObservers addObject:observer];
    }
}

// Initialization

- (id) init {
    if (self = [super init]) {
        tracer = [BRTracer getInstance];
        loginObservers = [[NSMutableArray alloc] init];
        messageObservers = [[NSMutableArray alloc] init];
        tagActionObservers = [[NSMutableArray alloc] init];
        contentActionObservers = [[NSMutableArray alloc] init];
        notificationActionObservers = [[NSMutableArray alloc] init];
        tagActionDebugObservers = [[NSMutableArray alloc] init];
        contentActionDebugObservers = [[NSMutableArray alloc] init];
        notificationActionDebugObservers = [[NSMutableArray alloc] init];
        relutionTagObservers = [[NSMutableArray alloc] init];
        policyTriggerObservers = [[NSMutableArray alloc] init];
    }
    return self;
}

// Configuration
- (BRRelutionIoTService*) setLoginData: (NSString*) _baseUrl andUsername: (NSString*) _username
                         andPassword: (NSString*) _password andLoginObserver: (id<BRLoginObserver>) _loginObserver {
    baseUrl = _baseUrl;
    username = _username;
    password = _password;
    if (_loginObserver != nil) {
        [loginObservers removeAllObjects];
        [BRRelutionIoTService addLoginObserver:_loginObserver];
    }
    return self;
}

- (BRRelutionIoTService*) setLoggingEnabled: (BOOL) enabled {
    loggingEnabled = enabled;
    return self;
}

- (BRRelutionIoTService*) setCampaignActionTriggerEnabled: (BOOL) enabled {
    campaignActionTriggerEnabled = enabled;
    return self;
}

- (BRRelutionIoTService*) setHeatmapGenerationEnabled: (BOOL) enabled {
    heatmapGenerationEnabled = enabled;
    return self;
}

- (BRRelutionIoTService*) setHeatmapReportingEnabled: (BOOL) enabled {
    sendingHeatmapReportsEnabled = enabled;
    return self;
}

- (BRRelutionIoTService*) setPolicyTriggerEnabled: (BOOL) enabled {
    policyTriggerEnabled = enabled;
    return self;
}

// Starting and stopping

- (void) start {
    @try {
        if ([BRRelutionIoTService isRunning]) {
            [self stopWithoutRemovingObservers];
        }
        
        [self initTracing];
        [self login];
        [BRRelutionIoTService publishLoginSucceeded];
        //self->_scanner = [self createScannerSimulator];
        self->_scanner = [self createScanner];
        [self startScanConfigLoader];
        [self startReporter:_scanner];
        [self startTrigger:_scanner];
        [self startPolicyTrigger:_scanner];
        [self startScanner:_scanner];
        [self startAdvertiser];
        [self initRelutionTagRegistry:_scanner];
        
        running = true;
    } @catch (BRRelutionException* e) {
        [BRRelutionIoTService publishLoginRelutionError];
    } @catch (BRLoginException* e) {
        [BRRelutionIoTService publishLoginFailed];
    }
}

+ (BOOL) isRunning {
    return running;
}

- (void) login {
    relution = [[BRRelution alloc] initWithBaseUrl:baseUrl andUsername:username andPassword:password];
}

- (void) initTracing {
    [BRTracer setEnabled:loggingEnabled];
}

- (BRIBeaconMessageScanner*) createScannerSimulator {
    BRBeaconMessageScannerSimulator* scanner = [[BRBeaconMessageScannerSimulator alloc] init];
    
    // iBeacons
    [scanner simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:45 andMinor:1 andRssi:-75];
    [scanner simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"c9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:45 andMinor:1 andRssi:-75];
    [scanner simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"92407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:45 andMinor:1 andRssi:-82];
    [scanner simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"29407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:45 andMinor:1 andRssi:-15];
    [scanner simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:45 andMinor:1 andRssi:-15];
    [scanner simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"95407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:45 andMinor:1 andRssi:-15];
    [scanner simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"49407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:45 andMinor:1 andRssi:-55];
    [scanner simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"7e76f413-f309-45e7-9641-4f9f35099757"] andMajor:45 andMinor:1 andRssi:-55];
    
    // Delayed notifications
    [scanner simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"19407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:45 andMinor:1 andRssi:-50];
    [scanner simulateIBeaconWithUuid:[[NSUUID alloc] initWithUUIDString:@"94407f30-f5f8-466e-aff9-25556b57fe6d"] andMajor:45 andMinor:1 andRssi:-10];
    
    // Eddystone
    [scanner simulateEddystoneUidWithNamespace:@"65AC11A8F8C51FF6476F" andInstanceId: @"1234" andRssi: -25];
    [scanner simulateEddystoneUrl:@"http://google.de" andRssi:-34];
    
    // Join me messages
    [scanner simulateJoinMeWithNodeId:9999 andRssi:-45];
    [scanner simulateJoinMeWithNodeId:1010 andRssi:-75];
    
    // BRRelution tag messages
    [scanner simulateRelutionTagsV1:@[[NSNumber numberWithLong:1], [NSNumber numberWithLong:2]]];
    
    // BRRelution tag V2 messages
    [scanner simulateRelutionTagsWithNamespaceUid:@"65AC11A8F8C51FF6476F" andTags:@[[NSNumber numberWithLong:3], [NSNumber numberWithLong:4]]];
    [scanner simulateRelutionTagsWithNamespaceUid:@"75AC11A8F8C51FF6476F" andTags:@[[NSNumber numberWithLong:10], [NSNumber numberWithLong:20]] andRssi:-44];
    
    [scanner setRepeat:true];
    //[scanner setRepeatInterval:20000L];
    [scanner setRepeatInterval:2000L];
    [scanner addRssiNoise];
    [scanner addReceiver:self];
    
    return scanner;
}

- (BRIBeaconMessageScanner*) createScanner {
    self->_scanner = [[BRBeaconMessageScanner alloc] initWithTracer:tracer];
    [self->_scanner addReceiver:self];
    BRBeaconMessageScannerConfig *config = self->_scanner.config;
    [config scanIBeacon:@"b9407f30-f5f8-466e-aff9-25556b57fe6d" major:45 minor:1];
    [config scanIBeacon:@"94407f30-f5f8-466e-aff9-25556b57fe6d" major:45 minor:1];
    //[config scanIBeacon:@"6fe5ab86-4ca9-4b83-beec-298306b8bb37" major:1 minor:1];
    [config scanJoinMeMessages];
    
    // BRRelution Tag messages V1
    //[config scanRelutionTagsV1:@[[NSNumber numberWithLong:1], [NSNumber numberWithLong:2]]];
    [config scanRelutionTagsV1];
    
    // BRRelution Tag messages V2
    //[config scanRelutionTags:@"00010203040506070809"];
    //[config scanRelutionTags:@"00010203040506070809" andTags: @[[NSNumber numberWithLong:66], [NSNumber numberWithLong:55]] ];
    
    // By default, we scan all Eddystone URL messages.
    [config scanEddystoneUrls];
    
    //[config scanEddystoneUrl:@"http://goo.gl/HaUfdz"];
    //[config scanEddystoneUrl:@"http://gooo.gl/HaUfdz"];
    //[config scanEddystoneUrls];
    
    //[config scanEddystoneUid];
    //[config scanEddystoneUidWithNamespace:@"65AC11A8F8C51FF6476F"];
    //[config scanEddystoneUidWithNamespace:@"00010203040506070809"];
    //[config scanEddystoneUidWithNamespace:@"00010203040506070809" andInstanceId:@"1F2A"];
    //[config scanEddystoneUidWithNamespace:@"00010203040506070809" andInstanceId:@"1F2B"];
    //[config scanEddystoneUidWithNamespace:@"65AC11A8F8C51FF6476F" andInstanceId:@"13037496146791"];
    
    return self->_scanner;
}

- (void) startScanConfigLoader {
    _scanConfigLoader = [[BRRelutionScanConfigLoaderImpl alloc] initWithTracer:tracer andRelution:relution andScanner:_scanner andSyncFrequency:10000l];
    [_scanConfigLoader start];
}

- (void) startReporter: (BRIBeaconMessageScanner*) scanner {
    if (sendingHeatmapReportsEnabled) {
        long long reporterIntervalDurationInStatusReportsInMs = 3000L;
        long long reporterTimeBetweenStatusReportsInMs = 30000L;
        long long reporterPollingTimeToWaitForReceiverInMs = 60000L;
        
        self->_heatmapService = [[BRRelutionHeatmapService alloc]
                                initWithScanner:self->_scanner
                                andRelution: relution
                                andIntervalDuration:reporterIntervalDurationInStatusReportsInMs
                                andTimeBetweenReportsInMs:reporterTimeBetweenStatusReportsInMs
                                andPollingTime:reporterPollingTimeToWaitForReceiverInMs];
        [self->_heatmapService start];
    }
}

- (void) startTrigger: (BRIBeaconMessageScanner*) scanner {
    if (campaignActionTriggerEnabled) {
        self->_triggerService
            = [[BRRelutionCampaignService alloc] initWithScanner:_scanner andRelution:relution];
        [self->_triggerService addDebugActionListener:self];
        [self->_triggerService addActionListener:self];
        [self->_triggerService start];
    }
}

- (void) startPolicyTrigger: (BRIBeaconMessageScanner*) scanner {
    if (policyTriggerEnabled) {
        _policyTrigger = [[BRBeaconTrigger alloc] initWithTracer:tracer andScanner:scanner];
        [_policyTrigger addRelutionTagTrigger:1L];
        [_policyTrigger addRelutionTagTrigger:2L];
        [_policyTrigger addRelutionTagTrigger:3L];
        [_policyTrigger addRelutionTagTrigger:4L];
        [_policyTrigger addRelutionTagTrigger:5L];
        [_policyTrigger addObserver:self];
    }
}

- (void) onBeaconActive: (BRBeaconMessage*) message {
    [BRRelutionIoTService publishBeaconActive];
}

- (void) onBeaconInactive: (BRBeaconMessage*) message {
    [BRRelutionIoTService publishBeaconInactive];
}

- (void) onNewDistance: (BRBeaconMessage*) message distance: (float) distance {
    [BRRelutionIoTService publishDistance:distance];
}

- (void) startScanner: (BRIBeaconMessageScanner*) scanner {
    [scanner startScanning];
}

- (void) initRelutionTagRegistry: (BRIBeaconMessageScanner*) scanner {
    relutionTagInfoRegistry = [[BRRelutionTagInfoRegistryImpl alloc] initWithRelution:relution andScanner:self->_scanner];
    [relutionTagInfoRegistry continuouslyUpdateRegistry];
}

- (void) startAdvertiser {
    if (heatmapGenerationEnabled) {
        @try {
            self->_advertiser = [[BRBeaconAdvertiser alloc] init];
            [self->_advertiser startAdvertisingDiscoveryMessage];
        } @catch (NSException* e) {
            [tracer logDebugWithTag:RELUTION_IOT_SERVICE_LOG_TAG
                         andMessage:@"An unknown problem occurred when starting the advertiser."];
        }
    }
}

// Publishing

- /* override */ (void) onMeshActive: (BRBeaconMessageStreamNode *) senderNode {
    // Empty implementation
}

- /* override */ (void) onReceivedMessage: (BRBeaconMessageStreamNode *) senderNode withMessage: (BRBeaconMessage*) message {
    // Publish all messages
    [BRRelutionIoTService publishBeacons:message];
    
    // Publish Relution Tag messages
    if ([message isKindOfClass:[BRRelutionTagMessage class]]) {
        BRRelutionTagMessage* relutionTagMessage = (BRRelutionTagMessage*)message;
        NSArray* tags = [relutionTagMessage tags];
        for (NSNumber* tag in tags) {
            [BRRelutionIoTService publishRelutionTag:[tag longValue] andMessage:relutionTagMessage];
        }
    }
}

- /* override */ (void) onMeshInactive: (BRBeaconMessageStreamNode *) senderNode {
    // Empty implementation
}

- /* override */ (void) onActionExecutionStarted: (BRBeaconAction*) action {
    if ([action isKindOfClass:[BRBeaconTagAction class]]) {
        BRBeaconTagAction *tagAction = (BRBeaconTagAction*)action;
        [tracer logDebugWithTag:RELUTION_IOT_SERVICE_LOG_TAG andMessage:@"Visited tag"];
        [BRRelutionIoTService publishTagAction:tagAction];
    } else if ([action isKindOfClass:[BRBeaconContentAction class]]) {
        BRBeaconContentAction* contentAction = (BRBeaconContentAction*)action;
        [tracer logDebugWithTag:RELUTION_IOT_SERVICE_LOG_TAG andMessage:@"Received content"];
        [BRRelutionIoTService publishContentAction:contentAction];
    } else if ([action isKindOfClass:[BRBeaconNotificationAction class]]) {
        BRBeaconNotificationAction* notificationAction = (BRBeaconNotificationAction*)action;
        [tracer logDebugWithTag:RELUTION_IOT_SERVICE_LOG_TAG andMessage:@"Notification received"];
        [BRRelutionIoTService publishNotificationAction:notificationAction];
    }
}

- /* override */ (void) onActionTriggered: (BRBeaconContentAction*) contentAction {
    [tracer logDebugWithTag:RELUTION_IOT_SERVICE_LOG_TAG andMessage:@"Received content"];
    [BRRelutionIoTService publishContentActionExecuted:contentAction];
}

- /* override */ (void) onTagVisited: (BRBeaconTagAction*) tagAction {
    [tracer logDebugWithTag:RELUTION_IOT_SERVICE_LOG_TAG andMessage:@"Visited tag"];
    [BRRelutionIoTService publishTagActionExecuted:tagAction];
}

- /* override */ (void) onNotificationActionTriggered: (BRBeaconNotificationAction*) notificationAction {
    [tracer logDebugWithTag:RELUTION_IOT_SERVICE_LOG_TAG andMessage:@"Notification received"];
    [BRRelutionIoTService publishNotificationActionExecuted:notificationAction];
}

+ (void) publishLoginSucceeded {
    @synchronized (self) {
        for (id<BRLoginObserver> observer in loginObservers) {
            [observer onLoginSucceeded];
        }
    }
}

+ (void) publishLoginFailed {
    @synchronized (self) {
        for (id<BRLoginObserver> observer in loginObservers) {
            [observer onLoginFailed];
        }
    }
}

+ (void) publishLoginRelutionError {
    @synchronized (self) {
        for (id<BRLoginObserver> observer in loginObservers) {
            [observer onRelutionError];
        }
    }
}

+ (void) publishBeacons: (BRBeaconMessage*) beaconMessage {
    @synchronized(self) {
        for (id<BRBeaconMessageObserver> observer in messageObservers) {
            [observer onMessageReceived:beaconMessage];
        }
    }
}

+ (void) publishTagAction: (BRBeaconTagAction*) tagAction {
    @synchronized(self) {
        for (id<BRBeaconTagActionDebugObserver> observer in tagActionDebugObservers) {
            [observer onTagActionReceived:tagAction];
        }
    }
}

+ (void) publishTagActionExecuted: (BRBeaconTagAction*) tagAction {
    @synchronized(self) {
        for (id<BRBeaconTagActionObserver> observer in tagActionObservers) {
            [observer onTagActionExecuted:tagAction];
        }
    }
}

+ (void) publishContentAction: (BRBeaconContentAction*) contentAction {
    @synchronized(self) {
        for (id<BRBeaconContentActionDebugObserver> observer in contentActionDebugObservers) {
            [observer onContentActionReceived:contentAction];
        }
    }
}

+ (void) publishContentActionExecuted: (BRBeaconContentAction*) contentAction {
    @synchronized(self) {
        for (id<BRBeaconContentActionObserver> observer in contentActionObservers) {
            [observer onContentActionExecuted:contentAction];
        }
    }
}

+ (void) publishNotificationAction: (BRBeaconNotificationAction*) notificationAction {
    @synchronized(self) {
        for (id<BRBeaconNotificationActionDebugObserver> observer in notificationActionDebugObservers) {
            [observer onNotificationActionReceived:notificationAction];
        }
    }
}

+ (void) publishNotificationActionExecuted: (BRBeaconNotificationAction*) notificationAction {
    @synchronized(self) {
        for (id<BRBeaconNotificationActionObserver> observer in notificationActionObservers) {
            [observer onNotificationActionExecuted:notificationAction];
        }
    }
}

+ (void) publishRelutionTag: (long) tag andMessage: (BRRelutionTagMessage*) message {
    @synchronized(self) {
        for (id<BRRelutionTagObserver> observer in relutionTagObservers) {
            [observer onTagReceived:tag message:message];
        }
    }
}

+ (void) publishBeaconActive {
    @synchronized (self) {
        for (id<BRPolicyTriggerObserver> observer in policyTriggerObservers) {
            [observer onBeaconActive];
        }
    }
}

+ (void) publishBeaconInactive {
    @synchronized (self) {
        for (id<BRPolicyTriggerObserver> observer in policyTriggerObservers) {
            [observer onBeaconInactive];
        }
    }
}

+ (void) publishDistance: (float) distance {
    @synchronized (self) {
        for (id<BRPolicyTriggerObserver> observer in policyTriggerObservers) {
            [observer onNewDistance:distance];
        }
    }
}


// Requests
+ (BRRelutionTagInfo*) getTagInfoForTag: (long) tag {
    BRRelutionTagInfo* relutionTagInfo = [relutionTagInfoRegistry getRelutionTagInfoForTag:tag];
    return relutionTagInfo;
}

/**
 * Changes the txPower field of an iBeacon message assigned to a beacon in Relution. This
 * method can be used to calibrate an iBeacon message for the assigned beacon in order
 * to improve distance estimation used e.g. in campaign actions that make use of a distance threshold.
 * @param iBeacon The iBeacon which should be calibrated.
 * @param txPower The txPower field, which is the same as the received signal strength (RSSI)
 *                at one meter distance away from the beacon.
 */
+ (void) calibrateIBeacon: (BRIBeacon*) iBeacon withTxPower: (float) txPower {
    NSString* message = [NSString stringWithFormat:@"Calibrate iBeacon with UUID %@ and RSSI %f", iBeacon.uuid.UUIDString, txPower];
    [tracer logDebugWithTag:RELUTION_IOT_SERVICE_LOG_TAG andMessage:message];
    @try {
        [relution sendCalibratedRssiForIBeacon:iBeacon andCalibratedRssi:(int)txPower];
    } @catch (NSException* e) {
        [tracer logDebugWithTag:RELUTION_IOT_SERVICE_LOG_TAG andMessage:@"Calibrating txPower failed."];
    }
}

+ (NSString*) getOrganizationUuid {
    return [relution organizationUuid];
}

+ (NSString*) getUsername {
    return username;
}

+ (NSString*) getHostname {
    return baseUrl;
}

- (void) stop {
    [self stopWithoutRemovingObservers];
    
    // Remove observers
    [loginObservers removeAllObjects];
    
    [messageObservers removeAllObjects];
    
    [tagActionObservers removeAllObjects];
    [contentActionObservers removeAllObjects];
    [notificationActionObservers removeAllObjects];
    
    [tagActionDebugObservers removeAllObjects];
    [contentActionDebugObservers removeAllObjects];
    [notificationActionDebugObservers removeAllObjects];
    
    [relutionTagObservers removeAllObjects];
    [policyTriggerObservers removeAllObjects];
}

- (void) stopWithoutRemovingObservers {
    if ([BRRelutionIoTService isRunning]) {
        [self stopRelutionTagRegistry];
        [self stopAdvertiser];
        [self stopScanConfigLoader];
        [self stopScanner];
        [self stopPolicyTrigger];
        [self stopTrigger];
        [self stopReporter];
        running = false;
    }
}

// Stopping

- (void) stopRelutionTagRegistry {
    [relutionTagInfoRegistry stopUpdatingRegistry];
}

- (void) stopAdvertiser {
    // Nothing has to be stopped.
}

- (void) stopScanConfigLoader {
    [self->_scanConfigLoader stop];
}

- (void) stopScanner {
    [self->_scanner stopScanning];
}

- (void) stopPolicyTrigger {
    if (_policyTrigger != nil) {
        [_policyTrigger stop];
    }
}

- (void) stopTrigger {
    [self->_triggerService stop];
}

- (void) stopReporter {
    [self->_heatmapService stop];
}


@end
