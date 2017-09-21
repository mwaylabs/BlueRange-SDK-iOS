//
//  BRBeaconMessageScannerConfig.m
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

#import "BRBeaconMessageScannerConfig.h"
#import "BRIBeaconMessageGenerator.h"
#import "BRRelutionTagMessageGenerator.h"
#import "BRRelutionTagMessageGeneratorV1.h"
#import "BRBeaconJoinMeMessageGenerator.h"
#import "BREddystoneMessageGenerator.h"
#import "BREddystoneUidMessageGenerator.h"
#import "BREddystoneUrlMessageGenerator.h"
#import "BRBeaconMessageScannerConfig.h"
#import "BRBeaconMessageGenerator.h"
#import "BRIBeaconMessageScanner.h"
#import "BRIBeacon.h"

// Private methods
@interface BRBeaconMessageScannerConfig()

- (void) addMessageGeneratorAndRestartScannerIfNeccessary: (NSObject<BRBeaconMessageGenerator>*) messageGenerator;
- (void) addMessageGeneratorsAndRestartScannerIfNeccessary: (NSArray*) messageGenerators;
- (void) addMessageGenerator: (NSObject<BRBeaconMessageGenerator>*) messageGenerator;
- (void) ensureMessageGeneratorDisjunction;
- (NSArray*) getRelutionTagMessageGenerators;
- (NSArray*) getEddystoneMessageGenerators;
- (void) blacklistNamespaceInEddystoneMessageGeneratorIfMatches:
    (BREddystoneMessageGenerator*) eddystoneMessageGenerator namespaceUid: (NSString*) namespaceUid;
- (void) stopScannerIfIsRunning: (BOOL) restart;
- (void) startScannerIfDidRunBefore: (BOOL) restart;

@end

@implementation BRBeaconMessageScannerConfig

- (id) initWithScanner: (BRIBeaconMessageScanner*) scanner {
    if (self = [super init]) {
        self->_scanner = scanner;
        self->_iBeaconMessageGenerators = [[NSMutableArray alloc] init];
        self->_defaultScannerMessageGenerators = [[NSMutableArray alloc] init];
        self->_scanPeriodInMs = 500;
        self->_betweenScanPeriodInMs = 1;
    }
    return self;
}

- (void) addMessageGeneratorAndRestartScannerIfNeccessary: (NSObject<BRBeaconMessageGenerator>*) messageGenerator {
    BOOL restart = [self->_scanner running];
    [self stopScannerIfIsRunning:restart];
    [self addMessageGenerator:messageGenerator];
    [self startScannerIfDidRunBefore:restart];
}

- (void) addMessageGeneratorsAndRestartScannerIfNeccessary: (NSArray*) messageGenerators {
    // Restart the scanner only once with the new configuration
    if ([messageGenerators count] > 0) {
        BOOL restart = [self->_scanner running];
        [self stopScannerIfIsRunning:restart];
        for (int i = 0;i < [messageGenerators count]; i++) {
            NSObject<BRBeaconMessageGenerator> *messageGenerator
                = (NSObject<BRBeaconMessageGenerator>*)[messageGenerators objectAtIndex:i];
            [self addMessageGenerator:messageGenerator];
        }
        [self startScannerIfDidRunBefore:restart];
    }
}

- (void) addMessageGenerator: (NSObject<BRBeaconMessageGenerator>*) messageGenerator {
    if ([messageGenerator isMemberOfClass:[BRIBeaconMessageGenerator class]]) {
        [_iBeaconMessageGenerators addObject:messageGenerator];
    } else {
        [_defaultScannerMessageGenerators addObject:messageGenerator];
    }
    // Ensure that message generators do not overlap.
    [self ensureMessageGeneratorDisjunction];
}

