/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import "VoiceChatControlAckModel.h"

@implementation VoiceChatControlAckModel

- (BOOL)result {
    if (self.code == 200) {
        return YES;
    } else {
        return NO;
    }
}

@end
