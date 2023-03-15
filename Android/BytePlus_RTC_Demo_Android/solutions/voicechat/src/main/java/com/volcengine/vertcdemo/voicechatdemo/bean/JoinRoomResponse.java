/**
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

package com.volcengine.vertcdemo.voicechatdemo.bean;

import com.google.gson.annotations.SerializedName;
import com.volcengine.vertcdemo.core.net.rtm.RTSBizResponse;

import java.util.Map;

public class JoinRoomResponse implements RTSBizResponse {
    public boolean isFromCreate = true;
    @SerializedName("room_info")
    public VCRoomInfo roomInfo;
    @SerializedName("user_info")
    public VCUserInfo userInfo;
    @SerializedName("rtc_token")
    public String rtcToken;
    @SerializedName("host_info")
    public VCUserInfo hostInfo;
    @SerializedName("seat_list")
    public Map<Integer, VCSeatInfo> seatMap;
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
