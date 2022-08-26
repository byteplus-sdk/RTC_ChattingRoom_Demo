/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import "VoiceChatRoomParamInfoModel.h"

@implementation VoiceChatRoomParamInfoModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _rtt = @"0";
        _sendLossRate = @"0";
        _receivedLossRate = @"0";
    }
    return self;
}

@end
