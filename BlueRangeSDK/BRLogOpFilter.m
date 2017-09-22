//
//  BRLogOpFilter.m
//  BlueRangeSDK
//
// Copyright (c) 2016-2017, M-Way Solutions GmbH
// All rights reserved.
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
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
