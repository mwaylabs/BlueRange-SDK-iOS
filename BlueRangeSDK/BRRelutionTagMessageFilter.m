//
//  BRRelutionTagMessageFilter.m
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

#import "BRRelutionTagMessageFilter.h"
#import "BRBeaconMessage.h"
#import "BRRelutionTagMessage.h"

@implementation BRRelutionTagMessageFilter

- (id) initWithSender: (BRBeaconMessageStreamNode*) senderNode {
    if (self = [super initWithSender:senderNode]) {
        
    }
    return self;
}

- (id) initWithSenders: (NSArray*) senders {
    if (self = [super initWithSenders:senders]) {
        
    }
    return self;
}

- /* Override */ (void) onReceivedMessage: (BRBeaconMessageStreamNode *) senderNode withMessage: (BRBeaconMessage*) message {
    if ([message isKindOfClass:[BRRelutionTagMessage class]]) {
        for (id<BRBeaconMessageStreamNodeReceiver> receiver in self.receivers) {
            [receiver onReceivedMessage:self withMessage:message];
        }
    }
}

@end
