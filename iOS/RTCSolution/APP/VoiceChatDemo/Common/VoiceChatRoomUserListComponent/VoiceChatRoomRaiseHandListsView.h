//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "VoiceChatRTSManager.h"
#import "VoiceChatRoomUserListtCell.h"
#import <UIKit/UIKit.h>
@class VoiceChatRoomRaiseHandListsView;

NS_ASSUME_NONNULL_BEGIN

static NSString *const KClearRedNotification = @"KClearRedNotification";

@protocol VoiceChatRoomRaiseHandListsViewDelegate <NSObject>

- (void)voiceChatRoomRaiseHandListsView:(VoiceChatRoomRaiseHandListsView *)voiceChatRoomRaiseHandListsView clickButton:(VoiceChatUserModel *)model;

@end

@interface VoiceChatRoomRaiseHandListsView : UIView

@property (nonatomic, copy) NSArray<VoiceChatUserModel *> *dataLists;

@property (nonatomic, weak) id<VoiceChatRoomRaiseHandListsViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
