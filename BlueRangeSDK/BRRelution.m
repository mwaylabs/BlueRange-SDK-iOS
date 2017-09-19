//
//  BRRelution.m
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

#import "BRRelution.h"
#import "BRHttpClient.h"
#import "BRJsonUtils.h"
#import "BRNetwork.h"
#import "BRIBeacon.h"
#import "BRFilter.h"
#import "BRStringFilter.h"
#import "BRLogOpFilter.h"
#import "BRLongFilter.h"

// Private methods
@interface BRRelution()

- (void) login;
- (NSString*) getEncodedAuthorizationString: (NSString*) username password: (NSString*) password;
- (NSURL*) getUrlForIBeaconActionMapping: (BRIBeacon*) iBeacon;
- (NSString*) getFilterStringForIBeacon: (BRIBeacon*) iBeacon;

- (void) verifyRelutionStatus: (NSDictionary*) responseObject;
- (BOOL) isSuccessStatusCode: (int) statusCode;

@end

@implementation BRRelutionException : NSException
@end
@implementation BRLoginException : NSException
@end

@implementation BRRelution

- (id) initWithBaseUrl: (NSString*) baseUrl andUsername: (NSString*) username andPassword: (NSString*) password {
    if (self = [super init]) {
        self->_baseUrl = baseUrl;
        self->_username = username;
        self->_password = password;
        self->_httpClient = [[BRHttpClient alloc] init];
        [self login];
    }
    return self;
}

- (BOOL) isServerAvailable {
    return [BRNetwork isServerAvailable:self.baseUrl];
}

- (void) login {
    @try {
        NSMutableDictionary* loginJson = [[NSMutableDictionary alloc] init];
        [loginJson setObject:[NSNull null] forKey:@"orgaName"];
        [loginJson setObject:self->_username forKey:@"userName"];
        [loginJson setObject:self->_password forKey:@"password"];
        [loginJson setObject:[NSNull null] forKey:@"email"];
        
        NSString* url = [NSString stringWithFormat:@"%@%@", self->_baseUrl, @"/gofer/security/rest/auth/login"];
        BRJsonResponse* response = [self->_httpClient postWithResponseData:url andJsonObject:loginJson];
        
        if ([self isSuccessStatusCode:[response statusCode]]) {
            NSString* jsonString = [[NSString alloc] initWithData:[response responseBody] encoding:NSUTF8StringEncoding];
            NSMutableDictionary* jsonResponse = [BRJsonUtils getJsonFromString:jsonString];
            NSMutableDictionary* user = [BRJsonUtils getJsonValueForKey:@"user" andDictionary:jsonResponse];
            self->_organizationUuid = [user objectForKey:@"organizationUuid"];
            self->_userUuid = [user objectForKey:@"uuid"];
        } else if (response.statusCode == 401) {
            @throw [BRLoginException exceptionWithName:@"" reason:@"" userInfo:nil];
        } else {
            @throw [BRRelutionException exceptionWithName:@"" reason:@"" userInfo:nil];
        }
        
    } @catch (BRLoginException* e) {
        @throw [BRLoginException exceptionWithName:@"" reason:@"" userInfo:nil];
    } @catch (NSException* e) {
        @throw [BRRelutionException exceptionWithName:@"" reason:@"" userInfo:nil];
    }
}

- (BRAdvertisingMessagesConfiguration*) getAdvertisingMessagesConfiguration {
    @try {
        NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
        [headers setObject:self->_userUuid forKey:@"X-Gofer-User"];
        
        NSString* url = [NSString stringWithFormat:@"%@%@%@", self->_baseUrl,
                         @"/relution/api/v1/iot/advertisingMessages/configuration/",
                         self->_organizationUuid];
        NSDictionary* responseObject = [self->_httpClient get:url];
        
        [self verifyRelutionStatus:responseObject];
        NSArray* results = [responseObject objectForKey:@"results"];
        BRAdvertisingMessagesConfiguration* configuration = [[BRAdvertisingMessagesConfiguration alloc] initWithJsonArray:[results mutableCopy]];
        return configuration;
        
    } @catch (NSException* e) {
        @throw [NSException exceptionWithName:@"Requesting sites failed. " reason:@"" userInfo:nil];
    }
}

