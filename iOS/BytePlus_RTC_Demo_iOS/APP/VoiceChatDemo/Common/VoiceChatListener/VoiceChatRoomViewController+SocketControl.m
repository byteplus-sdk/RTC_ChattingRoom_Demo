/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import "VoiceChatRoomViewController+SocketControl.h"

@implementation VoiceChatRoomViewController (SocketControl)

- (void)addSocketListener {
    __weak __typeof(self) wself = self;
    [VoiceChatRTMManager onAudienceJoinRoomWithBlock:^(VoiceChatUserModel * _Nonnull userModel, NSInteger count) {
        if (wself) {
            [wself receivedJoinUser:userModel count:count];
        }
    }];
    
    
    [VoiceChatRTMManager onAudienceLeaveRoomWithBlock:^(VoiceChatUserModel * _Nonnull userModel, NSInteger count) {
        if (wself) {
            [wself receivedLeaveUser:userModel count:count];
        }
    }];

    
    [VoiceChatRTMManager onFinishLiveWithBlock:^(NSString * _Nonnull rommID, NSInteger type) {
        if (wself) {
            [wself receivedFinishLive:type roomID:rommID];
        }
    }];

    
    [VoiceChatRTMManager onJoinInteractWithBlock:^(VoiceChatUserModel * _Nonnull userModel, NSString * _Nonnull seatID) {
        if (wself) {
            [wself receivedJoinInteractWithUser:userModel seatID:seatID];
        }
    }];

    
    [VoiceChatRTMManager onFinishInteractWithBlock:^(VoiceChatUserModel * _Nonnull userModel, NSString * _Nonnull seatID, NSInteger type) {
        if (wself) {
            [wself receivedLeaveInteractWithUser:userModel seatID:seatID type:type];
        }
    }];

    
    [VoiceChatRTMManager onSeatStatusChangeWithBlock:^(NSString * _Nonnull seatID, NSInteger type) {
        if (wself) {
            [wself receivedSeatStatusChange:seatID type:type];
        }
    }];

    
    [VoiceChatRTMManager onMediaStatusChangeWithBlock:^(VoiceChatUserModel * _Nonnull userModel, NSString * _Nonnull seatID, NSInteger mic) {
        if (wself) {
            [wself receivedMediaStatusChangeWithUser:userModel seatID:seatID mic:mic];
        }
    }];

    
    [VoiceChatRTMManager onMessageWithBlock:^(VoiceChatUserModel * _Nonnull userModel, NSString * _Nonnull message) {
        if (wself) {
            message = [message stringByRemovingPercentEncoding];
            [wself receivedMessageWithUser:userModel message:message];
        }
    }];

    //Single Notification Message
    
    [VoiceChatRTMManager onInviteInteractWithBlock:^(VoiceChatUserModel * _Nonnull hostUserModel, NSString * _Nonnull seatID) {
        if (wself) {
            [wself receivedInviteInteractWithUser:hostUserModel seatID:seatID];
        }
    }];
    
    [VoiceChatRTMManager onApplyInteractWithBlock:^(VoiceChatUserModel * _Nonnull userModel, NSString * _Nonnull seatID) {
        if (wself) {
            [wself receivedApplyInteractWithUser:userModel seatID:seatID];
        }
    }];

    [VoiceChatRTMManager onInviteResultWithBlock:^(VoiceChatUserModel * _Nonnull userModel, NSInteger reply) {
        if (wself) {
            [wself receivedInviteResultWithUser:userModel reply:reply];
        }
    }];
    
    [VoiceChatRTMManager onMediaOperateWithBlock:^(NSInteger mic) {
        if (wself) {
            [wself receivedMediaOperatWithUid:mic];
        }
    }];

    [VoiceChatRTMManager onClearUserWithBlock:^(NSString * _Nonnull uid) {
        if (wself) {
            [wself receivedClearUserWithUid:uid];
        }
    }];
}
@end
