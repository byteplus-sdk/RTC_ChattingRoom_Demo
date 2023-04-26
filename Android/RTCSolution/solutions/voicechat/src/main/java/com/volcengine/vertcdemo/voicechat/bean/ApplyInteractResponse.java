// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.volcengine.vertcdemo.voicechat.bean;

import com.google.gson.annotations.SerializedName;
/**
 * The data model returned by the audience application connection interface
 */
public class ApplyInteractResponse extends VoiceChatResponse {

    @SerializedName("is_need_apply")
    public boolean needApply = false;

    @Override
    public String toString() {
        return "ReplyMicOnEvent{" +
                "needApply=" + needApply +
                '}';
    }
}
