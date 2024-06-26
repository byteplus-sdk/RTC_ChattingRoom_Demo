//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "VoiceChatRTSManager.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoiceChatHostAvatarView : UIView

@property (nonatomic, strong) VoiceChatUserModel *userModel;

- (void)updateHostVolume:(NSNumber *)volume;

- (void)updateHostMic:(UserMic)userMic;

@end

NS_ASSUME_NONNULL_END
