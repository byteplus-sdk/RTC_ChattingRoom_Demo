//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "VoiceChatRoomParamInfoModel.h"

@implementation VoiceChatRoomParamInfoModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _rtt = @"0";
    }
    return self;
}

@end
