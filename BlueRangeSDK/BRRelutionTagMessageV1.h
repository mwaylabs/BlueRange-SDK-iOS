//
//  BRRelutionTagMessageV1.h
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
#import "BRBeaconMessage.h"

/**
 * A Relution Tag message is a Relution specific advertising message that can be delivered by
 * BlueRange SmartBeacons. A Relution tag message contains one or more tag identifiers. The
 * concept of Relution Tag messages is designed for apps that do not require internet access but
 * want to react to tags, that can be assigned dynamically to a beacon using the Relution platform.
 */
@interface BRRelutionTagMessageV1 : BRBeaconMessage

@property (readonly, copy) NSArray* tags;
@property (readonly) short txPower;

- (id) initWithTags: (NSArray*) tags andRssi: (int) rssi andTxPower: (short) txPower;
- (id) initWithCoder:(NSCoder *)coder;
- (NSString *) getDescription;
- (BRBeaconMessage*) newCopy;
- (id)copyWithZone:(struct _NSZone *)zone;
- (BOOL) isEqual:(id)object;
- (void) encodeWithCoder:(NSCoder *)coder;
- /* Override */ (NSUInteger) hash;

@end
