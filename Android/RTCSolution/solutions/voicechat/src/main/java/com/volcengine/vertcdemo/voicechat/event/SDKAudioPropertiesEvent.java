// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.volcengine.vertcdemo.voicechat.event;

import com.ss.bytertc.engine.data.AudioPropertiesInfo;

import java.util.List;
/**
 * The SDK calls back the user's volume change event
 */
public class SDKAudioPropertiesEvent {

    public List<SDKAudioProperties> audioPropertiesList;

    public SDKAudioPropertiesEvent(List<SDKAudioProperties> audioPropertiesList) {
        this.audioPropertiesList = audioPropertiesList;
    }

    public static class SDKAudioProperties {
        public String userId;

        public AudioPropertiesInfo audioPropertiesInfo;

        public SDKAudioProperties(String userId, AudioPropertiesInfo audioPropertiesInfo) {
            this.userId = userId;
            this.audioPropertiesInfo = audioPropertiesInfo;
        }
    }
}