//
//  BRRelutionIoTService.h
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

#import <Foundation/Foundation.h>
#import "BRBeaconMessageStreamNodeReceiver.h"
#import "BRBeaconActionDebugListener.h"
#import "BRBeaconTagActionListener.h"
#import "BRBeaconContentActionListener.h"
#import "BRBeaconNotificationListener.h"
#import "BRBeaconTrigger.h"

// Forward declarations

@protocol BRITracer;
@protocol BRRelutionScanConfigLoader;
@class BRBeaconMessage;
@class BRBeaconTagAction;
@class BRBeaconContentAction;
@class BRBeaconNotificationAction;
@class BRRelutionTagMessage;
@class BRRelutionTagInfo;
@class BRBeaconAction;
@class BRIBeacon;
@class BRIBeaconMessageScanner;
@class BRRelutionCampaignService;
@class BRRelutionTagInfoRegistryImpl;
@class BRBeaconAdvertiser;
@class BRRelution;
@class BRRelutionHeatmapService;
@class BRRelution;

// Interfaces

@protocol BRLoginObserver
- (void) onLoginSucceeded;
- (void) onLoginFailed;
- (void) onRelutionError;
@end

@protocol BRBeaconMessageObserver
- (void) onMessageReceived: (BRBeaconMessage*) message;
@end

@protocol BRBeaconTagActionObserver
- (void) onTagActionExecuted: (BRBeaconTagAction*) tagAction;
@end

@protocol BRBeaconContentActionObserver
- (void) onContentActionExecuted: (BRBeaconContentAction*) contentAction;
@end

@protocol BRBeaconNotificationActionObserver
- (void) onNotificationActionExecuted: (BRBeaconNotificationAction*) notificationAction;
@end

@protocol BRBeaconTagActionDebugObserver
- (void) onTagActionReceived: (BRBeaconTagAction*) tagAction;
@end

@protocol BRBeaconContentActionDebugObserver
- (void) onContentActionReceived: (BRBeaconContentAction*) contentAction;
@end

@protocol BRBeaconNotificationActionDebugObserver
- (void) onNotificationActionReceived: (BRBeaconNotificationAction*) notificationAction;
@end

@protocol BRRelutionTagObserver
- (void) onTagReceived: (long) tag message: (BRRelutionTagMessage*) message;
@end

@protocol BRPolicyTriggerObserver
- (void) onBeaconActive;
- (void) onBeaconInactive;
- (void) onNewDistance: (float) distanceInM;
@end

/**
 * This service class unites all features that are currently supported by the SDK and provides an
 * easy to use interface, so that it is not necessary to know all the details of the underlying
 * message processing architecture. Before starting this service with one of the start methods
 * defined in the base class, you must call the {@link #setConfig} method, where you pass the
 * Relution server URL, the organization UUID and the login data. After the service has been
 * started, you can register different observers to get informed about incoming beacon messages,
 * Relution tags or executed actions. Moreover, you can use this class to calibrate iBeacon
 * messages.
 */
@interface BRRelutionIoTService : NSObject<
    BRBeaconMessageStreamNodeReceiver,
    BRBeaconActionDebugListener,
    BRBeaconContentActionListener,
    BRBeaconTagActionListener,
    BRBeaconNotificationListener,
    BRBeaconTriggerObserver> {
        
        NSThread* _mainThread;
        BRIBeaconMessageScanner* _scanner;
        id<BRRelutionScanConfigLoader> _scanConfigLoader;
        BRRelutionCampaignService* _triggerService;
        BRBeaconTrigger* _policyTrigger;
        BRRelutionHeatmapService* _heatmapService;
        BRBeaconAdvertiser* _advertiser;
    
}

// Observer registrations


/**
 Adds an observer for Relution login events.

 @param loginObserver
 */
+ (void) addLoginObserver: (id<BRLoginObserver>) loginObserver;


/**
 Adds an observer for incoming beacon messages. Notice: Only
 beacon as configured in Relution will be detected and considered
 by this observer.

 @param observer
 */
+ (void) addBeaconMessageObserver: (id<BRBeaconMessageObserver>) observer;


/**
 Adds an observer for "Tag" actions as defined in Relution (Campaigns).

 @param observer
 */
+ (void) addBeaconTagActionObserver: (id<BRBeaconTagActionObserver>) observer;


/**
 Adds an observer for "Content" actions as defined in Relution (Campaigns).

 @param observer
 */
+ (void) addBeaconContentActionObserver: (id<BRBeaconContentActionObserver>) observer;


/**
 Adds an observer for "Notification" actions as defined in Relution (Campaigns).

 @param observer
 */
+ (void) addBeaconNotificationActionObserver: (id<BRBeaconNotificationActionObserver>) observer;


// Debug observers

/**
 Should only be used when debugging Relution Proximity Messaging.

 @param observer
 */


