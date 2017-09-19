//
//  BRBeaconMessageQueuedStreamNode.m
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

#import "BRBeaconMessageQueuedStreamNode.h"

const int DEFAULT_MAXIMUM_SIZE = INT_MAX;
const NSTimeInterval QUEUED_STREAM_NODE_SLEEP_TIME = 0.1;

@interface BRBeaconMessageQueuedStreamNode()

- (void) initMessageQueue;
- (void) pushBeaconMessage: (BRBeaconMessage*) beaconMessage;

@end

@implementation BRBeaconMessageQueuedStreamNode

- (id) initWithSender:(BRBeaconMessageStreamNode *)sender {
    if (self = [super initWithSender:sender]) {
        [self initMessageQueue];
    }
    return self;
}

- (id) initWithSenders:(NSArray *)senders {
    if (self = [super initWithSenders:senders]) {
        [self initMessageQueue];
    }
    return self;
}

- (void) initMessageQueue {
    self->_maximumSize = DEFAULT_MAXIMUM_SIZE;
    self->_messageQueue = [[NSMutableArray alloc] init];
}

- /* override */ (void) onReceivedMessage: (BRBeaconMessageStreamNode *) senderNode withMessage: (BRBeaconMessage*) message {
    [self pushBeaconMessage:message];
}

- (void) pushBeaconMessage: (BRBeaconMessage*) beaconMessage {
    // Do not add the message to the list, if the queue is full.
    if ([self->_messageQueue count] >= self.maximumSize) {
        return;
    }
    // Adding the beacon messages is synchronized as it is typical for producer consumer scenarios.
    @synchronized(self->_messageQueue) {
        [self->_messageQueue addObject:beaconMessage];
    }
}

- (BRBeaconMessage*) pullBeaconMessage {
    while ([self->_messageQueue count] == 0) {
        @synchronized(self->_messageQueue) {
            [NSThread sleepForTimeInterval:((double)QUEUED_STREAM_NODE_SLEEP_TIME)];
        }
    }
    @synchronized(self->_messageQueue) {
        BRBeaconMessage* beaconMessage = [self->_messageQueue objectAtIndex:0];
        [self->_messageQueue removeObjectAtIndex:0];
        return beaconMessage;
    }
}

@end
