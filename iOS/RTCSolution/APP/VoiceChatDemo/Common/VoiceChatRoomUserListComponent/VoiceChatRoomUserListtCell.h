//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "VoiceChatRTSManager.h"
#import <UIKit/UIKit.h>
@class VoiceChatRoomUserListtCell;

NS_ASSUME_NONNULL_BEGIN

@protocol VoiceChatRoomUserListtCellDelegate <NSObject>

- (void)VoiceChatRoomUserListtCell:(VoiceChatRoomUserListtCell *)VoiceChatRoomUserListtCell clickButton:(id)model;

@end

@interface VoiceChatRoomUserListtCell : UITableViewCell

@property (nonatomic, strong) VoiceChatUserModel *model;

@property (nonatomic, weak) id<VoiceChatRoomUserListtCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
