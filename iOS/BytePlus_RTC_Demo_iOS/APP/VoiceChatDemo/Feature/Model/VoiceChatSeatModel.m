/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import "VoiceChatSeatModel.h"

@implementation VoiceChatSeatModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"userModel" : @"guest_info"};
}

@end
