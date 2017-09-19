//
//  BREddystoneUrlMessageGenerator.m
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

#import "BREddystoneUrlMessageGenerator.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BREddystoneUrlMessage.h"

@implementation BREddystoneUrlMessageGenerator

- (id) init {
    if (self = [super init]) {
        self->_urlFilteringEnabled = false;
        self->_url = nil;
    }
    return self;
}

- (id) initWithUrl: (NSString*) url {
    if (self = [super init]) {
        self->_urlFilteringEnabled = true;
        self->_url = url;
    }
    return self;
}

- /* override */ (BOOL) matches: (NSDictionary*) advertisementData {
    if (![super matches:advertisementData]) {
        return false;
    }
    @try {
        // Extract manufacturer specific data out of the advertisement data
        NSData* beaconServiceData = [self getServiceDataForAdvertisementData:advertisementData];
        uint8_t* data = (uint8_t*)[beaconServiceData bytes];
        
        // 0. If no manufacturer specific data are available, this is not a valid beacon
        if (beaconServiceData == nil) {
            return false;
        }
        
        // 1. FrameType
        const uint8_t EXPECTED_FRAME_TYPE = EDDY_FRAME_URL;
        uint8_t frameType = data[0];
        if (frameType != EXPECTED_FRAME_TYPE) {
            return false;
        }
        
        // 2. Check namespace
        if (self->_urlFilteringEnabled) {
            NSString* actualUrl = [BREddystoneUrlMessage getUrlStringFromBytes: data withStartByte:2 andLength:17];
            NSString* acceptedUrl = self->_url;
            
            if (![actualUrl isEqualToString:acceptedUrl]) {
                return false;
            }
        }
        
    } @catch (NSException* e) {
        return false;
    }
    
    // In all other cases...
    return true;
}

- /* override */ (BRBeaconMessage*) newMessage: (NSDictionary*) advertisementData withRssi: (int) rssi {
    // Extract manufacturer specific data out of the advertisement data
    NSData* beaconServiceData = [self getServiceDataForAdvertisementData:advertisementData];
    uint8_t* data = (uint8_t*)[beaconServiceData bytes];
    
    // 1. TxPower (we add -41 dBm as specified in the Eddystone specification)
    int txPower = (int)(((int8_t*)([beaconServiceData bytes]))[1]) + -41;
    
    // 2. URL
    NSString* url = [BREddystoneUrlMessage getUrlStringFromBytes:
                     data withStartByte:2 andLength:17];
    
    // Create a new message
    BREddystoneUrlMessage __autoreleasing *message
        = [[BREddystoneUrlMessage alloc] initWithUrl:url andTxPower:txPower andRssi:rssi];
    
    return message;
}

- /* override */ (BOOL) isEqual:(id)object {
    if (!([object isKindOfClass:[BREddystoneUrlMessageGenerator class]])) {
        return false;
    }
    BREddystoneUrlMessageGenerator *generator = (BREddystoneUrlMessageGenerator*)object;
    
    if ((self->_urlFilteringEnabled && generator->_urlFilteringEnabled)
        && (![generator->_url isEqualToString:self->_url])) {
        return false;
    }
    
    return true;
}

@end