- (void) sendAnalyticsReport: (NSDictionary*) jsonReport {
    @try {
        NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
        [headers setObject:self->_userUuid forKey:@"X-Gofer-User"];
        [headers setObject:@"Basic c29mb2JvZGVqZXNv" forKey:@"Authorization"];
        
        NSString* url = [NSString stringWithFormat:@"%@%@", self->_baseUrl,
                         @"/relution/api/v1/iot/analytics/raw"];
        NSDictionary* responseObject = [self->_httpClient post:url andJsonObject:jsonReport andHeaders:headers];
        
        [self verifyRelutionStatus:responseObject];
        
    } @catch (NSException* e) {
        @throw [NSException exceptionWithName:@"Sending analytics report failed. " reason:@"" userInfo:nil];
    }
}

- (void) sendCalibratedRssiForIBeacon: (BRIBeacon*) iBeacon andCalibratedRssi: (int) calibratedRssi {
    @try {
        NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
        [headers setObject:self->_userUuid forKey:@"X-Gofer-User"];
        NSString* encodedAuthorizationString = [self getEncodedAuthorizationString: self->_username password: self->_password];
        [headers setObject:[NSString stringWithFormat:@"Basic %@", encodedAuthorizationString] forKey:@"Authorization"];
        
        NSString* body = [NSString stringWithFormat:@"%d", calibratedRssi];
        
        BRFilter* filter = [[BRLogOpFilter alloc] initWithOperation:AND,
                          [[BRStringFilter alloc] initWithFieldName:@"type" andValue:@"IBEACON"],
                          [[BRStringFilter alloc] initWithFieldName:@"beaconUuid" andValue:iBeacon.uuid.UUIDString.uppercaseString],
                          [[BRLongFilter alloc] initWithFieldName:@"major" andValue:iBeacon.major],
                          [[BRLongFilter alloc] initWithFieldName:@"minor" andValue:iBeacon.minor],
                          nil];
        
        NSString* url = [NSString stringWithFormat:@"%@%@%@", self->_baseUrl,
                         @"/relution/api/v1/iot/advertisingMessages/calibrateBeaconRssi?filter=",
                         [filter description]];
        NSDictionary* responseObject = [self->_httpClient put:url andBody:body andHeaders:headers];
        
        [self verifyRelutionStatus:responseObject];
        
    } @catch (NSException* e) {
        @throw [NSException exceptionWithName:@"Sending calibrated RSSI failed. " reason:@"" userInfo:nil];
    }
}

