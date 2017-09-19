//
//  BRRelutionHeatmapReportBuilder.m
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

#import "BRRelutionHeatmapReportBuilder.h"
#import "BRBeaconJoinMeMessage.h"
#import "BRRelutionHeatmapReport.h"
#import "BRJsonUtils.h"

// BRConstants
const long DEFAULT_INTERVAL_DURATION_IN_MS = 20000L;

// Private methods
@interface BRRelutionHeatmapReportBuilder()

// New report
- (void) createNewReport;

// Add message
- (void) addJoinMeMessage: (BRBeaconJoinMeMessage*) joinMeMessage;
- (void) createNewInterval: (BRBeaconJoinMeMessage*) joinMeMessage;
- (void) addJoinMeMessageToInterval: (BRBeaconJoinMeMessage*) joinMeMessage;
- (void) updateEndTime: (BRBeaconJoinMeMessage*) joinMeMessage;
- (void) updateDiscoveryNodes: (BRBeaconJoinMeMessage*) joinMeMessage;
- (NSMutableDictionary*) getNode: (int) nodeId;
- (void) createAndAddNodeToDiscoveredNodes: (int) nodeId;
- (void) updateNode: (NSMutableDictionary*) node withMessage: (BRBeaconJoinMeMessage*) message;
- (void) collectMessage: (BRBeaconJoinMeMessage*) message forNode: (NSMutableDictionary*) node;
- (void) updateNodeEntriesOfNode: (NSMutableDictionary*) node;
- (BOOL) intervalEndReached: (BRBeaconJoinMeMessage*) joinMeMessage;
- (void) addIntervalToReport;

// Build report
- (BRRelutionHeatmapReport*) createActivityReport;

@end

@implementation BRRelutionHeatmapReportBuilder

