//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "VoiceChatRoomCell.h"
#import <UIKit/UIKit.h>
@class VoiceChatRoomTableView;

NS_ASSUME_NONNULL_BEGIN

@protocol VoiceChatRoomTableViewDelegate <NSObject>

- (void)VoiceChatRoomTableView:(VoiceChatRoomTableView *)VoiceChatRoomTableView didSelectRowAtIndexPath:(VoiceChatRoomModel *)model;

@end

@interface VoiceChatRoomTableView : UIView

@property (nonatomic, copy) NSArray *dataLists;

@property (nonatomic, weak) id<VoiceChatRoomTableViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
