//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "VoiceChatRTSManager.h"
#import <UIKit/UIKit.h>

@interface VoiceChatSeatItemView : UIView

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) VoiceChatSeatModel *seatModel;

@property (nonatomic, copy) void (^clickBlock)(VoiceChatSeatModel *seatModel);

@end
