//
//  BRRelutionTagMessageV1.m
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

#import "BRRelutionTagMessageV1.h"

// BRConstants
NSString * const RELUTION_TAG_MESSAGE_TAGS_KEY = @"tags";
NSString * const RELUTION_TAG_MESSAGE_TXPOWEr_KEY = @"txPower";

@implementation BRRelutionTagMessageV1

- (id) initWithTags: (NSArray*) tags andRssi: (int) rssi andTxPower: (short) txPower {
    if (self = [super initWithTimestamp:[NSDate date] andRssi:rssi]) {
        self->_tags = [tags copy];
        self->_txPower = txPower;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self->_tags = [coder decodeObjectForKey:RELUTION_TAG_MESSAGE_TAGS_KEY];
        self->_txPower = [coder decodeIntForKey:RELUTION_TAG_MESSAGE_TXPOWEr_KEY];
    }
    return self;
}

- (NSString *) getDescription {
    NSMutableString *outputString = [NSMutableString stringWithFormat:@"BRRelutionTagMessageV1: tags = "];
    for (int i = 0; i < [self.tags count]; i++) {
        if (i != 0) {
            [outputString appendString:@", "];
        }
        long tag = [[self.tags objectAtIndex:i] longValue];
        [outputString appendString:[NSString stringWithFormat:@"%ld", tag]];
    }
    [outputString appendFormat:@", txPower = %d", self.txPower];
    return outputString;
}

- (BRBeaconMessage*) newCopy {
    BRRelutionTagMessageV1 *clonedMessage = [[BRRelutionTagMessageV1 alloc] initWithTags:self.tags andRssi:self.rssi andTxPower:self.txPower];
    return clonedMessage;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    BRRelutionTagMessageV1 *newMessage = [super copyWithZone:zone];
    newMessage->_tags = [self.tags copyWithZone:zone];
    newMessage->_txPower = self.txPower;
    return newMessage;
}

- (BOOL) isEqual:(id)object {
    if (!([object isKindOfClass:[BRRelutionTagMessageV1 class]])) {
        return false;
    }
    BRRelutionTagMessageV1 *beaconMessage = (BRRelutionTagMessageV1*)object;
    return [beaconMessage.tags isEqual:self.tags];
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.tags forKey:RELUTION_TAG_MESSAGE_TAGS_KEY];
    [coder encodeInt:self.txPower forKey:RELUTION_TAG_MESSAGE_TXPOWEr_KEY];
}

- /* Override */ (NSUInteger) hash {
    int hash = 0;
    for (int i = 0; i < [self->_tags count]; i++) {
        hash *= [[self->_tags objectAtIndex:i] longValue];
    }
    return hash;
}

@end
