// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.volcengine.vertcdemo.voicechat.event;
/**
 * SDK audio statistics event
 */
public class SDKAudioStatsEvent {
    public int rtt;
    public float upload;
    public float download;

    public SDKAudioStatsEvent(int rtt, float upload, float download) {
        this.rtt = rtt;
        this.upload = upload;
        this.download = download;
    }
}