- (void) ensureMessageGeneratorDisjunction {
    // Since Relution Tag messages can be parsed as Eddystone UID messages as well,
    // we have to explicitly blacklist them from the Eddystone messages.
    NSArray* relutionTagMessageGenerators = [self getRelutionTagMessageGenerators];
    NSArray* eddystoneMessageGenerators = [self getEddystoneMessageGenerators];
    for (BRRelutionTagMessageGenerator* relutionTagMessageGenerator in relutionTagMessageGenerators) {
        NSString* namespaceUid = [relutionTagMessageGenerator namespaceUid];
        for (BREddystoneMessageGenerator* eddystoneMessageGenerator in eddystoneMessageGenerators) {
            if (!([eddystoneMessageGenerator isMemberOfClass:[BRRelutionTagMessageGenerator class]])) {
                [self blacklistNamespaceInEddystoneMessageGeneratorIfMatches: eddystoneMessageGenerator namespaceUid: namespaceUid];
            }
        }
    }
}

- (NSArray*) getRelutionTagMessageGenerators {
    NSMutableArray* relutionTagMessageGenerators = [[NSMutableArray alloc] init];
    for (NSObject<BRBeaconMessageGenerator>* messageGenerator in self->_defaultScannerMessageGenerators) {
        if ([messageGenerator isKindOfClass:[BRRelutionTagMessageGenerator class]]) {
            [relutionTagMessageGenerators addObject:messageGenerator];
        }
    }
    return relutionTagMessageGenerators;
}

- (NSArray*) getEddystoneMessageGenerators {
    NSMutableArray* eddystoneMessageGenerators = [[NSMutableArray alloc] init];
    for (NSObject<BRBeaconMessageGenerator>* messageGenerator in self->_defaultScannerMessageGenerators) {
        if ([messageGenerator isKindOfClass:[BREddystoneMessageGenerator class]]) {
            [eddystoneMessageGenerators addObject:messageGenerator];
        }
    }
    return eddystoneMessageGenerators;
}

- (void) blacklistNamespaceInEddystoneMessageGeneratorIfMatches:
    (BREddystoneMessageGenerator*) eddystoneMessageGenerator namespaceUid: (NSString*) namespaceUid {
    if ([eddystoneMessageGenerator isKindOfClass:[BREddystoneUidMessageGenerator class]]) {
        BREddystoneUidMessageGenerator* eddystoneUidMessageGenerator = (BREddystoneUidMessageGenerator*)eddystoneMessageGenerator;
        NSString* comparedNamespace = [eddystoneUidMessageGenerator namespaceUid];
        if (comparedNamespace == nil || [comparedNamespace isEqualToString:namespaceUid]) {
            [eddystoneUidMessageGenerator blacklistNamespace:namespaceUid];
        }
    } else if ([eddystoneMessageGenerator isKindOfClass:[BREddystoneUrlMessageGenerator class]]) {
        
    }
}

- (void) scanIBeacon: (NSString*) uuid major: (int) major minor: (int) minor {
    @synchronized(self) {
        BRIBeaconMessageGenerator *messageGenerator = [[BRIBeaconMessageGenerator alloc] initWithUUID:uuid major:major minor:minor];
        if (![self->_iBeaconMessageGenerators containsObject:messageGenerator]) {
            NSObject<BRBeaconMessageGenerator>* generator = (NSObject<BRBeaconMessageGenerator>*)messageGenerator;
            [self addMessageGeneratorAndRestartScannerIfNeccessary:generator];
        }
    }
}

- (void) scanIBeacon: (NSString*) uuid major: (int) major {
    @synchronized(self) {
        BRIBeaconMessageGenerator *messageGenerator = [[BRIBeaconMessageGenerator alloc] initWithUUID:uuid major:major];
        if (![self->_iBeaconMessageGenerators containsObject:messageGenerator]) {
            NSObject<BRBeaconMessageGenerator>* generator = (NSObject<BRBeaconMessageGenerator>*)messageGenerator;
            [self addMessageGeneratorAndRestartScannerIfNeccessary:generator];
        }
    }
}

