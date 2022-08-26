/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import <Foundation/Foundation.h>
#import "VoiceChatRTMManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface VoiceChatTextInputCompoments : NSObject

@property (nonatomic, copy) void (^clickSenderBlock)(NSString *text);

- (void)showWithRoomModel:(VoiceChatRoomModel *)roomModel;

@end

NS_ASSUME_NONNULL_END
