// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.volcengine.vertcdemo.voicechat.bean;

import com.google.gson.annotations.SerializedName;
/**
 * Reply to the data model returned by the connection interface
 */
public class InteractReplyResponse extends VoiceChatResponse {

    @SerializedName("user_info")
    public VoiceChatUserInfo userInfo;

    @Override
    public String toString() {
        return "InteractReplyEvent{" +
                "userInfo=" + userInfo +
                '}';
    }
}