- (id) initWithOrganizationUuid: (NSString*) organizationUuid {
    if (self = [super init]) {
        self->_intervals = nil;
        self->_interval = nil;
        self->_nodesInInterval = nil;
        self->_organizationUuid = organizationUuid;
        self->_intervalDurationInMs = DEFAULT_INTERVAL_DURATION_IN_MS;
        self->_messagesInNode = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- /* override */ (void) newReport {
    [self createNewReport];
}

- (void) createNewReport {
    self->_intervals = [[NSMutableArray alloc] init];
    self->_interval = nil;
    self->_nodesInInterval = nil;
    self->_messagesInNode = [[NSMutableDictionary alloc] init];
}

- /* override */ (void) addBeaconMessage: (BRBeaconMessage*) message {
    if ([message isKindOfClass:[BRBeaconJoinMeMessage class]]) {
        BRBeaconJoinMeMessage* joinMeMessage = (BRBeaconJoinMeMessage*)message;
        @try {
            [self addJoinMeMessage:joinMeMessage];
        } @catch (BRJSONException* exception) {
            @throw [BRBuildException exceptionWithName:@"" reason:@"" userInfo:nil];
        }
    }
}

- (void) addJoinMeMessage: (BRBeaconJoinMeMessage*) joinMeMessage {
    if (self->_interval == nil) {
        // Create interval when no interval exists yet.
        [self createNewInterval:joinMeMessage];
    } else if ([self intervalEndReached:joinMeMessage]) {
        // If an interval exists and the end of the interval has been reached,
        // finish the current interval and create a new one.
        [self addIntervalToReport];
        [self createNewInterval:joinMeMessage];
    }
    [self addJoinMeMessageToInterval:joinMeMessage];
}

- (void) createNewInterval: (BRBeaconJoinMeMessage*) joinMeMessage {
    self->_interval = [[NSMutableDictionary alloc] init];
    self->_nodesInInterval = [[NSMutableArray alloc] init];
    NSTimeInterval messageTimestamp = [[joinMeMessage timestamp] timeIntervalSince1970];
    long long messageTimestampInMs = messageTimestamp * 1000;
    [self->_interval setObject:[NSNumber numberWithLongLong:messageTimestampInMs] forKey:@"startTime"];
    [self->_interval setObject:[NSNumber numberWithLongLong:messageTimestampInMs] forKey:@"endTime"];
    [self->_interval setObject:self->_nodesInInterval forKey:@"discoveredNodes"];
}

- (void) addJoinMeMessageToInterval: (BRBeaconJoinMeMessage*) joinMeMessage {
    [self updateEndTime:joinMeMessage];
    [self updateDiscoveryNodes:joinMeMessage];
}

- (void) updateEndTime: (BRBeaconJoinMeMessage*) joinMeMessage {
    NSTimeInterval messageTimestamp = [[joinMeMessage timestamp] timeIntervalSince1970];
    long long messageTimestampInMs = messageTimestamp * 1000;
    [self->_interval setObject:[NSNumber numberWithLongLong:messageTimestampInMs] forKey:@"endTime"];
}

- (void) updateDiscoveryNodes: (BRBeaconJoinMeMessage*) joinMeMessage {
    int nodeId = [joinMeMessage nodeId];
    NSMutableDictionary* node = [self getNode:nodeId];
    if (node == nil) {
        [self createAndAddNodeToDiscoveredNodes:nodeId];
        node = [self getNode:nodeId];
    }
    [self updateNode:node withMessage:joinMeMessage];
}

- (NSMutableDictionary*) getNode: (int) nodeId {
    for (int i = 0; i < [self->_nodesInInterval count]; i++) {
        NSMutableDictionary* node = [BRJsonUtils getJsonValueAtIndex:i forArray:self->_nodesInInterval];
        int foundNodeId = [[BRJsonUtils getJsonValueForKey:@"nodeId" andDictionary:node] intValue];
        if (foundNodeId == nodeId) {
            return node;
        }
    }
    return nil;
}

- (void) createAndAddNodeToDiscoveredNodes: (int) nodeId {
    NSMutableDictionary* node = [[NSMutableDictionary alloc] init];
    [node setObject:[NSNumber numberWithInt:nodeId] forKey:@"nodeId"];
    [node setObject:[NSNumber numberWithInt:0] forKey:@"packetCount"];
    [node setObject:[NSNumber numberWithInt:0] forKey:@"avgRssi"];
    [self->_nodesInInterval addObject:node];
}

- (void) updateNode: (NSMutableDictionary*) node withMessage: (BRBeaconJoinMeMessage*) message {
    [self collectMessage:message forNode:node];
    [self updateNodeEntriesOfNode:node];
}

- (void) collectMessage: (BRBeaconJoinMeMessage*) message forNode: (NSMutableDictionary*) node {
    if ([self->_messagesInNode objectForKey:node] == nil) {
        NSMutableArray* messages = [[NSMutableArray alloc] init];
        [self->_messagesInNode setObject:messages forKey:node];
    }
    NSMutableArray* messages = [self->_messagesInNode objectForKey:node];
    [messages addObject:message];
}

- (void) updateNodeEntriesOfNode: (NSMutableDictionary*) node {
    NSMutableArray* messages = [self->_messagesInNode objectForKey:node];
    int newPacketCount = (int)[messages count];
    int newAvgRssi = 0;
    for (int i = 0; i < [messages count];i++) {
        BRBeaconJoinMeMessage* message = [messages objectAtIndex:i];
        float rssi = [message rssi];
        newAvgRssi += rssi;
    }
    newAvgRssi /= (int32_t)[messages count];
    [node setObject:[NSNumber numberWithInt:newPacketCount] forKey:@"packetCount"];
    [node setObject:[NSNumber numberWithInt:newAvgRssi] forKey:@"avgRssi"];
}

- (BOOL) intervalEndReached: (BRBeaconJoinMeMessage*) joinMeMessage {
    long long startTimeInMs = [[BRJsonUtils getJsonValueForKey:@"startTime" andDictionary:self->_interval] longLongValue];
    NSTimeInterval messageTimestamp = [[joinMeMessage timestamp] timeIntervalSince1970];
    long long currentTimeInMs = messageTimestamp * 1000;
    return (currentTimeInMs-startTimeInMs) >= DEFAULT_INTERVAL_DURATION_IN_MS;
}

- (void) addIntervalToReport {
    [self->_intervals addObject:self->_interval];
    self->_interval = nil;
}

- /* override */ (BRRelutionHeatmapReport*) buildReport {
    if (self->_interval != nil) {
        [self addIntervalToReport];
    }
    BRRelutionHeatmapReport* report = nil;
    @try {
        report = [self createActivityReport];
    } @catch (BRJSONException* exception) {
        @throw [BRBuildException exceptionWithName:@"" reason:@"" userInfo:nil];
    }
    return report;
}

- (BRRelutionHeatmapReport*) createActivityReport {
    NSMutableDictionary* reportJsonObject = [[NSMutableDictionary alloc] init];
    [reportJsonObject setObject:self->_intervals forKey:@"report"];
    [reportJsonObject setObject:self->_organizationUuid forKey:@"organizationUUID"];
    BRRelutionHeatmapReport* __autoreleasing report = [[BRRelutionHeatmapReport alloc] initWithJsonReport:reportJsonObject];
    return report;
}

@end
