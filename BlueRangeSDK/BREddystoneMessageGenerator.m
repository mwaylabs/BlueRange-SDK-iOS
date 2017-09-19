//
//  BREddystoneMessageGenerator.m
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

#import "BREddystoneMessageGenerator.h"
#import "BRAbstract.h"
#import <CoreBluetooth/CoreBluetooth.h>

static NSString* eddystoneServiceID = @"FEAA";
const int EDDY_FRAME_UID = 0b00000000;
const int EDDY_FRAME_URL = 0b00010000;
const int EDDY_FRAME_TLM = 0b00100000;
const int EDDY_FRAME_EID = 0b01000000;

@implementation BREddystoneMessageGenerator

- (BOOL) matches: (NSDictionary*) advertisementData {
    NSData* beaconServiceData = [self getServiceDataForAdvertisementData:advertisementData];
    if (beaconServiceData != nil) {
        return true;
    } else {
        return false;
    }
}

- (BRBeaconMessage*) newMessage: (NSDictionary*) advertisementData withRssi: (int) rssi {
    mustOverride();
}

- (BOOL) isEqual:(id)object {
    mustOverride();
}

- (NSData*) getServiceDataForAdvertisementData: (NSDictionary*) advertisementData {
    NSDictionary *serviceData = advertisementData[CBAdvertisementDataServiceDataKey];
    
    static CBUUID *_singleton;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _singleton = [CBUUID UUIDWithString:eddystoneServiceID];
    });
    
    NSData *beaconServiceData = serviceData[_singleton];
    return beaconServiceData;
}

@end
