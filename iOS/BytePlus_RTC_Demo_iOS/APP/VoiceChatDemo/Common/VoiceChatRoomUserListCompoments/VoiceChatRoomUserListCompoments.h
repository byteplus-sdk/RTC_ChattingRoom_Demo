/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import <Foundation/Foundation.h>
#import "VoiceChatRoomAudienceListsView.h"
#import "VoiceChatRoomRaiseHandListsView.h"

NS_ASSUME_NONNULL_BEGIN

@interface VoiceChatRoomUserListCompoments : NSObject

- (void)showRoomModel:(VoiceChatRoomModel *)roomModel
               seatID:(NSString *)seatID
         dismissBlock:(void (^)(void))dismissBlock;

- (void)update;

- (void)updateWithRed:(BOOL)isRed;

@end

NS_ASSUME_NONNULL_END
