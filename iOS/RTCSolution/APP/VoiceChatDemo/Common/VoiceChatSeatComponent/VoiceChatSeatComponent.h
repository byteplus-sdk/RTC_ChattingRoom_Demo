//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "VoiceChatSheetView.h"
#import <Foundation/Foundation.h>
@class VoiceChatSeatComponent;

NS_ASSUME_NONNULL_BEGIN

@protocol VoiceChatSeatDelegate <NSObject>

- (void)voiceChatSeatComponent:(VoiceChatSeatComponent *)voiceChatSeatComponent
                   clickButton:(VoiceChatSeatModel *)seatModel
                   sheetStatus:(VoiceChatSheetStatus)sheetStatus;

@end

@interface VoiceChatSeatComponent : NSObject

@property (nonatomic, weak) id<VoiceChatSeatDelegate> delegate;

- (instancetype)initWithSuperView:(UIView *)superView;

- (void)showSeatView:(NSArray<VoiceChatSeatModel *> *)seatList
      loginUserModel:(VoiceChatUserModel *)loginUserModel;

- (void)addSeatModel:(VoiceChatSeatModel *)seatModel;

- (void)removeUserModel:(VoiceChatUserModel *)userModel;

- (void)updateSeatModel:(VoiceChatSeatModel *)seatModel;

- (void)updateSeatVolume:(NSDictionary *)volumeDic;

@end

NS_ASSUME_NONNULL_END
