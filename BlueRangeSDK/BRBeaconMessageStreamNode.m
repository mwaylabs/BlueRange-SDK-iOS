//
//  BRBeaconMessageStreamNode.m
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

#import "BRBeaconMessageStreamNode.h"
#import "BRAbstract.h"

// Private methods
@interface BRBeaconMessageStreamNode()

- (void) initialize;
- (int) indexOfSender: (BRBeaconMessageStreamNode*) sender;

@end

@implementation BRBeaconMessageStreamNode

@synthesize senders;
@synthesize receivers;

// Public
- (id) init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (id) initWithSender: (BRBeaconMessageStreamNode *) sender {
    if (self = [super init]) {
        [self initialize];
        [self addSender:sender];
    }
    return self;
}

- (id) initWithSenders: (NSArray *) _senders {
    if (self = [super init]) {
        [self initialize];
        for (int i = 0; i < [_senders count]; i++) {
            BRBeaconMessageStreamNode *sender = [_senders objectAtIndex:i];
            [self addSender:sender];
        }
    }
    return self;
}

- (void) initialize {
    // The senders list should only hold weak references.
    self->senders = [NSPointerArray weakObjectsPointerArray];
    // Receivers, however, strong references
    self->receivers = [[NSMutableArray alloc] init];

}

- (void) addSender: (BRBeaconMessageStreamNode *) sender {
    // Add the this instance as a receiver to the sender.
    [sender addReceiver:self];
    // Add it to the list of senders.
    [self->senders addPointer:(__bridge void * _Nullable)(sender)];
}

- (void) removeSender: (BRBeaconMessageStreamNode *) sender {
    // Remove me from the receiver.
    [sender removeReceiver:self];
    // Remove me from the list of senders
    int index = [self indexOfSender:sender];
    [self->senders removePointerAtIndex:index];
}

- (int) indexOfSender: (BRBeaconMessageStreamNode*) sender {
    for (int i = 0; i < [self->senders count]; i++) {
        BRBeaconMessageStreamNode *currentSender = [senders pointerAtIndex:i];
        if (currentSender == sender) {
            return i;
        }
    }
    return -1;
}

- (void) addReceiver: (id<BRBeaconMessageStreamNodeReceiver>) receiver {
    [self->receivers addObject:receiver];
}

- (void) removeReceiver: (id<BRBeaconMessageStreamNodeReceiver>) receiver {
    [self->receivers removeObject:receiver];
}

// Public abstract
- (void) onMeshActive: (BRBeaconMessageStreamNode *) senderNode {
    // Default implementation is empty.
}

- (void) onReceivedMessage: (BRBeaconMessageStreamNode *) senderNode withMessage: (BRBeaconMessage*) message {
    mustOverride();
}

- (void) onMeshInactive: (BRBeaconMessageStreamNode *) senderNode {
    // Default implementation is empty.
}

@end
