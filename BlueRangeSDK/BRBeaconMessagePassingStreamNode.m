//
//  BRBeaconMessagePassingStreamNode.m
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

#import "BRBeaconMessagePassingStreamNode.h"
#import "BRBeaconMessageStreamNodeReceiver.h"

// Private methods
@interface BRBeaconMessagePassingStreamNode()
- (void) passMessageToReceivers: (BRBeaconMessage*) message;
@end

@implementation BRBeaconMessagePassingStreamNode

- (id) init {
    if (self = [super init]) {
        
    }
    return self;
}

- (id) initWithSender:(BRBeaconMessageStreamNode *)sender {
    if (self = [super initWithSender:sender]) {
        
    }
    return self;
}

- (id) initWithSenders:(NSArray *)senders {
    if (self = [super initWithSenders:senders]) {
        
    }
    return self;
}

// Override
- (void) onReceivedMessage: (BRBeaconMessageStreamNode *) senderNode withMessage: (BRBeaconMessage*) message {
    // 1. Preprocessing
    [self preprocessMessage:message];
    // 2. Delegating
    [self passMessageToReceivers:message];
    // 3. Postprocessing
    [self postprocessMessage:message];
}

- (void) passMessageToReceivers: (BRBeaconMessage*) message {
    for (id<BRBeaconMessageStreamNodeReceiver> receiver in self.receivers) {
        [receiver onReceivedMessage:self withMessage:message];
    }
}

// Protected
/**
 * This method is called right before a beacon message is passed to the receivers.
 * @param message The received message that is going to be passed to the receivers.
 */
- (void) preprocessMessage: (BRBeaconMessage*) message {
    // Default implementation is empty.
}

/**
 * This method is called right after a beacon message was passed to the receivers.
 * @param message The received message that was passed to the receivers.
 */
- (void) postprocessMessage: (BRBeaconMessage*) message {
    // Default implementation is empty.
}

@end
