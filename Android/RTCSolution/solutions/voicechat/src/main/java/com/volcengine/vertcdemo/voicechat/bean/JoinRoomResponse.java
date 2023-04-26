// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.volcengine.vertcdemo.voicechat.bean;

import com.google.gson.annotations.SerializedName;

import java.util.Map;
/**
 * Join the data model returned by the room interface
 */
public class JoinRoomResponse extends VoiceChatResponse {
    public boolean isFromCreate = true;
    @SerializedName("room_info")
    public VoiceChatRoomInfo roomInfo;
    @SerializedName("user_info")
    public VoiceChatUserInfo userInfo;
    @SerializedName("rtc_token")
    public String rtcToken;
    @SerializedName("host_info")
    public VoiceChatUserInfo hostInfo;
    @SerializedName("seat_list")
    public Map<Integer, VoiceChatSeatInfo> seatMap;
    @SerializedName("audience_count")
    public int audienceCount;

    @Override
    public String toString() {
        return "JoinRoomResponse{" +
                "roomInfo=" + roomInfo +
                ", userInfo=" + userInfo +
                ", rtcToken='" + rtcToken + '\'' +
                ", hostInfo=" + hostInfo +
                ", seatMap=" + seatMap +
                ", audienceCount=" + audienceCount +
                '}';
    }
}
