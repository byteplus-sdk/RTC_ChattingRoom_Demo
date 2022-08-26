/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import <UIKit/UIKit.h>
#import "VoiceChatSeatItemButton.h"
#import "VoiceChatRTMManager.h"
@class VoiceChatSheetView;

NS_ASSUME_NONNULL_BEGIN

@protocol VoiceChatSheetViewDelegate <NSObject>

- (void)voiceChatSheetView:(VoiceChatSheetView *)voiceChatSheetView
               clickButton:(VoiceChatSheetStatus)sheetState;

@end

@interface VoiceChatSheetView : UIView

@property (nonatomic, weak) id <VoiceChatSheetViewDelegate> delegate;

- (void)showWithSeatModel:(VoiceChatSeatModel *)seatModel
           loginUserModel:(VoiceChatUserModel *)loginUserModel;

- (void)dismiss;

@property (nonatomic, strong, readonly) VoiceChatSeatModel *seatModel;

@property (nonatomic, strong, readonly) VoiceChatUserModel *loginUserModel;

@end

NS_ASSUME_NONNULL_END
