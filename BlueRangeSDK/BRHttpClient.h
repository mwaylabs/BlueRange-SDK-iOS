//
//  BRHttpClient.h
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

#import <Foundation/Foundation.h>

// Inner classes
@interface BRRequestException : NSException
@end

@interface BRJsonResponse : NSObject

@property int statusCode;
@property NSData* responseBody;

@end

@interface BRParameter : NSObject

@property NSString* key;
@property NSString* value;
- (id) initWithKey: (NSString*) key andValue: (NSString*) value;

@end

@interface BRHttpClient : NSObject {
    long _timeoutInMs;
}

- (id) init;

// Get
- (NSDictionary*) get: (NSString*) url;
- (NSDictionary*) get: (NSString*) url andParameters: (NSArray*) parameters;
- (NSDictionary*) get: (NSString*) url andHeaders: (NSDictionary*) headers;
- (NSDictionary*) get: (NSString*) url andHeaders: (NSDictionary*) headers andParameters: (NSArray*) parameters;
- (BRJsonResponse*) getWithResponseData: (NSString*) url andHeaders: (NSDictionary*) headers andParameters: (NSArray*) parameters;

// Post
- (NSDictionary*) post: (NSString*) url andJsonObject: (NSDictionary*) jsonObject;
- (NSDictionary*) post: (NSString*) url andJsonObject: (NSDictionary*) jsonObject andHeaders: (NSDictionary*) headers;
- (BRJsonResponse*) postWithResponseData: (NSString*) url andJsonObject: (NSDictionary*) jsonObject;
- (BRJsonResponse*) postWithResponseData: (NSString*) url andJsonObject: (NSDictionary*) jsonObject andHeaders: (NSDictionary*) headers;

// Put
- (NSDictionary*) put: (NSString*) url andJsonObject: (NSDictionary*) jsonObject andHeaders: (NSDictionary*) headers;
- (NSDictionary*) put: (NSString*) url andBody: (NSString*) body andHeaders: (NSDictionary*) headers;
- (BRJsonResponse*) putWithResponseData: (NSString*) url andBody: (NSString*) body andHeaders: (NSDictionary*) headers;

@end
