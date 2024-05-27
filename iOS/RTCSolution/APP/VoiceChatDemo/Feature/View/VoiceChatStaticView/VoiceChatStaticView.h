//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "VoiceChatRTSManager.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoiceChatStaticView : UIView

@property (nonatomic, strong) VoiceChatRoomModel *roomModel;

- (void)updatePeopleNum:(NSInteger)count;

- (void)updateParamInfoModel:(VoiceChatRoomParamInfoModel *)paramInfoModel;

@end

NS_ASSUME_NONNULL_END
