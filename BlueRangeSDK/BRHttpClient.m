//
//  BRHttpClient.m
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

#import "BRHttpClient.h"
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import "BRJsonUtils.h"
#import "BRConstants.h"

// BRConstants
const int DEFUALT_STATUS_CODE = -1;

@implementation BRRequestException : NSException
@end

@implementation BRJsonResponse : NSObject
@end

@implementation BRParameter

- (id) initWithKey: (NSString*) key andValue: (NSString*) value {
    if (self = [super init]) {
        self->_key = key;
        self->_value = value;
    }
    return self;
}

@end

// Private methods
@interface BRHttpClient()

- (void) configSslCertificateValidation: (ASIHTTPRequest*) request;

@end

@implementation BRHttpClient

- (id) init {
    if (self = [super init]) {
        self->_timeoutInMs = 10 * 1000;
        [ASIHTTPRequest setDefaultTimeOutSeconds:(self->_timeoutInMs / 1000)];
    }
    return self;
}

- (void) configSslCertificateValidation: (ASIHTTPRequest*) request {
    if ([kSdkMode isEqualToString:@"DEVELOPMENT_MODE"]) {
        [request setValidatesSecureCertificate:false];
    } else {
        // Reject untrusted certificates.
    }
}

- (NSDictionary*) get: (NSString*) url{
    NSMutableArray* parameters = [[NSMutableArray alloc] init];
    return [self get:url andParameters:parameters];
}

- (NSDictionary*) get: (NSString*) url andParameters: (NSArray*) parameters {
    NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
    return [self get:url andHeaders:headers andParameters:parameters];
}

- (NSDictionary*) get: (NSString*) url andHeaders: (NSDictionary*) headers {
    NSMutableArray* parameters = [[NSMutableArray alloc] init];
    return [self get:url andHeaders:headers andParameters:parameters];
}

- (NSDictionary*) get: (NSString*) url andHeaders: (NSDictionary*) headers andParameters: (NSArray*) parameters {
    BRJsonResponse* response = [self getWithResponseData:url andHeaders:headers andParameters:parameters];
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseBody options:kNilOptions error:&error];
    return json;
}

- (BRJsonResponse*) getWithResponseData: (NSString*) url andHeaders: (NSDictionary*) headers andParameters: (NSArray*) parameters {
    NSString* requestUrl = [NSString stringWithFormat:@"%@", url];
    @try {
        
        // Parameters
        if ([parameters count] > 0) {
            requestUrl = [NSString stringWithFormat:@"%@?=", requestUrl];
        }
        for (int i = 0; i < [parameters count]; i++) {
            if (i >= 0) {
                requestUrl = [NSString stringWithFormat:@"%@&", requestUrl];
            }
            NSString* parameter = [parameters objectAtIndex:i];
            requestUrl = [NSString stringWithFormat:@"%@%@", requestUrl, parameter];
        }
        
        // Request
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
        
        // Method
        [request setRequestMethod:@"GET"];
        
        // Header
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        for (NSString* key in [headers allKeys]) {
            NSString* value = [headers objectForKey:key];
            [request addRequestHeader:key value:value];
        }
        
        // SSL Certificate validation
        [self configSslCertificateValidation:request];
        
        // Send request
        [request startSynchronous];
        
        // Get status code
        BRJsonResponse* jsonResponse = [[BRJsonResponse alloc] init];
        jsonResponse.statusCode = [request responseStatusCode];
        jsonResponse.responseBody = [request responseData];
        
        return jsonResponse;
    } @catch (NSException* e) {
        NSString* message = [NSString stringWithFormat:@"Error with GET %@. ", url];
        @throw [BRRequestException exceptionWithName:message reason:@"" userInfo:nil];
    }
}

// Post

- (NSDictionary*) post: (NSString*) url andJsonObject: (NSDictionary*) jsonObject {
    NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
    BRJsonResponse* response = [self postWithResponseData:url andJsonObject:jsonObject andHeaders:headers];
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseBody options:kNilOptions error:&error];
    return json;
}

- (NSDictionary*) post: (NSString*) url andJsonObject: (NSDictionary*) jsonObject andHeaders: (NSDictionary*) headers {
    BRJsonResponse* response = [self postWithResponseData:url andJsonObject:jsonObject andHeaders:headers];
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseBody options:kNilOptions error:&error];
    return json;
}

- (BRJsonResponse*) postWithResponseData: (NSString*) url andJsonObject: (NSDictionary*) jsonObject {
    NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
    BRJsonResponse* response = [self postWithResponseData:url andJsonObject:jsonObject andHeaders:headers];
    return response;
}

- (BRJsonResponse*) postWithResponseData: (NSString*) url andJsonObject: (NSDictionary*) jsonObject andHeaders: (NSDictionary*) headers {
    NSString* requestUrl = [NSString stringWithFormat:@"%@", url];
    @try {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
        
        // Method
        [request setRequestMethod:@"POST"];
        
        // Header
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        for (NSString* key in [headers allKeys]) {
            NSString* value = [headers objectForKey:key];
            [request addRequestHeader:key value:value];
        }
        
        // Body
        NSString* jsonString = [BRJsonUtils jsonStringForDictionary:jsonObject];
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableData *body = [data mutableCopy];
        [request setPostBody:body];
        
        // SSL Certificate validation
        [self configSslCertificateValidation:request];
        
        // Send request
        [request startSynchronous];
        
        // Get status code
        BRJsonResponse* jsonResponse = [[BRJsonResponse alloc] init];
        jsonResponse.statusCode = [request responseStatusCode];
        jsonResponse.responseBody = [request responseData];
        
        return jsonResponse;
        
    } @catch (NSException* e) {
        NSString* message = [NSString stringWithFormat:@"Error with POST %@. ", url];
        @throw [BRRequestException exceptionWithName:message reason:@"" userInfo:nil];
    }
}

// Put

- (NSDictionary*) put: (NSString*) url andJsonObject: (NSDictionary*) jsonObject andHeaders: (NSDictionary*) headers {
    NSString* jsonString = [BRJsonUtils jsonStringForDictionary:jsonObject];
    return [self put:url andBody:jsonString andHeaders:headers];
}

- (NSDictionary*) put: (NSString*) url andBody: (NSString*) body andHeaders: (NSDictionary*) headers {
    BRJsonResponse* response = [self putWithResponseData:url andBody:body andHeaders:headers];
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseBody options:kNilOptions error:&error];
    return json;
}

- (BRJsonResponse*) putWithResponseData: (NSString*) url andBody: (NSString*) body andHeaders: (NSDictionary*) headers {
    NSString* requestUrl = [NSString stringWithFormat:@"%@", url];
    @try {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
        
        // Method
        [request setRequestMethod:@"PUT"];
        
        // Header
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        for (NSString* key in [headers allKeys]) {
            NSString* value = [headers objectForKey:key];
            [request addRequestHeader:key value:value];
        }
        
        // Body
        NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableData *body = [data mutableCopy];
        [request setPostBody:body];
        
        // SSL Certificate validation
        [self configSslCertificateValidation:request];
        
        // Send request
        [request startSynchronous];
        
        // Get status code
        BRJsonResponse* jsonResponse = [[BRJsonResponse alloc] init];
        jsonResponse.statusCode = [request responseStatusCode];
        jsonResponse.responseBody = [request responseData];
        
        return jsonResponse;
        
    } @catch (NSException* e) {
        NSString* message = [NSString stringWithFormat:@"Error with PUT %@. ", url];
        @throw [BRRequestException exceptionWithName:message reason:@"" userInfo:nil];
    }
}

@end
