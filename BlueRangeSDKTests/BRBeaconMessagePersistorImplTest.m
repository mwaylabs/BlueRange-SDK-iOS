//
//  BRBeaconMessagePersistorImplTest.m
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

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "BRBeaconMessagePersistorImpl.h"
#import "BRLogIterator.h"
#import "BRDummyFileAccessor.h"
#import "BRDummyTracer.h"
#import "BRIBeaconMessage.h"
#import "BRBeaconMessageLog.h"
#import "BRRelutionTagMessageV1.h"

@interface BRBeaconMessagePersistorImplTest : XCTestCase

@property BRBeaconMessagePersistorImpl* persistor;
@property BRDummyFileAccessor* fileAccessor;
@property BRDummyTracer* tracer;

@end

@implementation BRBeaconMessagePersistorImplTest

- (void)setUp {
    [super setUp];
    self.fileAccessor = [[BRDummyFileAccessor alloc] init];
    self.tracer = [[BRDummyTracer alloc] init];
    self.persistor = [[BRBeaconMessagePersistorImpl alloc] initWithFileAccessor:self.fileAccessor andChunkSize:1];
    [self.persistor setTracer:self.tracer];
}

- (void) testLogIteratorWithZeroMessages {
    // 1. Write no message to the log
    // 2. Iterator should read one message from the log
    id<BRLogIterator> iterator = [self.persistor getLogIterator];
    BOOL hasNext = [iterator hasNext];
    XCTAssertFalse(hasNext);
}

- (void) testLogIteratorWithOneMessage {
    // 1. Write one message to the log
    int numMessages = 1;
    NSMutableArray* writtesMessages = [self writeArbitraryMessages:numMessages];
    
    // 2. Iterator should read one message from the log
    NSMutableArray* readMessages = [[NSMutableArray alloc] init];
    id<BRLogIterator> iterator = [self.persistor getLogIterator];
    while ([iterator hasNext]) {
        BRBeaconMessage* message = [iterator next];
        [readMessages addObject:message];
    }
    XCTAssertEqualObjects(writtesMessages, readMessages);
}

- (void) testEmptyLogAfterClearLog {
    int numMessages = 1;
    [self writeArbitraryMessages:numMessages];
    [self.persistor clearMessages];
    BRBeaconMessageLog* log = [self.persistor readLog];
    NSMutableArray* readMessages = [log beaconMessages];
    XCTAssertEqual(0, [readMessages count]);
}

- (void) testNoDirtyReadWithLogIterator {
    int numMessages = 1;
    NSMutableArray* writtenMessages = [self writeArbitraryMessages:numMessages];
    
    // Whenever hasNext returns true, it should
    // already have preloaded the next chunk because
    // the chunk could be removed right after calling
    // the hasNext method.
    // A clearMessages call right at the beginning of
    // the iteration should not result in an exception!
    NSMutableArray* readMessages = [[NSMutableArray alloc] init];
    id<BRLogIterator> iterator = [self.persistor getLogIterator];
    while ([iterator hasNext]) {
        [self.persistor clearMessages];
        BRBeaconMessage* message = [iterator next];
        [readMessages addObject:message];
    }
    
    XCTAssertEqualObjects(writtenMessages, readMessages);
}

- (void) testLogIteratorNoSuchElementException {
    // Only one message
    int numMessages = 1;
    [self writeArbitraryMessages:numMessages];
    
    id<BRLogIterator> iterator = [self.persistor getLogIterator];
    // Call next twice!
    [iterator next];
    XCTAssertThrows([iterator next]);
}

- (void) testLogIteratorAccessingCorruptFile {
    // 1. Simulate no message
    int numMessages = 1;
    [self writeArbitraryMessages:numMessages];
    
    // 2. Corrupt all files
    [self.fileAccessor corruptAllFiles];
    
    // 3. Iterator should return false on hasNext call.
    id<BRLogIterator> iterator = [self.persistor getLogIterator];
    BOOL hasNext = [iterator hasNext];
    XCTAssertFalse(hasNext);
}

- (void) testGetTotalMessagesInLog {
    // 1. Simulate no message
    int numMessages = 3;
    [self writeArbitraryMessages:numMessages];
    
    // Get total messages
    int actualNumMessages = [self.persistor getTotalMessages];
    
    // Validate
    XCTAssertEqual(numMessages, actualNumMessages);
}

// PersistorImpl specific test methods:

- (void) testLogIteratorIteratingOverCachedChunk {
    // We need one message and a chunk size of 2!
    int numMessages = 1;
    int chunkSize = 2;
    self.persistor = [[BRBeaconMessagePersistorImpl alloc] initWithFileAccessor:self.fileAccessor andChunkSize:chunkSize];
    NSMutableArray* writtenMessages = [self writeArbitraryMessages:numMessages];
    
    // Iterator should iterate over the cached chunk
    NSMutableArray* readMessages = [[NSMutableArray alloc] init];
    id<BRLogIterator> iterator = [self.persistor getLogIterator];
    while ([iterator hasNext]) {
        BRBeaconMessage* message = [iterator next];
        [readMessages addObject:message];
    }
    XCTAssertEqualObjects(writtenMessages, readMessages);
}

