//
//  BRHttpClient.h
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
