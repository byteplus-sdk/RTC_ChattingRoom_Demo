// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.volcengine.vertcdemo.voicechat.bean;

import com.google.gson.annotations.SerializedName;
import com.volcengine.vertcdemo.core.net.rts.RTSBizInform;
/**
 * Audiences apply for mic event
 */
public class AudienceApplyEvent implements RTSBizInform {

    public boolean hasNewApply;
    @SerializedName("user_info")
    public VoiceChatUserInfo userInfo;
    @SerializedName("seat_id")
    public int seatId;

    @Override
    public String toString() {
        return "AudienceApplyEvent{" +
                "userInfo=" + userInfo +
                ", seatId=" + seatId +
                '}';
    }
}
