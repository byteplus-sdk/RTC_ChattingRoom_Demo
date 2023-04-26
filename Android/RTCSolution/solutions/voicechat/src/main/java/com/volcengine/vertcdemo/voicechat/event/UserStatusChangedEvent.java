// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.volcengine.vertcdemo.voicechat.event;

import com.volcengine.vertcdemo.voicechat.bean.VoiceChatUserInfo;
/**
 * User status change event
 */
public class UserStatusChangedEvent {

    public VoiceChatUserInfo userInfo;
    @VoiceChatUserInfo.UserStatus
    public int status;

    public UserStatusChangedEvent(VoiceChatUserInfo userInfo, @VoiceChatUserInfo.UserStatus int status) {
        this.userInfo = userInfo;
        this.status = status;
    }
}
