//
//  BRLogOpFilter.m
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

#import "BRLogOpFilter.h"

@implementation BRLogOpFilter

- (id) initWithOperation: (Operation*) operation, ... {
    if (self = [super init]) {
        self->_operation = *operation;
        self->_filters = [[NSMutableArray alloc] init];
        
        va_list args;
        va_start(args, operation);
        
        id arg = nil;
        while ((arg = va_arg(args,id))) {
            BRFilter* filter = (BRFilter*)arg;
            [self->_filters addObject:filter];
        }
        
        va_end(args);
    }
    return self;
}

- /* override */ (NSDictionary*) toJson {
    NSMutableDictionary *filter = [[NSMutableDictionary alloc] init];
    @try {
        [filter setObject:@"logOp" forKey:@"type"];
        
        NSString* operationString = nil;
        if (self->_operation == AND) {
            operationString = @"AND";
        } else if (self->_operation == OR) {
            operationString = @"OR";
        } else if (self->_operation == NAND) {
            operationString = @"NAND";
        } else if (self->_operation == NOR) {
            operationString = @"NOR";
        }
        [filter setObject:operationString forKey:@"operation"];
        
        NSMutableArray* jsonFilters = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self->_filters count]; i++) {
            [jsonFilters addObject:[self->_filters[i] toJson]];
        }
        
        [filter setObject:jsonFilters forKey:@"filters"];
        
    } @catch (NSException* e) {
        
    }
    return filter;
}

@end
