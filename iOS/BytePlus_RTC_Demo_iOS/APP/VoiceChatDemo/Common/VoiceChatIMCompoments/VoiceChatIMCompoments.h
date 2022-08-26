/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import <Foundation/Foundation.h>
#import "VoiceChatIMModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VoiceChatIMCompoments : NSObject

- (instancetype)initWithSuperView:(UIView *)superView;

- (void)addIM:(VoiceChatIMModel *)model;

@end

NS_ASSUME_NONNULL_END