- (void) scanIBeacon: (NSString*) uuid {
    @synchronized(self) {
        BRIBeaconMessageGenerator *messageGenerator = [[BRIBeaconMessageGenerator alloc] initWithUUID:uuid];
        if (![self->_iBeaconMessageGenerators containsObject:messageGenerator]) {
            NSObject<BRBeaconMessageGenerator>* generator = (NSObject<BRBeaconMessageGenerator>*)messageGenerator;
            [self addMessageGeneratorAndRestartScannerIfNeccessary:generator];
        }
    }
}

- (void) scanIBeaconUuids: (NSArray*) uuidStrings {
    @synchronized (self) {
        NSMutableArray* newMessageGenerators = [[NSMutableArray alloc] init];
        // Add all message generators to the list if it does not exist yet in the list of all message generators.
        for (int i = 0; i < [uuidStrings count]; i++) {
            NSString* uuid = [uuidStrings objectAtIndex:i];
            BRIBeaconMessageGenerator *messageGenerator = [[BRIBeaconMessageGenerator alloc] initWithUUID:uuid];
            if (![self->_iBeaconMessageGenerators containsObject:messageGenerator]) {
                [newMessageGenerators addObject:messageGenerator];
            }
        }
        [self addMessageGeneratorsAndRestartScannerIfNeccessary:newMessageGenerators];
    }
}

- (void) scanIBeacons: (NSArray*) iBeacons {
    @synchronized (self) {
        NSMutableArray* newMessageGenerators = [[NSMutableArray alloc] init];
        // Add all message generators to the list if it does not exist yet in the list of all message generators.
        for (int i = 0; i < [iBeacons count]; i++) {
            BRIBeacon* iBeacon = [iBeacons objectAtIndex:i];
            NSString* uuidString = iBeacon.uuid.UUIDString;
            int major = iBeacon.major;
            int minor = iBeacon.minor;
            BRIBeaconMessageGenerator *messageGenerator = [[BRIBeaconMessageGenerator alloc] initWithUUID:uuidString major:major minor:minor];
            if (![self->_iBeaconMessageGenerators containsObject:messageGenerator]) {
                [newMessageGenerators addObject:messageGenerator];
            }
        }
        [self addMessageGeneratorsAndRestartScannerIfNeccessary:newMessageGenerators];
    }
}

- (void) scanRelutionTagsV1: (NSArray*) tags {
    @synchronized(self) {
        BRRelutionTagMessageGeneratorV1 *messageGenerator = [[BRRelutionTagMessageGeneratorV1 alloc] initWithTags:tags];
        if (![self->_defaultScannerMessageGenerators containsObject:messageGenerator]) {
            NSObject<BRBeaconMessageGenerator>* generator = (NSObject<BRBeaconMessageGenerator>*)messageGenerator;
            [self addMessageGeneratorAndRestartScannerIfNeccessary:generator];
        }
    }
}

- (void) scanRelutionTagsV1 {
    @synchronized(self) {
        BRRelutionTagMessageGeneratorV1 *messageGenerator = [[BRRelutionTagMessageGeneratorV1 alloc] init];
        if (![self->_defaultScannerMessageGenerators containsObject:messageGenerator]) {
            NSObject<BRBeaconMessageGenerator>* generator = (NSObject<BRBeaconMessageGenerator>*)messageGenerator;
            [self addMessageGeneratorAndRestartScannerIfNeccessary:generator];
        }
    }
}

- (void) scanRelutionTags: (NSString*) namespaceUid {
    BRRelutionTagMessageGenerator* messageGenerator = [[BRRelutionTagMessageGenerator alloc] initWithNamespace:namespaceUid];
    if (![self->_defaultScannerMessageGenerators containsObject:messageGenerator]) {
        NSObject<BRBeaconMessageGenerator>* generator = (NSObject<BRBeaconMessageGenerator>*)messageGenerator;
        [self addMessageGeneratorAndRestartScannerIfNeccessary:generator];
    }
}

