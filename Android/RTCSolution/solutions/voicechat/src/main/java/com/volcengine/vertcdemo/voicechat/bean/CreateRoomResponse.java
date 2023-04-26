// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.volcengine.vertcdemo.voicechat.bean;

import com.google.gson.annotations.SerializedName;
/**
 *The data model returned by the create room interface
 */
public class CreateRoomResponse extends VoiceChatResponse {

    @SerializedName("room_info")
    public VoiceChatRoomInfo roomInfo;
    @SerializedName("user_info")
    public VoiceChatUserInfo userInfo;
    @SerializedName("rtc_token")
    public String rtcToken;

    @Override
    public String toString() {
        return "CreateRoomEvent{" +
                "roomInfo=" + roomInfo +
                ", userInfo=" + userInfo +
                ", rtcToken='" + rtcToken + '\'' +
                '}';
    }
}
