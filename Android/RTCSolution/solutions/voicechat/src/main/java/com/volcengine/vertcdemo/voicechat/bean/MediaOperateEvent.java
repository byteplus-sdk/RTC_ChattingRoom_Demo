// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.volcengine.vertcdemo.voicechat.bean;

import com.google.gson.annotations.SerializedName;
import com.volcengine.vertcdemo.core.net.rts.RTSBizInform;
/**
 * Media is switched by the anchor
 */
public class MediaOperateEvent implements RTSBizInform {

    @SerializedName("mic")
    @VoiceChatUserInfo.MicStatus
    public int mic;

    @Override
    public String toString() {
        return "MediaOperateEvent{" +
                "mic=" + mic +
                '}';
    }
}
