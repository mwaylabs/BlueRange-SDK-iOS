//
//  BRJsonUtils.m
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

#import "BRJsonUtils.h"

@implementation BRJSONException

@end

@implementation BRJsonUtils

+ (id) getJsonFromString: (NSString*) jsonString {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id jsonResult = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    return jsonResult;
}

+ (NSString*) jsonStringForDictionary: (NSDictionary*) dictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (NSString*) jsonStringForArray: (NSArray*) array {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"[]";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (id) getJsonValueForKey: (NSString*) key andDictionary: (NSDictionary*) dictionary {
    id result = [dictionary objectForKey:key];
    if (result == nil) {
        @throw[BRJSONException exceptionWithName:@"BRJSONException" reason:@"No value for key." userInfo:nil];
    }
    return result;
}

+ (id) getJsonValueAtIndex: (int) index forArray: (NSArray*) array {
    if (index >= 0 && index < [array count]) {
        return [array objectAtIndex:index];
    } else {
        @throw[BRJSONException exceptionWithName:@"BRJSONException" reason:@"No value for index." userInfo:nil];
    }
}

@end