- (NSString*) getEncodedAuthorizationString: (NSString*) username password: (NSString*) password {
    NSString* authorizationString = [NSString stringWithFormat:@"%@:%@", username, password];
    NSData *authorizationData = [authorizationString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedAuthorizationString = [authorizationData base64EncodedStringWithOptions:0];
    return encodedAuthorizationString;
}

- (BRRelutionActionInformation*) getActionsForIBeacon: (BRIBeacon*) iBeacon {
    @try {
        NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
        [headers setObject:self->_userUuid forKey:@"X-Gofer-User"];
        
        NSString* url = [self getUrlForIBeaconActionMapping:iBeacon].absoluteString;
        NSDictionary* responseObject = [self->_httpClient get:url andHeaders:headers];
        
        [self verifyRelutionStatus:responseObject];
        
        BRRelutionActionInformation* actionInformation = [[BRRelutionActionInformation alloc] init];
        [actionInformation setActionInformationObject:responseObject];
        return actionInformation;
        
    } @catch (NSException* e) {
        @throw [NSException exceptionWithName:@"Getting actions for iBeacon failed. " reason:@"" userInfo:nil];
    }
}

- (NSURL*) getUrlForIBeaconActionMapping: (BRIBeacon*) iBeacon {
    // Request has the following form:
    /* /campaigns/sdk
     ?filter=
     {
     "type": "logOp",
     "operation": "AND",
     "filters": [{
     "type": "string",
     "fieldName": "devices.organizationUuid",
     "value": "65AC11A8-99BE-45BB-80A0-F8C51FF6476F"
     }, {
     "type": "string",
     "fieldName": "devices.advertisingMessages.ibeaconUuid",
     "value": "B9407F30-F5F8-466E-AFF9-25556B57FE6D"
     }, {
     "type": "string",
     "fieldName": "devices.advertisingMessages.ibeaconMajor",
     "value": "1"
     }, {
     "type": "string",
     "fieldName": "devices.advertisingMessages.ibeaconMinor",
     "value": "1"
     }]
     }*/
    
    NSString* baseEndpointUrl = [NSString stringWithFormat:@"%@%@", self->_baseUrl, @"/relution/api/v1/iot/campaigns/actions"];
    NSURLComponents* components = [NSURLComponents componentsWithString:baseEndpointUrl];
    
    NSString* filterString = [self getFilterStringForIBeacon:iBeacon];
    NSURLQueryItem *filterItem = [NSURLQueryItem queryItemWithName:@"filter" value:filterString];
    
    components.queryItems = @[filterItem];
    NSURL* url = components.URL;
    
    return url;
}

- (NSString*) getFilterStringForIBeacon: (BRIBeacon*) iBeacon {
    NSMutableDictionary* filterObject = [[NSMutableDictionary alloc] init];
    
    @try {
        
        [filterObject setObject:@"logOp" forKey:@"type"];
        [filterObject setObject:@"AND" forKey:@"operation"];
        NSMutableArray* filtersArray = [[NSMutableArray alloc] init];
        NSMutableDictionary* organizationUuidObject = [[NSMutableDictionary alloc] init];
        [organizationUuidObject setObject:@"string" forKey:@"type"];
        [organizationUuidObject setObject:@"devices.organizationUuid" forKey:@"fieldName"];
        [organizationUuidObject setObject:self->_organizationUuid forKey:@"value"];
        NSMutableDictionary* iBeaconUuidObject = [[NSMutableDictionary alloc] init];
        [iBeaconUuidObject setObject:@"string" forKey:@"type"];
        [iBeaconUuidObject setObject:@"devices.advertisingMessages.beaconUuid" forKey:@"fieldName"];
        [iBeaconUuidObject setObject:[iBeacon.uuid.UUIDString lowercaseString] forKey:@"value"];
        NSMutableDictionary* iBeaconMajorObject = [[NSMutableDictionary alloc] init];
        [iBeaconMajorObject setObject:@"string" forKey:@"type"];
        [iBeaconMajorObject setObject:@"devices.advertisingMessages.major" forKey:@"fieldName"];
        [iBeaconMajorObject setObject:[NSString stringWithFormat:@"%d", iBeacon.major] forKey:@"value"];
        NSMutableDictionary* iBeaconMinorObject = [[NSMutableDictionary alloc] init];
        [iBeaconMinorObject setObject:@"string" forKey:@"type"];
        [iBeaconMinorObject setObject:@"devices.advertisingMessages.minor" forKey:@"fieldName"];
        [iBeaconMinorObject setObject:[NSString stringWithFormat:@"%d", iBeacon.minor] forKey:@"value"];
        [filtersArray addObject:organizationUuidObject];
        [filtersArray addObject:iBeaconUuidObject];
        [filtersArray addObject:iBeaconMajorObject];
        [filtersArray addObject:iBeaconMinorObject];
        [filterObject setObject:filtersArray forKey:@"filters"];
        
    } @catch(NSException* e) {
        // Should not be reached!
    }
    return [BRJsonUtils jsonStringForDictionary:filterObject];
}

- (BRRelutionTagInfos*) getRelutionTagInfos {
    @try {
        NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
        [headers setObject:self->_userUuid forKey:@"X-Gofer-User"];
        [headers setObject:@"Basic c29mb2JvZGVqZXNv" forKey:@"Authorization"];
        
        BRFilter* filter = [[BRStringFilter alloc] initWithFieldName:@"organizationUuid" andValue:self->_organizationUuid];
        NSString* url = [NSString stringWithFormat:@"%@%@%@", self->_baseUrl,
                                           @"/relution/api/v1/tags?filter=",
                                          [filter description]];
        
        NSDictionary* responseObject = [self->_httpClient get:url andHeaders:headers];
        
        [self verifyRelutionStatus:responseObject];
        
        NSArray* results = [responseObject objectForKey:@"results"];
        BRRelutionTagInfos* relutionTagInfos = [[BRRelutionTagInfos alloc] initWithJsonArray:[results mutableCopy]];
        return relutionTagInfos;
        
    } @catch (NSException* e) {
        @throw [NSException exceptionWithName:@"Getting BRRelution Tag infos failed. " reason:@"" userInfo:nil];
    }
}

- (void) verifyRelutionStatus: (NSDictionary*) responseObject {
    int status = [[responseObject objectForKey:@"status"] intValue];
    if (status != 0) {
        NSString* exceptionMessage = [NSString stringWithFormat:@"BRRelution status = %d", status];
        if ([responseObject objectForKey:@"message"] != nil) {
            exceptionMessage = [NSString stringWithFormat:@"%@, message = %@", exceptionMessage, [responseObject objectForKey:@"message"]];
        }
        @throw [NSException exceptionWithName:exceptionMessage reason:@"" userInfo:nil];
    }
}

- (BOOL) isSuccessStatusCode:(int)statusCode {
    return ((statusCode >= 200) && (statusCode <= 299));
}

@end
