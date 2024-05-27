//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "VoiceChatRTSManager.h"
#import "VoiceChatRoomUserListtCell.h"
#import <UIKit/UIKit.h>
@class VoiceChatRoomAudienceListsView;

NS_ASSUME_NONNULL_BEGIN

@protocol VoiceChatRoomAudienceListsViewDelegate <NSObject>

- (void)voiceChatRoomAudienceListsView:(VoiceChatRoomAudienceListsView *)voiceChatRoomAudienceListsView clickButton:(VoiceChatUserModel *)model;

@end

@interface VoiceChatRoomAudienceListsView : UIView

@property (nonatomic, copy) NSArray<VoiceChatUserModel *> *dataLists;

@property (nonatomic, weak) id<VoiceChatRoomAudienceListsViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
