//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "VoiceChatSeatModel.h"

@implementation VoiceChatSeatModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"userModel": @"guest_info"};
}

@end
