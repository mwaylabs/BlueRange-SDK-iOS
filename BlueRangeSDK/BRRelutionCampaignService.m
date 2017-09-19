//
//  BRRelutionCampaignService.m
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

#import "BRRelutionCampaignService.h"
#import "BRIBeaconMessageScanner.h"
#import "BRRelutionIBeaconMessageActionMapper.h"
#import "BRIBeaconMessageActionMapperStub.h"
#import "BRRelutionTagMessageActionMapperEmptyStub.h"
#import "BRBeaconMessageActionTrigger.h"
#import "BRBeaconMessageScannerConfig.h"
#import "BRBeaconActionListener.h"
#import "BRBeaconActionDebugListener.h"

NSString * const RELUTION_CAMPAIGN_SERVICE_LOG_TAG = @"BRRelutionCampaignService";
const long POLLING_TIME_FOR_REQUESTING_UUID_REGISTRY_IN_MS = 1000L;
const long WAIT_TIME_BETWEEN_UUID_REGISTRY_SYNCHRONIZATION_IN_MS = 10000L; // 10 seconds.

@interface BRRelutionCampaignService()

@end

@implementation BRRelutionCampaignService

- (id) initWithScanner: (BRIBeaconMessageScanner*) scanner andRelution: (BRRelution*) relution {
    if (self = [super init]) {
        self->_scanner = scanner;
        
        //self->_iBeaconMessageActionMapper = [[BRIBeaconMessageActionMapperStub alloc] init];
        self->_iBeaconMessageActionMapper = [[BRRelutionIBeaconMessageActionMapper alloc]
                                             initWithRelution: relution];
        
        self->_relutionTagMessageActionMapper = [[BRRelutionTagMessageActionMapperEmptyStub alloc] init];
        
        self->_trigger = [[BRBeaconMessageActionTrigger alloc] initWithSender:scanner
                                        andIBeaconMessageActionMapper:self->_iBeaconMessageActionMapper
                                        andRelutionTagMessageActionMapper:self->_relutionTagMessageActionMapper];
    }
    return self;
}

- (void) start {
    [self->_trigger start];
}

- (void) stop {
    [self->_trigger stop];
}

- (void) addActionListener: (NSObject<BRBeaconActionListener>*) listener {
    [self->_trigger addActionListener:listener];
}

// Debugging
- (void) addDebugActionListener: (NSObject<BRBeaconActionDebugListener>*) listener {
    [self->_trigger addDebugActionListener:listener];
}

@end
