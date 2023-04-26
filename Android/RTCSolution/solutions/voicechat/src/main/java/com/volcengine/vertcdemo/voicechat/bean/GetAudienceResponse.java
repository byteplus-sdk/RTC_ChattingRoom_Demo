// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.volcengine.vertcdemo.voicechat.bean;

import com.google.gson.annotations.SerializedName;

import java.util.List;
/**
 * Get the data model returned by the audience list interface
 */
public class GetAudienceResponse extends VoiceChatResponse {
    @SerializedName("audience_list")
    public List<VoiceChatUserInfo> audienceList;

    @Override
    public String toString() {
        return "GetAudienceEvent{" +
                "audienceList=" + audienceList +
                '}';
    }
}
