/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import <Foundation/Foundation.h>
#import "VoiceChatSheetView.h"
@class VoiceChatSeatCompoments;

NS_ASSUME_NONNULL_BEGIN

@protocol VoiceChatSeatDelegate <NSObject>

- (void)voiceChatSeatCompoments:(VoiceChatSeatCompoments *)voiceChatSeatCompoments
                    clickButton:(VoiceChatSeatModel *)seatModel
                    sheetStatus:(VoiceChatSheetStatus)sheetStatus;

@end

@interface VoiceChatSeatCompoments : NSObject

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
