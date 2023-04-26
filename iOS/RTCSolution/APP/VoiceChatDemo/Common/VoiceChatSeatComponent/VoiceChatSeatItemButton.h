// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
// 

#import "BaseButton.h"

typedef NS_ENUM(NSInteger, VoiceChatSheetStatus) {
    VoiceChatSheetStatusInvite = 0,
    VoiceChatSheetStatusKick,
    VoiceChatSheetStatusOpenMic,
    VoiceChatSheetStatusCloseMic,
    VoiceChatSheetStatusLock,
    VoiceChatSheetStatusUnlock,
    // Audience apply for mic
    VoiceChatSheetStatusApply,
    // The guests took the initiative to take the mic
    VoiceChatSheetStatusLeave,
};

NS_ASSUME_NONNULL_BEGIN

@interface VoiceChatSeatItemButton : BaseButton

@property (nonatomic, copy) NSString *desTitle;

@property (nonatomic, assign) VoiceChatSheetStatus sheetState;

@end

NS_ASSUME_NONNULL_END