- (void) testLogIteratorNextCalledTwice {
    // We need one message and a chunk size of 2!
    int numMessages = 2;
    int chunkSize = 1;
    self.persistor = [[BRBeaconMessagePersistorImpl alloc] initWithFileAccessor:self.fileAccessor andChunkSize:chunkSize];
    NSMutableArray* writtenMessages = [self writeArbitraryMessages:numMessages];
    
    NSMutableArray* readMessages = [[NSMutableArray alloc] init];
    id<BRLogIterator> iterator = [self.persistor getLogIterator];
    while ([iterator hasNext]) {
        //First chunk should be loaded!
        BRBeaconMessage* message = [iterator next];
        
        // Second chunk should be loaded! Here the
        // preload mechanism of hasNext does not load the chunk.
        // That's why next should also load it.
        BRBeaconMessage* message2 = [iterator next];
        
        [readMessages addObject:message];
        [readMessages addObject:message2];
    }
    XCTAssertEqualObjects(writtenMessages, readMessages);
}

// This is just a test to see the number of bytes saved for each chunk.
- (void) testChunkSpaceUsage {
    // 1. Simulate extreme maximum space usage:
    // 2 hours sending 3 messages per second
    int numMessages = 2*60*60*3;
    // 2 hours a week 3 years and 2 messages/sec.
    // However in 3 years the log should be cleared at least once...
    //int numMessages = 3*53*2*60*60*2;
    
    int chunkSize = 100;
    BRDummyFileAccessor* f = [[BRDummyFileAccessor alloc] init];
    self.persistor = [[BRBeaconMessagePersistorImpl alloc] initWithFileAccessor:f andChunkSize:chunkSize];
    BRBeaconMessagePersistorImpl* p = (BRBeaconMessagePersistorImpl*)self.persistor;
    [p setZippingEnabled:true];
    
    // Simulate alternatively sending iBeacon and Relution Tag messages.
    NSMutableArray* messages = [[NSMutableArray alloc] init];
    for (int i = 0; i < numMessages; i+=2) {
        BRBeaconMessage* message1 = [self getArbitraryIBeacon];
        [messages addObject:message1];
    }
    for (int i = 0; i < numMessages; i+=2) {
        BRBeaconMessage* message2 = [self getArbitraryRelutionTagMessage];
        [messages addObject:message2];
    }
    for (BRBeaconMessage* message in messages) {
        [self.persistor writeMessage:message];
    }
    
    double logSizeInBytes = (double)[p getLogSizeInBytes];
    NSLog(@"Log size for %d messages with chunk size %d: %f kB.", numMessages, chunkSize, logSizeInBytes/1024);
    
    // RESULTS: 1 hour //
    // Chunk size: 100
    //      Zipping disabled: Log size for 21600 messages with chunk size 100: 1282 kB.
    //      Zipping enabled:  Log size for 21600 messages with chunk size 100: 80 kB.
    
    // RESULTS: 3 years
    // Chunk size: 100
    //      Zipping disabled: Log size for 2289600 messages with chunk size 100: 135967 kB.
    //      Zipping enabled:  Log size for 2289600 messages with chunk size 100: 8471 kB.
    
    // Overall log size should not be greater than 10 MB
    XCTAssertTrue(logSizeInBytes < (10 * 1024 * 1024));
}

- (void) testIfMaxLogSizeReachedDoNotAddMessages {
    // Write one message to the log
    int numMessages = 2;
    int maxLogSize = 1;
    BRBeaconMessagePersistorImpl* p = (BRBeaconMessagePersistorImpl*)self.persistor;
    [p setMaxLogSize:maxLogSize];
    NSMutableArray* writtenMessages = [self writeArbitraryMessages:numMessages];
    
    // 2. Iterator should read one message from the log
    NSMutableArray* readMessages = [[NSMutableArray alloc] init];
    id<BRLogIterator> iterator = [self.persistor getLogIterator];
    while ([iterator hasNext]) {
        BRBeaconMessage* message = [iterator next];
        [readMessages addObject:message];
    }
    XCTAssertEqualObjects([writtenMessages subarrayWithRange:NSMakeRange(0, 1)], readMessages);
}

- (NSMutableArray*) writeArbitraryMessages: (int) numOfMessages {
    NSMutableArray* beaconMessages = [[NSMutableArray alloc] init];
    for (int i = 0; i < numOfMessages; i++) {
        BRIBeaconMessage* beaconMessage = [self getArbitraryIBeacon];
        [beaconMessages addObject:beaconMessage];
        [self.persistor writeMessage:beaconMessage];
    }
    return beaconMessages;
}

- (BRIBeaconMessage*) getArbitraryIBeacon {
    NSString* uuid = @"b9407f30-f5f8-466e-aff9-25556b57fe6d";
    int major = 45;
    int minor = 1;
    int rssi = -50;
    BRIBeaconMessage* message = [[BRIBeaconMessage alloc] initWithUUID:[[NSUUID alloc] initWithUUIDString:uuid] major:major minor:minor rssi:rssi];
    return message;
}

- (BRBeaconMessage*) getArbitraryRelutionTagMessage {
    NSMutableArray* tags = [[NSMutableArray alloc] init];
    [tags addObject:[NSNumber numberWithLong:12]];
    [tags addObject:[NSNumber numberWithLong:15]];
    [tags addObject:[NSNumber numberWithLong:20]];
    BRRelutionTagMessageV1* message = [[BRRelutionTagMessageV1 alloc] initWithTags:tags andRssi:-50 andTxPower:-22];
    return message;
}

- (void)tearDown {
    [super tearDown];
}

@end
