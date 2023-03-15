/**
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

package com.volcengine.vertcdemo.voicechatdemo.core;

import static com.ss.bytertc.engine.data.AudioMixingType.AUDIO_MIXING_TYPE_PLAYOUT_AND_PUBLISH;

import android.content.Context;
import android.util.Log;

import com.ss.bytertc.engine.RTCRoom;
import com.ss.bytertc.engine.RTCRoomConfig;
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.UserInfo;
import com.ss.bytertc.engine.data.AudioMixingConfig;
import com.ss.bytertc.engine.data.AudioPropertiesConfig;
import com.ss.bytertc.engine.data.RemoteAudioPropertiesInfo;
import com.ss.bytertc.engine.data.StreamIndex;
import com.ss.bytertc.engine.type.ChannelProfile;
import com.ss.bytertc.engine.type.LocalStreamStats;
import com.ss.bytertc.engine.type.MediaStreamType;
import com.ss.bytertc.engine.type.RemoteStreamStats;
import com.ss.video.rtc.demo.basic_module.utils.AppExecutors;
import com.ss.video.rtc.demo.basic_module.utils.Utilities;
import com.volcengine.vertcdemo.core.eventbus.AudioVolumeEvent;
import com.volcengine.vertcdemo.core.eventbus.SolutionDemoEventManager;
import com.volcengine.vertcdemo.core.net.rtm.RTCEventHandlerWithRTS;
import com.volcengine.vertcdemo.core.net.rtm.RTCRoomEventHandlerWithRTS;
import com.volcengine.vertcdemo.core.net.rtm.RTSInfo;
import com.volcengine.vertcdemo.voicechatdemo.core.event.AudioStatsEvent;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class VoiceChatRTCManager {

    private static final String TAG = "VoiceChatRTCManager";

    private static VoiceChatRTCManager sInstance;

    private VoiceChatRTSClient mRTMClient;

    private final RTCEventHandlerWithRTS mRTCVideoEventHandler = new RTCEventHandlerWithRTS() {

        @Override
        public void onWarning(int warn) {
            super.onWarning(warn);
            Log.d(TAG, String.format("onWarning: %d", warn));
        }

        @Override
        public void onError(int err) {
            super.onError(err);
            Log.d(TAG, String.format("onError: %d", err));
        }

        @Override
        public void onRemoteAudioPropertiesReport(RemoteAudioPropertiesInfo[] audioPropertiesInfos, int totalRemoteVolume) {
            AudioVolumeEvent.Info[] infos = new AudioVolumeEvent.Info[audioPropertiesInfos.length];
            for (int i = 0; i < audioPropertiesInfos.length; i++) {
                final RemoteAudioPropertiesInfo property = audioPropertiesInfos[i];
                infos[i] = new AudioVolumeEvent.Info(
                        property.streamKey.getUserId(),
                        property.audioPropertiesInfo.linearVolume
                );
            }
            SolutionDemoEventManager.post(new AudioVolumeEvent(infos));
        }
    };

    private final RTCRoomEventHandlerWithRTS mRTCRoomEventHandler = new RTCRoomEventHandlerWithRTS() {

        private int rtt;
        private float sendLossRate;
        private float receivedLossRate;

        @Override
        public void onRoomStateChanged(String roomId, String uid, int state, String extraInfo) {
            super.onRoomStateChanged(roomId, uid, state, extraInfo);
            Log.d(TAG, String.format("onRoomStateChanged: %s, %s, %d, %s", roomId, uid, state, extraInfo));
        }

        @Override
        public void onLocalStreamStats(LocalStreamStats stats) {
            super.onLocalStreamStats(stats);
            rtt = stats.audioStats.rtt;
            sendLossRate = stats.audioStats.audioLossRate;
            updateUI();
        }

        @Override
        public void onRemoteStreamStats(RemoteStreamStats stats){
            super.onRemoteStreamStats(stats);
            if (stats.audioStats.audioLossRate > 0){
                receivedLossRate = stats.audioStats.audioLossRate;
                updateUI();
            }
        }


        private void updateUI(){
            AudioStatsEvent event = new AudioStatsEvent(rtt, sendLossRate, receivedLossRate);
            SolutionDemoEventManager.post(event);
        }
    };

    private RTCVideo mRTCVideo;
    private RTCRoom mRTCRoom;

    public static VoiceChatRTCManager ins() {
        if (sInstance == null) {
            sInstance = new VoiceChatRTCManager();
        }
        return sInstance;
    }

    public VoiceChatRTSClient getRTMClient() {
        return mRTMClient;
    }

    public void initEngine(RTSInfo info) {
        destroyEngine();
        mRTCVideo = RTCVideo.createRTCVideo(Utilities.getApplicationContext(), info.appId, mRTCVideoEventHandler, null, null);
        mRTCVideo.enableAudioPropertiesReport(new AudioPropertiesConfig(2000));
        mRTCVideo.stopVideoCapture();
        mRTMClient = new VoiceChatRTSClient(mRTCVideo, info);
        mRTCVideoEventHandler.setBaseClient(mRTMClient);
        mRTCRoomEventHandler.setBaseClient(mRTMClient);
        initBGMRes();
        Log.d(TAG, String.format("initEngine: %s", info));
    }

    private void initBGMRes() {
        AppExecutors.diskIO().execute(() -> {
            File bgmPath = new File(getExternalResourcePath(), "bgm/voicechat_bgm.mp3");
            if (!bgmPath.exists()) {
                File dir = new File(getExternalResourcePath() + "bgm");
                if (!dir.exists()) {
                    //noinspection ResultOfMethodCallIgnored
                    dir.mkdirs();
                }
                copyAssetFile(Utilities.getApplicationContext(), "voicechat_bgm.mp3", bgmPath.getAbsolutePath());
            }
        });
    }

    private String getExternalResourcePath() {
        return Utilities.getApplicationContext().getExternalFilesDir("assets").getAbsolutePath() + "/resource/";
    }

    public void destroyEngine() {
        Log.d(TAG, "destroyEngine");
        RTCVideo.destroyRTCVideo();
    }

    public void joinRoom(String roomId, String token, String userId) {
        Log.d(TAG, String.format("joinRoom: %s %s %s", roomId, userId, token));
        if (mRTCVideo != null) {
            RTCRoomConfig config = new RTCRoomConfig(
                    ChannelProfile.CHANNEL_PROFILE_COMMUNICATION,
                    true, true, true);
            mRTCRoom = mRTCVideo.createRTCRoom(roomId);
            mRTCRoom.setRTCRoomEventHandler(mRTCRoomEventHandler);
            mRTCRoom.joinRoom(token, new UserInfo(userId, null), config);
        }
    }

    public void leaveRoom() {
        Log.d(TAG, "leaveRoom");
        if (mRTCRoom != null) {
            mRTCRoom.leaveRoom();
            mRTCRoom.destroy();
        }
    }

    public void stopAudioCapture() {
        Log.d(TAG, "stopAudioCapture");
        if (mRTCVideo != null) {
            mRTCVideo.stopAudioCapture();
        }
    }

    public void startAudioCapture(boolean isStart) {
        Log.d(TAG, String.format("startAudioCapture: %b", isStart));
        if (mRTCVideo != null) {
            if (isStart) {
                mRTCVideo.startAudioCapture();
            } else {
                mRTCVideo.stopAudioCapture();
            }
        }
    }

    public void startMuteAudio(boolean mute) {
        Log.d(TAG, String.format("startMuteAudio: %b", mute));
        if (mRTCRoom != null) {
            if (mute) {
                mRTCRoom.unpublishStream(MediaStreamType.RTC_MEDIA_STREAM_TYPE_AUDIO);
            } else {
                mRTCRoom.publishStream(MediaStreamType.RTC_MEDIA_STREAM_TYPE_AUDIO);
            }
        }
    }

    public void startAudioMixing(boolean isStart) {
        Log.d(TAG, String.format("startAudioMixing: %b", isStart));
        if (mRTCVideo != null) {
            if (isStart) {
                String bgmPath = getExternalResourcePath() + "bgm/voicechat_bgm.mp3";
                mRTCVideo.getAudioMixingManager().preloadAudioMixing(0, bgmPath);
                AudioMixingConfig config = new AudioMixingConfig(AUDIO_MIXING_TYPE_PLAYOUT_AND_PUBLISH, -1);
                mRTCVideo.getAudioMixingManager().startAudioMixing(0, bgmPath, config);
            } else {
                mRTCVideo.getAudioMixingManager().stopAudioMixing(0);
            }
        }
    }

    public void resumeAudioMixing() {
        Log.d(TAG, "resumeAudioMixing");
        if (mRTCVideo != null) {
            mRTCVideo.getAudioMixingManager().resumeAudioMixing(0);
        }
    }

    public void pauseAudioMixing() {
        Log.d(TAG, "pauseAudioMixing");
        if (mRTCVideo != null) {
            mRTCVideo.getAudioMixingManager().pauseAudioMixing(0);
        }
    }

    public void adjustBGMVolume(int progress) {
        Log.d(TAG, String.format("adjustBGMVolume: %d", progress));
        if (mRTCVideo != null) {
            mRTCVideo.getAudioMixingManager().setAudioMixingVolume(0, progress, AUDIO_MIXING_TYPE_PLAYOUT_AND_PUBLISH);
        }
    }

    public void adjustUserVolume(int progress) {
        Log.d(TAG, String.format("adjustUserVolume: %d", progress));
        if (mRTCVideo != null) {
            mRTCVideo.setCaptureVolume(StreamIndex.STREAM_INDEX_MAIN, progress);
        }
    }


    public static boolean copyAssetFile(Context context, String srcName, String dstName) {
        try {
            InputStream in = context.getAssets().open(srcName);
            File outFile = new File(dstName);
            OutputStream out = new FileOutputStream(outFile);
            byte[] buffer = new byte[1024];
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
            in.close();
            out.close();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }
}
