/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import <UIKit/UIKit.h>
#import "VoiceChatRTMManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface VoiceChatHostAvatarView : UIView

@property (nonatomic, strong) VoiceChatUserModel *userModel;

- (void)updateHostVolume:(NSNumber *)volume;

- (void)updateHostMic:(UserMic)userMic;

@end

NS_ASSUME_NONNULL_END