- (void) scanRelutionTags: (NSString*) namespaceUid andTags: (NSArray*) tags {
    BRRelutionTagMessageGenerator* messageGenerator = [[BRRelutionTagMessageGenerator alloc] initWithNamespace:namespaceUid andTags:tags];
    if (![self->_defaultScannerMessageGenerators containsObject:messageGenerator]) {
        NSObject<BRBeaconMessageGenerator>* generator = (NSObject<BRBeaconMessageGenerator>*)messageGenerator;
        [self addMessageGeneratorAndRestartScannerIfNeccessary:generator];
    }
}

- (void) scanEddystoneUid {
    @synchronized (self) {
        BREddystoneUidMessageGenerator* messageGenerator = [[BREddystoneUidMessageGenerator alloc] init];
        if (![self->_defaultScannerMessageGenerators containsObject:messageGenerator]) {
            NSObject<BRBeaconMessageGenerator>* generator = (NSObject<BRBeaconMessageGenerator>*)messageGenerator;
            [self addMessageGeneratorAndRestartScannerIfNeccessary:generator];
        }
    }
}

- (void) scanEddystoneUidWithNamespace: (NSString*) namespaceUid {
    @synchronized (self) {
        BREddystoneUidMessageGenerator* messageGenerator = [[BREddystoneUidMessageGenerator alloc] initWithNamespace:namespaceUid];
        if (![self->_defaultScannerMessageGenerators containsObject:messageGenerator]) {
            NSObject<BRBeaconMessageGenerator>* generator = (NSObject<BRBeaconMessageGenerator>*)messageGenerator;
            [self addMessageGeneratorAndRestartScannerIfNeccessary:generator];
        }
    }
}

- (void) scanEddystoneUidWithNamespaces: (NSArray*) namespaceUids {
    @synchronized (self) {
        NSMutableArray* newMessageGenerators = [[NSMutableArray alloc] init];
        // Add all message generators to the list if it does not exist yet in the list of all message generators.
        for (int i = 0; i < [namespaceUids count]; i++) {
            NSString* namespaceUid = [namespaceUids objectAtIndex:i];
            BREddystoneUidMessageGenerator* messageGenerator = [[BREddystoneUidMessageGenerator alloc] initWithNamespace:namespaceUid];
            if (![self->_defaultScannerMessageGenerators containsObject:messageGenerator]) {
                [newMessageGenerators addObject:messageGenerator];
            }
        }
        [self addMessageGeneratorsAndRestartScannerIfNeccessary:newMessageGenerators];
    }
}

- (void) scanEddystoneUidWithNamespace: (NSString*) namespaceUid andInstanceId: (NSString*) instanceId {
    @synchronized (self) {
        BREddystoneUidMessageGenerator* messageGenerator = [[BREddystoneUidMessageGenerator alloc]
                                                          initWithNamespace:namespaceUid andInstance:instanceId];
        if (![self->_defaultScannerMessageGenerators containsObject:messageGenerator]) {
            NSObject<BRBeaconMessageGenerator>* generator = (NSObject<BRBeaconMessageGenerator>*)messageGenerator;
            [self addMessageGeneratorAndRestartScannerIfNeccessary:generator];
        }
    }
}

- (void) scanEddystoneUidWithNamespace: (NSString*) namespaceUid andInstanceIds: (NSArray*) instanceIds {
    @synchronized (self) {
        NSMutableArray* newMessageGenerators = [[NSMutableArray alloc] init];
        // Add all message generators to the list if it does not exist yet in the list of all message generators.
        for (int i = 0; i < [instanceIds count]; i++) {
            NSString* instanceId = [instanceIds objectAtIndex:i];
            BREddystoneUidMessageGenerator* messageGenerator = [[BREddystoneUidMessageGenerator alloc]
                                                              initWithNamespace:namespaceUid andInstance:instanceId];
            if (![self->_defaultScannerMessageGenerators containsObject:messageGenerator]) {
                [newMessageGenerators addObject:messageGenerator];
            }
        }
        [self addMessageGeneratorsAndRestartScannerIfNeccessary:newMessageGenerators];
    }
}

