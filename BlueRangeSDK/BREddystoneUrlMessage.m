//
//  BREddystoneUrlMessage.m
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

#import "BREddystoneUrlMessage.h"

@implementation BREddystoneUrlScheme

- (id) initWithCode: (int) code expansion: (NSString*) expansion {
    if (self = [super init]) {
        self->_code = code;
        self->_expansion = expansion;
    }
    return self;
}

@end

@implementation BREddystoneStringExpander

- (id) initWithAsciiCode: (int) code expansion:(NSString *)expansion {
    if (self = [super init]) {
        self->_asciiCode = code;
        self->_expansion = expansion;
    }
    return self;
}

@end

@implementation BRWrongUrlFormatException
@end

// Private classes
@interface BREddystoneUrlMessage ()

+ (NSString*) getUrlScheme: (uint8_t*) bytes andStartByte: (int) startByte;
+ (NSString*) getUrlRemainingPart: (uint8_t*) bytes andStartByte: (int) startByte andLength: (int) length;
+ (NSString*) getStringExpanderForByte: (uint8_t) byte;

@end

// BRConstants
NSString* EDDYSTONE_URL_MESSAGE_URL_KEY = @"url";

NSArray* urlSchemes = nil;
NSArray* urlExpanders = nil;

@implementation BREddystoneUrlMessage

+ (void) initialize {
    if (self == [BREddystoneMessage class]) {
        
    }
    urlSchemes = [[NSArray alloc] initWithObjects:
                      [[BREddystoneUrlScheme alloc] initWithCode:0x00 expansion:@"http://www."],
                      [[BREddystoneUrlScheme alloc] initWithCode:0x01 expansion:@"https://www."],
                      [[BREddystoneUrlScheme alloc] initWithCode:0x02 expansion:@"http://"],
                      [[BREddystoneUrlScheme alloc] initWithCode:0x03 expansion:@"https://"],
                      nil];
    
    urlExpanders = [[NSArray alloc] initWithObjects:
                        [[BREddystoneStringExpander alloc] initWithAsciiCode:0x00 expansion:@".com/"],
                        [[BREddystoneStringExpander alloc] initWithAsciiCode:0x01 expansion:@".org/"],
                        [[BREddystoneStringExpander alloc] initWithAsciiCode:0x02 expansion:@".edu/"],
                        [[BREddystoneStringExpander alloc] initWithAsciiCode:0x03 expansion:@".net/"],
                        [[BREddystoneStringExpander alloc] initWithAsciiCode:0x04 expansion:@".info/"],
                        [[BREddystoneStringExpander alloc] initWithAsciiCode:0x05 expansion:@".biz/"],
                        [[BREddystoneStringExpander alloc] initWithAsciiCode:0x06 expansion:@".gov/"],
                        [[BREddystoneStringExpander alloc] initWithAsciiCode:0x07 expansion:@".com/"],
                        [[BREddystoneStringExpander alloc] initWithAsciiCode:0x08 expansion:@".org/"],
                        [[BREddystoneStringExpander alloc] initWithAsciiCode:0x09 expansion:@".edu/"],
                        [[BREddystoneStringExpander alloc] initWithAsciiCode:0x0a expansion:@".net/"],
                        [[BREddystoneStringExpander alloc] initWithAsciiCode:0x0b expansion:@".info/"],
                        [[BREddystoneStringExpander alloc] initWithAsciiCode:0x0c expansion:@".biz/"],
                        [[BREddystoneStringExpander alloc] initWithAsciiCode:0x0d expansion:@".gov/"],
                        nil];
}

- (id) initWithUrl: (NSString*) url {
    return [self initWithUrl:url andTxPower:-50];
}

- (id) initWithUrl: (NSString*) url andTxPower: (int) txPower {
    return [self initWithUrl:url andTxPower:txPower andRssi:-60];
}

- (id) initWithUrl: (NSString*) url andTxPower: (int) txPower andRssi: (int) rssi {
    if (self = [super init]) {
        self->_url = url;
        self->_txPower = txPower;
        [self setRssi:rssi];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        NSString* url = [coder decodeObjectForKey:EDDYSTONE_URL_MESSAGE_URL_KEY];
        self->_url = url;
    }
    return self;
}

- (NSString *) getDescription {
    return [NSString stringWithFormat:@"Eddystone URL: %@", self.url];
}

- (BRBeaconMessage*) newCopy {
    BREddystoneUrlMessage *clonedMessage
        = [[BREddystoneUrlMessage alloc] initWithUrl:self->_url];
    return clonedMessage;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    BREddystoneUrlMessage *newMessage = [super copyWithZone:zone];
    return newMessage;
}

- (BOOL) isEqual:(id)object {
    if (!([object isKindOfClass:[BREddystoneUrlMessage class]])) {
        return false;
    }
    BREddystoneUrlMessage *message = (BREddystoneUrlMessage*)object;
    return [[message url] isEqual:[self url]];
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self->_url forKey:EDDYSTONE_URL_MESSAGE_URL_KEY];
}

- /* Override */ (short) txPower {
    return self->_txPower;
}

- /* Override */ (NSUInteger) hash {
    return [[self url] hash];
}

/**
 * Returns the Eddystone url string based on the byte array
 * as it is encoded in the Eddystone URL message. The byte array
 * must be ordered in big endian.
 * @param bytes the byte array as specified in the Eddystone URL message.
 * @return the URL that is encoded in the byte array.
 */
+ (NSString*) getUrlStringFromBytes: (uint8_t*) bytes withStartByte: (int) startByte andLength: (int) length {
    NSString* urlScheme = [BREddystoneUrlMessage getUrlScheme: bytes andStartByte: startByte];
    NSString* urlTail = [BREddystoneUrlMessage getUrlRemainingPart:bytes andStartByte:startByte+1 andLength:length-1];
    return [NSString stringWithFormat:@"%@%@", urlScheme, urlTail];
}

+ (NSString*) getUrlScheme: (uint8_t*) bytes andStartByte: (int) startByte {
    uint8_t b = bytes[startByte];
    for (BREddystoneUrlScheme* urlScheme in urlSchemes) {
        if ([urlScheme code] == b) {
            return [urlScheme expansion];
        }
    }
    @throw [BRWrongUrlFormatException exceptionWithName:@"URL scheme is wrong!" reason:@"" userInfo:nil];
}

+ (NSString*) getUrlRemainingPart: (uint8_t*) bytes andStartByte: (int) startByte andLength: (int) length {
    NSString* result = @"";
    for (int i = startByte; i < length; i++) {
        uint8_t b = bytes[i];
        
        if (b == 0) {
            break;
        }
        
        NSString* expander = [BREddystoneUrlMessage getStringExpanderForByte:b];
        if (expander != nil) {
            result = [NSString stringWithFormat:@"%@%@", result, expander];
        } else {
            char c = (char)b;
            result = [NSString stringWithFormat:@"%@%c", result, c];
        }
    }
    return result;
}

+ (NSString*) getStringExpanderForByte: (uint8_t) byte {
    for (BREddystoneStringExpander* stringExpander in urlExpanders) {
        if (byte == [stringExpander asciiCode]) {
            return [stringExpander expansion];
        }
    }
    return nil;
}

@end
