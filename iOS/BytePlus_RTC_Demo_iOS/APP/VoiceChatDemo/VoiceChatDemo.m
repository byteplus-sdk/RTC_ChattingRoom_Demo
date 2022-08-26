/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import "VoiceChatDemo.h"
#import "VoiceChatRoomListsViewController.h"
#import <Core/NetworkReachabilityManager.h>
#import <Core/Localizator.h>

@implementation VoiceChatDemo

- (void)pushDemoViewControllerBlock:(void (^)(BOOL result))block {
    [[ToastComponents shareToastComponents] showLoading];
    [VoiceChatRTCManager shareRtc].networkDelegate = [NetworkReachabilityManager sharedManager];
    [[VoiceChatRTCManager shareRtc] connect:@"svc"
                                 loginToken:[LocalUserComponents userModel].loginToken
                                      block:^(BOOL result) {
        if (result) {
            [[ToastComponents shareToastComponents] dismiss];
            VoiceChatRoomListsViewController *next = [[VoiceChatRoomListsViewController alloc] init];
            UIViewController *topVC = [DeviceInforTool topViewController];
            [topVC.navigationController pushViewController:next animated:YES];
        } else {
            [[ToastComponents shareToastComponents] showWithMessage:LocalizedString(@"Connection failed")];
        }
        if (block) {
            block(result);
        }
    }];
}

@end
