/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import <Foundation/Foundation.h>
#import "VoiceChatRTMManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface VoiceChatIMModel : NSObject

@property (nonatomic, assign) BOOL isJoin;

@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) VoiceChatUserModel *userModel;

@end

NS_ASSUME_NONNULL_END
