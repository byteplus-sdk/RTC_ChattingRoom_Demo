/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import "VoiceChatDemo.h"
#import "JoinRTSParams.h"
#import "VoiceChatRoomListsViewController.h"
#import <Core/NetworkReachabilityManager.h>
#import <Core/Localizator.h>

@implementation VoiceChatDemo

- (void)pushDemoViewControllerBlock:(void (^)(BOOL result))block {
    [[ToastComponent shareToastComponent] showLoading];
    [VoiceChatRTCManager shareRtc].networkDelegate = [NetworkReachabilityManager sharedManager];
    JoinRTSInputModel *inputModel = [[JoinRTSInputModel alloc] init];
    inputModel.scenesName = @"svc";
    inputModel.loginToken = [LocalUserComponent userModel].loginToken;
    __weak __typeof(self) wself = self;
    [JoinRTSParams getJoinRTSParams:inputModel
                             block:^(JoinRTSParamsModel * _Nonnull model) {
        [wself joinRTS:model block:block];
    }];
}

- (void)joinRTS:(JoinRTSParamsModel * _Nonnull)model
          block:(void (^)(BOOL result))block{
    if (!model) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"Connection failed")];
        if (block) {
            block(NO);
        }
        return;
    }
    // Connect RTS
    [[VoiceChatRTCManager shareRtc] connect:model.appId
                                   RTSToken:model.RTSToken
                                  serverUrl:model.serverUrl
                                  serverSig:model.serverSignature
                                        bid:model.bid
                                      block:^(BOOL result) {
        if (result) {
            [[ToastComponent shareToastComponent] dismiss];
            VoiceChatRoomListsViewController *next = [[VoiceChatRoomListsViewController alloc] init];
            UIViewController *topVC = [DeviceInforTool topViewController];
            [topVC.navigationController pushViewController:next animated:YES];
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"Connection failed")];
        }
        if (block) {
            block(result);
        }
    }];
}

@end
