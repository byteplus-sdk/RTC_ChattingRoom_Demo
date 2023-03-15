/**
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

package com.volcengine.vertcdemo.voicechatdemo.bean;

import com.google.gson.annotations.SerializedName;
import com.volcengine.vertcdemo.core.net.rtm.RTSBizInform;
import com.volcengine.vertcdemo.voicechatdemo.core.VoiceChatDataManager;

public class InteractResultBroadcast implements RTSBizInform {

    @SerializedName("reply")
    @VoiceChatDataManager.ReplyType
    public int reply;
    @SerializedName("user_info")
    public VCUserInfo userInfo;

    @Override
    public String toString() {
        return "InteractResultBroadcast{" +
                "reply=" + reply +
                ", userInfo=" + userInfo +
                '}';
    }
}
