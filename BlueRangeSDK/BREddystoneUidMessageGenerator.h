//
//  BREddystoneUidMessageGenerator.h
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
#import "BREddystoneMessageGenerator.h"

/**
 * The beacon message generator class for Eddystone UID messages.
 */
@interface BREddystoneUidMessageGenerator : BREddystoneMessageGenerator {
    BOOL _namespaceFilteringEnabled;
    NSString* _namespaceUid;
    NSMutableArray* _blacklistedNamespaces;
    BOOL _instanceFilteringEnabled;
    NSString* _instance;
}

@property (readonly) NSString* namespaceUid;
@property (readonly) NSString* instance;

- (id) init;
- (id) initWithNamespace: (NSString*) namespaceUid;
- (id) initWithNamespace: (NSString*) namespaceUid andInstance: (NSString*) instance;
- /* override */ (BOOL) matches: (NSDictionary*) advertisementData;
- /* override */ (BRBeaconMessage*) newMessage: (NSDictionary*) advertisementData withRssi: (int) rssi;
- /* override */ (BOOL) isEqual:(id)object;
- (void) blacklistNamespace: (NSString*) namespaceUid;

@end
