/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import <UIKit/UIKit.h>
#import "VoiceChatRTMManager.h"

@interface VoiceChatSeatItemView : UIView

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) VoiceChatSeatModel *seatModel;

@property (nonatomic, copy) void (^clickBlock)(VoiceChatSeatModel *seatModel);

@end
