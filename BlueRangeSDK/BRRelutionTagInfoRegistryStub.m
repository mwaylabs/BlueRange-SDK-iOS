//
//  BRRelutionTagInfoRegistryStub.m
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

#import "BRRelutionTagInfoRegistryStub.h"
#import "BRRelutionTagInfo.h"

@implementation BRRelutionTagInfoRegistryStub

- (id) init {
    if (self = [super init]) {
        self->_tagInfoMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- /* override */ (void) continuouslyUpdateRegistry {
    [self->_tagInfoMap
        setObject:[[BRRelutionTagInfo alloc] initWithId:1 andName:@"name1" andDescription:@"description1"] forKey:[NSNumber numberWithLong:1L]];
    [self->_tagInfoMap
     setObject:[[BRRelutionTagInfo alloc] initWithId:2 andName:@"name2" andDescription:@"description2"] forKey:[NSNumber numberWithLong:2L]];
}

- /* override */ (void) stopUpdatingRegistry {
    // Nothing has to be done.
}

- /* override */ (BRRelutionTagInfo*) getRelutionTagInfoForTag: (long) tag {
    BRRelutionTagInfo* relutionTagInfo = [self->_tagInfoMap objectForKey:[NSNumber numberWithLong:tag]];
    if (relutionTagInfo == nil) {
        @throw [BRRelutionTagInfoRegistryNoInfoFound exceptionWithName:@"BRRelutionTagInfoRegistryNoInfoFound" reason:@"" userInfo:nil];
    }
    return relutionTagInfo;
}

@end