- (void) scanEddystoneUrls {
    @synchronized (self) {
        BREddystoneUrlMessageGenerator* messageGenerator = [[BREddystoneUrlMessageGenerator alloc] init];
        if (![self->_defaultScannerMessageGenerators containsObject:messageGenerator]) {
            NSObject<BRBeaconMessageGenerator>* generator = (NSObject<BRBeaconMessageGenerator>*)messageGenerator;
            [self addMessageGeneratorAndRestartScannerIfNeccessary:generator];
        }
    }
}

- (void) scanEddystoneUrl: (NSString*) url {
    @synchronized (self) {
        BREddystoneUrlMessageGenerator* messageGenerator = [[BREddystoneUrlMessageGenerator alloc] initWithUrl:url];
        if (![self->_defaultScannerMessageGenerators containsObject:messageGenerator]) {
            NSObject<BRBeaconMessageGenerator>* generator = (NSObject<BRBeaconMessageGenerator>*)messageGenerator;
            [self addMessageGeneratorAndRestartScannerIfNeccessary:generator];
        }
    }
}

- (void) scanEddystoneUrls: (NSArray*) urls {
    @synchronized (self) {
        NSMutableArray* newMessageGenerators = [[NSMutableArray alloc] init];
        // Add all message generators to the list if it does not exist yet in the list of all message generators.
        for (int i = 0; i < [urls count]; i++) {
            NSString* url = [urls objectAtIndex:i];
            BREddystoneUrlMessageGenerator* messageGenerator = [[BREddystoneUrlMessageGenerator alloc] initWithUrl:url];
            if (![self->_defaultScannerMessageGenerators containsObject:messageGenerator]) {
                [newMessageGenerators addObject:messageGenerator];
            }
        }
        [self addMessageGeneratorsAndRestartScannerIfNeccessary:newMessageGenerators];
    }
}

- (void) scanJoinMeMessages {
    @synchronized(self) {
        BRBeaconJoinMeMessageGenerator *messageGenerator = [[BRBeaconJoinMeMessageGenerator alloc] init];
        if (![self->_defaultScannerMessageGenerators containsObject:messageGenerator]) {
            NSObject<BRBeaconMessageGenerator>* generator = (NSObject<BRBeaconMessageGenerator>*)messageGenerator;
            [self addMessageGeneratorAndRestartScannerIfNeccessary:generator];
        }
    }
}

- (NSArray*) getIBeaconMessageGenerators
{
    return self->_iBeaconMessageGenerators;
}

- (NSArray*) getDefaultScannerMessageGenerators {
    return self->_defaultScannerMessageGenerators;
}

- (void) setScanPeriodInMs:(long)scanPeriodInMs {
    @synchronized (self) {
        BOOL restart = [self->_scanner running];
        [self stopScannerIfIsRunning:restart];
        self->_scanPeriodInMs = scanPeriodInMs;
        [self startScannerIfDidRunBefore:restart];
    }
}

- (long) scanPeriodInMs {
    @synchronized (self) {
        return self->_scanPeriodInMs;
    }
}

- (void) setBetweenScanPeriodInMs:(long)betweenScanPeriodInMs {
    @synchronized (self) {
        BOOL restart = [self->_scanner running];
        [self stopScannerIfIsRunning:restart];
        self->_betweenScanPeriodInMs = betweenScanPeriodInMs;
        [self startScannerIfDidRunBefore:restart];
    }
}

- (long) betweenScanPeriodInMs {
    @synchronized (self) {
        return self->_betweenScanPeriodInMs;
    }
}

- (void) stopScannerIfIsRunning: (BOOL) restart {
    if (restart) {
        [self->_scanner stopScanning];
    }
}

- (void) startScannerIfDidRunBefore: (BOOL) restart {
    if (restart) {
        [self->_scanner startScanning];
    }
}

@end
