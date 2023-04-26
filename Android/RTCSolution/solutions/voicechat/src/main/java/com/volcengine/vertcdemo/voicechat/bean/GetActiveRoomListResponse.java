// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.volcengine.vertcdemo.voicechat.bean;

import com.google.gson.annotations.SerializedName;

import java.util.List;
/**
 * Get the data model returned by the live room list interface
 */
public class GetActiveRoomListResponse extends VoiceChatResponse {

    @SerializedName("room_list")
    public List<VoiceChatRoomInfo> roomList;

    @Override
    public String toString() {
        return "GetActiveRoomListEvent{" +
                "roomList=" + roomList +
                '}';
    }
}
