// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.volcengine.vertcdemo.voicechat.bean;

import com.google.gson.annotations.SerializedName;
import com.volcengine.vertcdemo.core.net.rts.RTSBizInform;
import com.volcengine.vertcdemo.voicechat.core.VoiceChatDataManager;
/**
 * Received connection invitation result event
 */
public class InteractResultEvent implements RTSBizInform {

    @SerializedName("reply")
    @VoiceChatDataManager.ReplyType
    public int reply;
    @SerializedName("user_info")
    public VoiceChatUserInfo userInfo;

    @Override
    public String toString() {
        return "InteractResultEvent{" +
                "reply=" + reply +
                ", userInfo=" + userInfo +
                '}';
    }
}
