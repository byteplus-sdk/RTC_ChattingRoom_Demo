//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "VoiceChatRTSManager.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoiceChatSeatView : UIView

@property (nonatomic, copy) void (^clickBlock)(VoiceChatSeatModel *seatModel);

@property (nonatomic, copy) NSArray<VoiceChatSeatModel *> *seatList;

- (void)addSeatModel:(VoiceChatSeatModel *)seatModel;

- (void)removeUserModel:(VoiceChatUserModel *)userModel;

- (void)updateSeatModel:(VoiceChatSeatModel *)seatModel;

- (void)updateSeatVolume:(NSDictionary *)volumeDic;

@end

NS_ASSUME_NONNULL_END