/**
 Should only be used when debugging Relution Proximity Messaging.

 @param observer
 */
+ (void) addBeaconTagActionDebugObserver: (id<BRBeaconTagActionDebugObserver>) observer;


/**
 Should only be used when debugging Relution Proximity Messaging.

 @param observer
 */
+ (void) addBeaconContentActionDebugObserver: (id<BRBeaconContentActionDebugObserver>) observer;


/**
 Should only be used when debugging Relution Proximity Messaging.

 @param observer
 */
+ (void) addBeaconNotificationActionDebugObserver:(id<BRBeaconNotificationActionDebugObserver>)observer;


/**
 Should only be used when debugging Relution Proximity Messaging.

 @param observer
 */
+ (void) addRelutionTagObserver: (id<BRPolicyTriggerObserver>) observer;


/**
 Should only be used when debugging Relution Proximity Messaging.

 @param observer
 */
+ (void) addPolicyTriggerObserver: (id<BRPolicyTriggerObserver>) observer;


// Initialization


/**
 Creates a new Relution IoT service instance.

 @return The newly created Relution IoT service instance.
 */
- (id) init;


// Configuration

/**
 Configures the login data of the Relution IoT service. This method must
 be called before starting the service.

 @param baseUrl The Relution base URL (e.g. https://iot2.relution.io)
 @param username The Relution username
 @param password The Relution password
 @param loginObserver The login observer. It will be informed about a successfull/unsuccessful login.
 @return The Relution IoT service object.
 */
- (BRRelutionIoTService*) setLoginData: (NSString*) baseUrl andUsername: (NSString*) username
                         andPassword: (NSString*) password andLoginObserver: (id<BRLoginObserver>) loginObserver;

/**
 Configures whether logging should be enabled. Disable logging in production
 because logging can affect the app performance dramatically.

 @param enabled true, if logging should be enabled.
 @return The Relution IoT service object.
 */
- (BRRelutionIoTService*) setLoggingEnabled: (BOOL) enabled;


/**
 Configures whether Relution IoT proximity messaging should be enabled.
 If true, a beacon action trigger will execute actions based on the time and location
 specific parameters as configured in Relution IoT.

 @param enabled true, if Proximity messaging should be enabled.
 @return The Relution IoT service object.
 */
- (BRRelutionIoTService*) setCampaignActionTriggerEnabled: (BOOL) enabled;


/**
 Configures whether Relution Heatmap should be enabled.
 If true, the app will send specific Bluetooth LE advertising messages in background.
 These messages will be collected by the beacons and upstreamed to the cloud.
 This service can be used for heatmap generation.

 @param enabled true, if Relution Heatmap feature should be enabled.
 @return The Relution IoT service object
 */
- (BRRelutionIoTService*) setHeatmapGenerationEnabled: (BOOL) enabled;


/**
 Configures, whether Relution Analytics should be enabled.
 If true, Relution SmartBeacon IDs and their estimated distances will
 regularly be send to Relution for analytics. This information could
 be used also for server based indoor localization.

 @param enabled true, if Relution Analytics should be enabled.
 @returnThe Relution IoT service object
 */
- (BRRelutionIoTService*) setHeatmapReportingEnabled: (BOOL) enabled;


- (BRRelutionIoTService*) setPolicyTriggerEnabled: (BOOL) enabled;

// Starting and stopping

/**
 Starts the Relution IoT service. After a successful login, all
 service components will be started as configured.
 */
- (void) start;


/**
 Stops the Relution IoT service.
 */
- (void) stop;


/**
 Returns true, when the service has been started and not stopped yet.

 @return
 */
+ (BOOL) isRunning;

// Requests


/**
 Fetches informations about the Relution Tags from the Relution server.

 @param tag The Relution Tag ID.
 @return @link{BRRelutionTagInfo}
 */
+ (BRRelutionTagInfo*) getTagInfoForTag: (long) tag;


/**
 Sends an iBeacon txPower calibration to Relution. This will affect
 the distance estimation which will both consider the received signal
 strength of the beacon message (RSSI) and this calibrated RSSI (txPower).
 The txPower should be the mean RSSI measured at one meter distance to the beacon.

 @param iBeacon The iBeacon to be calibrated.
 @param txPower The calibrated RSSI (txPower) (e.g -55 dBm).
 */
+ (void) calibrateIBeacon: (BRIBeacon*) iBeacon withTxPower: (float) txPower;


// Login information

/**
 The Relution organization UUID

 @return
 */
+ (NSString*) getOrganizationUuid;


/**
 The Relution username

 @return Relution username
 */
+ (NSString*) getUsername;


/**
 The Relution hostname (e.g. https://iot2.relution.io)

 @return The Relution hostname
 */
+ (NSString*) getHostname;

@end
