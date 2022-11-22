/**
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

package com.volcengine.vertcdemo.voicechatdemo.feature.roommain;

import static com.volcengine.vertcdemo.voicechatdemo.bean.FinishLiveBroadcast.FINISH_TYPE_NORMAL;
import static com.volcengine.vertcdemo.voicechatdemo.bean.InteractChangedBroadcast.FINISH_INTERACT_TYPE_HOST;
import static com.volcengine.vertcdemo.voicechatdemo.bean.VCUserInfo.MIC_STATUS_ON;
import static com.volcengine.vertcdemo.voicechatdemo.bean.VCUserInfo.USER_STATUS_INTERACT;
import static com.volcengine.vertcdemo.voicechatdemo.bean.VCUserInfo.USER_STATUS_NORMAL;
import static com.volcengine.vertcdemo.voicechatdemo.feature.roommain.AudienceManagerDialog.SEAT_ID_BY_SERVER;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.gson.reflect.TypeToken;
import com.ss.bytertc.engine.handler.IRTCEngineEventHandler;
import com.ss.bytertc.engine.type.AudioVolumeInfo;
import com.ss.video.rtc.demo.basic_module.acivities.BaseActivity;
import com.ss.video.rtc.demo.basic_module.utils.GsonUtils;
import com.ss.video.rtc.demo.basic_module.utils.IMEUtils;
import com.ss.video.rtc.demo.basic_module.utils.Utilities;
import com.volcengine.vertcdemo.common.IAction;
import com.volcengine.vertcdemo.common.SolutionToast;
import com.volcengine.vertcdemo.core.SolutionDataManager;
import com.volcengine.vertcdemo.core.eventbus.SocketConnectEvent;
import com.volcengine.vertcdemo.core.eventbus.SolutionDemoEventManager;
import com.volcengine.vertcdemo.core.net.IRequestCallback;
import com.volcengine.vertcdemo.core.net.rtm.RTMBizResponse;
import com.volcengine.vertcdemo.voicechat.R;
import com.volcengine.vertcdemo.voicechatdemo.bean.AudienceApplyBroadcast;
import com.volcengine.vertcdemo.voicechatdemo.bean.AudienceChangedBroadcast;
import com.volcengine.vertcdemo.voicechatdemo.bean.ClearUserBroadcast;
import com.volcengine.vertcdemo.voicechatdemo.bean.FinishLiveBroadcast;
import com.volcengine.vertcdemo.voicechatdemo.bean.InteractChangedBroadcast;
import com.volcengine.vertcdemo.voicechatdemo.bean.InteractResultBroadcast;
import com.volcengine.vertcdemo.voicechatdemo.bean.JoinRoomResponse;
import com.volcengine.vertcdemo.voicechatdemo.bean.MediaChangedBroadcast;
import com.volcengine.vertcdemo.voicechatdemo.bean.MediaOperateBroadcast;
import com.volcengine.vertcdemo.voicechatdemo.bean.MessageBroadcast;
import com.volcengine.vertcdemo.voicechatdemo.bean.ReceivedInteractBroadcast;
import com.volcengine.vertcdemo.voicechatdemo.bean.ReplyResponse;
import com.volcengine.vertcdemo.voicechatdemo.bean.SeatChangedBroadcast;
import com.volcengine.vertcdemo.voicechatdemo.bean.VCRoomInfo;
import com.volcengine.vertcdemo.voicechatdemo.bean.VCSeatInfo;
import com.volcengine.vertcdemo.voicechatdemo.bean.VCUserInfo;
import com.volcengine.vertcdemo.voicechatdemo.core.VoiceChatDataManager;
import com.volcengine.vertcdemo.voicechatdemo.core.VoiceChatRTCManager;
import com.volcengine.vertcdemo.voicechatdemo.core.event.AudioStatsEvent;
import com.volcengine.vertcdemo.voicechatdemo.core.event.AudioVolumeEvent;
import com.volcengine.vertcdemo.voicechatdemo.feature.CommonDialog;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.Locale;
import java.util.Map;

@SuppressWarnings("unused")
public class VoiceChatRoomMainActivity extends BaseActivity {

    private static final String TAG = "VoiceChatRoomMain";

    private static final String REFER_KEY = "refer";
    private static final String REFER_FROM_CREATE = "create";
    private static final String REFER_FROM_LIST = "list";
    private static final String REFER_EXTRA_ROOM = "extra_room";
    private static final String REFER_EXTRA_USER = "extra_user";
    private static final String REFER_EXTRA_CREATE_JSON = "extra_create_json";

    private View mTopTip;
    private ImageView mBackgroundIv;
    private TextView mRoomTitleTv;
    private TextView mRoomStatsTv;
    private TextView mAudienceCountTv;
    private SeatsGroupLayout mSeatsGroupLayout;
    private BottomOptionLayout mBottomOptionLayout;
    private RecyclerView mVCChatRv;
    private FrameLayout mInputLayout;
    private EditText mInputEt;

    private VCChatAdapter mVCChatAdapter;

    private VCRoomInfo mRoomInfo;
    private VCUserInfo mHostUserInfo;
    private VCUserInfo mSelfUserInfo;

    private boolean isMicOn = true;
    private boolean isLeaveByKickOut = false;

    private final IRequestCallback<JoinRoomResponse> mJoinCallback = new IRequestCallback<JoinRoomResponse>() {
        @Override
        public void onSuccess(JoinRoomResponse data) {
            data.isFromCreate = true;
            initViewWithData(data);
        }

        @Override
        public void onError(int errorCode, String message) {
            if (errorCode == 422) {
                message = VoiceChatRoomMainActivity.this.getString(R.string.room_close_txt);
            }
            onArgsError(message);
        }
    };

    private final IRequestCallback<RTMBizResponse> mSendMessageCallback = new IRequestCallback<RTMBizResponse>() {
        @Override
        public void onSuccess(RTMBizResponse data) {

        }

        @Override
        public void onError(int errorCode, String message) {

        }
    };

    private final IRequestCallback<RTMBizResponse> mFinishCallback = new IRequestCallback<RTMBizResponse>() {
        @Override
        public void onSuccess(RTMBizResponse data) {

        }

        @Override
        public void onError(int errorCode, String message) {

        }
    };

    private final IRequestCallback<RTMBizResponse> mLeaveCallback = new IRequestCallback<RTMBizResponse>() {
        @Override
        public void onSuccess(RTMBizResponse data) {

        }

        @Override
        public void onError(int errorCode, String message) {

        }
    };

    private final IRequestCallback<JoinRoomResponse> mReconnectCallback = new IRequestCallback<JoinRoomResponse>() {
        @Override
        public void onSuccess(JoinRoomResponse data) {
            data.isFromCreate = false;
            initViewWithData(data);
        }

        @Override
        public void onError(int errorCode, String message) {
            finish();
        }
    };

    private final BottomOptionLayout.IBottomOptions mIBottomOptions = new BottomOptionLayout.IBottomOptions() {
        @Override
        public void onInputClick() {
            openInput();
        }

        @Override
        public void onInteractClick() {
            AudienceManagerDialog dialog = new AudienceManagerDialog(VoiceChatRoomMainActivity.this);
            dialog.setData(mRoomInfo.roomId, VoiceChatDataManager.ins().getAllowUserApply(),
                    VoiceChatDataManager.ins().hasNewApply(), SEAT_ID_BY_SERVER);
            dialog.show();
        }

        @Override
        public void onBGMClick() {
            BGMSettingDialog dialog = new BGMSettingDialog(VoiceChatRoomMainActivity.this);
            dialog.setData(VoiceChatDataManager.ins().getBGMOpening(),
                    VoiceChatDataManager.ins().getBGMVolume(),
                    VoiceChatDataManager.ins().getUserVolume());
            dialog.show();
        }

        @Override
        public void onMicClick() {
            switchMicStatus();
        }

        @Override
        public void onCloseClick() {
            attemptLeave();
        }
    };

    private final IAction<VCSeatInfo> mOnSeatClick = seatInfo -> {
        if (mInputLayout.getVisibility() == View.VISIBLE) {
            closeInput();
        } else {
            if (seatInfo != null && (mSelfUserInfo != null && !mSelfUserInfo.isHost()) && seatInfo.isLocked()) {
                return;
            }
            VCUserInfo userInfo = seatInfo == null ? null : seatInfo.userInfo;
            String userId = userInfo == null ? null : userInfo.userId;
            String selfUserId = SolutionDataManager.ins().getUserId();
            boolean isSelf = TextUtils.equals(selfUserId, userId);
            boolean isSelfHost = TextUtils.equals(selfUserId, mHostUserInfo.userId);
            if (!isSelfHost && !isSelf) {
                if (userInfo != null) {
                    return;
                }
                if (mSelfUserInfo.userStatus == USER_STATUS_INTERACT) {
                    SolutionToast.show(R.string.already_co_host_msg);
                } else if (mSelfUserInfo.userStatus == USER_STATUS_NORMAL) {
                    if (VoiceChatDataManager.ins().getSelfApply()) {
                        SolutionToast.show(R.string.already_send_application_msg);
                        return;
                    }
                }
            }
            SeatOptionDialog dialog = new SeatOptionDialog(VoiceChatRoomMainActivity.this);
            dialog.setData(mRoomInfo.roomId, seatInfo, mSelfUserInfo.userRole, mSelfUserInfo.userStatus);
            dialog.show();
        }
    };

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_class_voice_chat_demo_main);
    }

    @Override
    protected void onGlobalLayoutCompleted() {
        super.onGlobalLayoutCompleted();

        mTopTip = findViewById(R.id.main_disconnect_tip);
        mBackgroundIv = findViewById(R.id.voice_chat_demo_main_bg);
        mBackgroundIv.setOnClickListener((v) -> closeInput());
        mRoomTitleTv = findViewById(R.id.voice_chat_demo_main_title);
        mRoomStatsTv = findViewById(R.id.voice_chat_demo_main_stats);
        mAudienceCountTv = findViewById(R.id.voice_chat_demo_main_audience_num);
        Drawable drawable = getResources().getDrawable(R.drawable.ic_audience);
        drawable.setBounds(0, 0,
                (int) Utilities.dip2Px(22), (int) Utilities.dip2Px(20));
        mAudienceCountTv.setCompoundDrawables(drawable, null, null, null);

        mSeatsGroupLayout = findViewById(R.id.voice_chat_demo_main_seat_group);
        mSeatsGroupLayout.setSeatClick(mOnSeatClick);

        mBottomOptionLayout = findViewById(R.id.voice_chat_demo_main_bottom_option);
        mBottomOptionLayout.setOptionCallback(mIBottomOptions);

        mVCChatAdapter = new VCChatAdapter();
        mVCChatRv = findViewById(R.id.voice_chat_demo_main_chat_rv);
        mVCChatRv.setLayoutManager(new LinearLayoutManager(
                VoiceChatRoomMainActivity.this, RecyclerView.VERTICAL, false));
        mVCChatRv.setAdapter(mVCChatAdapter);
        mVCChatRv.setOnClickListener((v) -> closeInput());

        mInputLayout = findViewById(R.id.voice_chat_demo_main_input_layout);
        mInputEt = findViewById(R.id.voice_chat_demo_main_input_et);
        TextView inputSend = findViewById(R.id.voice_chat_demo_main_input_send);
        inputSend.setBackground(getSendBtnBackground());
        inputSend.setOnClickListener((v) -> onSendMessage(mInputEt.getText().toString()));

        closeInput();

        if (!checkArgs()) {
            finish();
            return;
        }

        SolutionDemoEventManager.register(this);
    }

    private boolean checkArgs() {
        Intent intent = getIntent();
        if (intent == null) {
            return false;
        }
        String refer = intent.getStringExtra(REFER_KEY);
        String roomJson = intent.getStringExtra(REFER_EXTRA_ROOM);
        String selfJson = intent.getStringExtra(REFER_EXTRA_USER);
        VCRoomInfo roomInfo = GsonUtils.gson().fromJson(roomJson, VCRoomInfo.class);
        VCUserInfo selfInfo = GsonUtils.gson().fromJson(selfJson, VCUserInfo.class);
        if (TextUtils.equals(refer, REFER_FROM_LIST)) {
            VoiceChatRTCManager.ins().getRTMClient().requestJoinRoom(selfInfo.userName, roomInfo.roomId, mJoinCallback);
            return true;
        } else if (TextUtils.equals(refer, REFER_FROM_CREATE)) {
            String createJson = intent.getStringExtra(REFER_EXTRA_CREATE_JSON);
            if (TextUtils.isEmpty(createJson)) {
                return false;
            }
            JoinRoomResponse createResponse = GsonUtils.gson().fromJson(createJson, JoinRoomResponse.class);
            initViewWithData(createResponse);
            return true;
        } else {
            return false;
        }
    }

    private void initViewWithData(JoinRoomResponse data) {
        mRoomTitleTv.setText(data.roomInfo.roomName);
        mAudienceCountTv.setText(String.valueOf(data.roomInfo.audienceCount + 1));
        mRoomInfo = data.roomInfo;
        mHostUserInfo = data.hostInfo;
        mSelfUserInfo = data.userInfo;
        mSeatsGroupLayout.bindHostInfo(data.hostInfo);
        mSeatsGroupLayout.bindSeatInfo(data.seatMap);
        mBottomOptionLayout.updateUIByRoleAndStatus(data.userInfo.userRole, data.userInfo.userStatus);

        setMainBackground(data.roomInfo.extraInfo);

        String appId = data.roomInfo.appId;
        if (data.isFromCreate) {
            VoiceChatRTCManager.ins().joinRoom(data.roomInfo.roomId, data.rtcToken, data.userInfo.userId);
        }
        boolean isSelfHost = TextUtils.equals(data.userInfo.userId, mHostUserInfo.userId);
        boolean isInteract = data.userInfo.userStatus == USER_STATUS_INTERACT;
        VoiceChatRTCManager.ins().startAudioCapture(isSelfHost || isInteract);
        VoiceChatRTCManager.ins().startMuteAudio(!data.userInfo.isMicOn());
    }

    private void setMainBackground(String ext) {
        if (TextUtils.isEmpty(ext)) {
            return;
        }
        try {
            Map<String, Object> extInfo = GsonUtils.gson().fromJson(ext,
                    new TypeToken<Map<String, Object>>() {
                    }.getType());
            Object backgroundName = extInfo.get("background_image_name");
            String nameStr = backgroundName == null ? null : backgroundName.toString();
            int backgroundRes;
            if (nameStr != null && nameStr.contains("voicechat_background_1")) {
                backgroundRes = R.drawable.voice_chat_demo_background_1;
            } else if (nameStr != null && nameStr.contains("voicechat_background_2")) {
                backgroundRes = R.drawable.voice_chat_demo_background_2;
            } else {
                backgroundRes = R.drawable.voice_chat_demo_background_0;
            }
            mBackgroundIv.setImageResource(backgroundRes);
        } catch (Exception e) {
            Log.e(TAG, "setMainBackground exception", e);
        }
    }

    private Drawable getSendBtnBackground() {
        float round = Utilities.dip2Px(14);
        GradientDrawable createDrawable = new GradientDrawable(
                GradientDrawable.Orientation.TOP_BOTTOM,
                new int[]{Color.parseColor("#1664FF"), Color.parseColor("#1664FF")});
        createDrawable.setCornerRadii(new float[]{round, round, round, round, round, round, round, round});
        return createDrawable;
    }

    @Override
    public void onBackPressed() {
        if (mInputLayout.getVisibility() == View.VISIBLE) {
            closeInput();
        } else {
            attemptLeave();
        }
    }

    @Override
    public void finish() {
        super.finish();
        closeInput();
        VoiceChatDataManager.ins().clearData();
        SolutionDemoEventManager.unregister(this);
        VoiceChatRTCManager.ins().leaveRoom();
        VoiceChatRTCManager.ins().startAudioMixing(false);
        VoiceChatRTCManager.ins().startAudioCapture(false);
        if (mSelfUserInfo == null || mRoomInfo == null) {
            return;
        }
        if (isLeaveByKickOut) {
            return;
        }
        if (mSelfUserInfo.isHost()) {
            VoiceChatRTCManager.ins().getRTMClient().requestFinishLive(mRoomInfo.roomId, mFinishCallback);
        } else {
            VoiceChatRTCManager.ins().getRTMClient().requestLeaveRoom(mRoomInfo.roomId, mLeaveCallback);
        }
    }

    private void onArgsError(String message) {
        CommonDialog dialog = new CommonDialog(this);
        dialog.setMessage(message);
        dialog.setCancelable(false);
        dialog.setPositiveListener((v) -> {
            finish();
            dialog.dismiss();
        });
        dialog.show();
    }

    private void attemptLeave() {
        if (mSelfUserInfo == null || !mSelfUserInfo.isHost()) {
            finish();
            return;
        }
        CommonDialog dialog = new CommonDialog(this);
        dialog.setMessage(getString(R.string.confirm_end_live_msg));
        dialog.setPositiveListener((v) -> {
            finish();
            dialog.dismiss();
        });
        dialog.setPositiveBtnText(R.string.confirm_end_live_btn_txt);
        dialog.setNegativeListener((v) -> dialog.dismiss());
        dialog.show();
    }

    private void onSendMessage(String message) {
        if (mRoomInfo == null) {
            return;
        }
        if (TextUtils.isEmpty(message)) {
            return;
        }
        mInputEt.setText("");
        closeInput();
        onReceivedMessage(String.format("%s : %s", mSelfUserInfo.userName, message));
        try {
            message = URLEncoder.encode(message, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        VoiceChatRTCManager.ins().getRTMClient().sendMessage(mRoomInfo.roomId, message, mSendMessageCallback);
    }

    private void openInput() {
        mInputLayout.setVisibility(View.VISIBLE);
        IMEUtils.openIME(mInputEt);
        mBottomOptionLayout.setVisibility(View.GONE);
    }

    private void closeInput() {
        IMEUtils.closeIME(mInputEt);
        mInputLayout.setVisibility(View.GONE);
        mBottomOptionLayout.setVisibility(View.VISIBLE);
    }

    private void onReceivedMessage(String message) {
        mVCChatAdapter.addChatMsg(message);
        mVCChatRv.post(() -> mVCChatRv.smoothScrollToPosition(mVCChatAdapter.getItemCount()));
    }

    private void switchMicStatus() {
        isMicOn = !isMicOn;

        mSeatsGroupLayout.updateUserMediaStatus(SolutionDataManager.ins().getUserId(), isMicOn);
        VoiceChatRTCManager.ins().startMuteAudio(!isMicOn);
        mBottomOptionLayout.updateMicStatus(isMicOn);
        VoiceChatRTCManager.ins().getRTMClient().updateMediaStatus(
                mRoomInfo.roomId, mSelfUserInfo.userId,
                isMicOn ? VoiceChatDataManager.MIC_OPTION_ON : VoiceChatDataManager.MIC_OPTION_OFF,
                new IRequestCallback<RTMBizResponse>() {
                    @Override
                    public void onSuccess(RTMBizResponse data) {

                    }

                    @Override
                    public void onError(int errorCode, String message) {

                    }
                });
    }

    private void showTopTip() {
        mTopTip.setVisibility(View.VISIBLE);
    }

    private void hideTopTip() {
        mTopTip.setVisibility(View.GONE);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceChangedBroadcast(AudienceChangedBroadcast event) {
        String suffix = getString(event.isJoin ? R.string.joined_room_txt : R.string.leaved_room_txt);
        onReceivedMessage(event.userInfo.userName + suffix);
        mAudienceCountTv.setText(String.valueOf(event.audienceCount + 1));
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onFinishLiveBroadcast(FinishLiveBroadcast event) {
        if (mRoomInfo == null || !TextUtils.equals(event.roomId, mRoomInfo.roomId)) {
            return;
        }
        String message = getString(event.type == FINISH_TYPE_NORMAL ? R.string.live_ended_txt : R.string.live_exp_time_txt);
        SolutionToast.show(message);
        finish();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMessageBroadcast(MessageBroadcast event) {
        if (TextUtils.equals(event.userInfo.userId, mSelfUserInfo.userId)) {
            return;
        }
        String message;
        try {
            message = URLDecoder.decode(event.message, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            message = event.message;
        }
        onReceivedMessage(String.format("%s : %s", event.userInfo.userName, message));
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onInteractChangedBroadcast(InteractChangedBroadcast event) {
        VCSeatInfo info = new VCSeatInfo();
        info.userInfo = event.userInfo;
        mSeatsGroupLayout.bindSeatInfo(event.seatId, event.isStart ? info : null);

        String msg = getString(event.isStart ? R.string.user_become_co_host_txt : R.string.user_become_audi_txt, event.userInfo.userName);
        onReceivedMessage(msg);

        boolean isSelf = TextUtils.equals(SolutionDataManager.ins().getUserId(), event.userInfo.userId);
        if (!isSelf) {
            return;
        }
        VoiceChatDataManager.ins().setSelfApply(false);
        if (event.isStart) {
            SolutionToast.show(R.string.you_has_co_host_txt);
        } else {
            if (event.type == FINISH_INTERACT_TYPE_HOST) {
                SolutionToast.show(R.string.you_has_be_audience_txt);
            } else {
                SolutionToast.show(R.string.you_has_audience_txt);
            }
        }
        mSelfUserInfo.userStatus = event.isStart ? USER_STATUS_INTERACT : USER_STATUS_NORMAL;
        VoiceChatRTCManager.ins().startAudioCapture(event.isStart);
        VoiceChatRTCManager.ins().startMuteAudio(false);

        mBottomOptionLayout.updateUIByRoleAndStatus(mSelfUserInfo.userRole, mSelfUserInfo.userStatus);
        mBottomOptionLayout.updateMicStatus(event.userInfo.isMicOn());
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onSeatChangedBroadcast(SeatChangedBroadcast event) {
        mSeatsGroupLayout.updateSeatStatus(event.seatId, event.type);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onReceivedInteractBroadcast(ReceivedInteractBroadcast event) {
        CommonDialog dialog = new CommonDialog(this);
        dialog.setMessage(getString(R.string.invitation_to_be_co_host));
        dialog.setPositiveBtnText(R.string.accept);
        dialog.setPositiveListener((v) -> {
            VoiceChatRTCManager.ins().getRTMClient().replyInvite(
                    mRoomInfo.roomId,
                    VoiceChatDataManager.REPLY_TYPE_ACCEPT,
                    event.seatId,
                    new IRequestCallback<ReplyResponse>() {
                        @Override
                        public void onSuccess(ReplyResponse data) {

                        }

                        @Override
                        public void onError(int errorCode, String message) {
                            if (errorCode == 506) {
                                SolutionToast.show(R.string.all_seats_filled_up_txt);
                            }
                        }
                    });
            dialog.dismiss();
        });
        dialog.setNegativeBtnText(R.string.confirm_decline_btn_txt);
        dialog.setNegativeListener((v) -> {
            VoiceChatRTCManager.ins().getRTMClient().replyInvite(
                    mRoomInfo.roomId,
                    VoiceChatDataManager.REPLY_TYPE_REJECT,
                    event.seatId,
                    new IRequestCallback<ReplyResponse>() {
                        @Override
                        public void onSuccess(ReplyResponse data) {

                        }

                        @Override
                        public void onError(int errorCode, String message) {

                        }
                    });
            dialog.dismiss();
        });
        dialog.show();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceApplyBroadcast(AudienceApplyBroadcast event) {
        VoiceChatDataManager.ins().setNewApply(event.hasNewApply);
        mBottomOptionLayout.updateDotTip(event.hasNewApply);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMediaChangedBroadcast(MediaChangedBroadcast event) {
        if (TextUtils.equals(mHostUserInfo.userId, event.userInfo.userId)) {
            mHostUserInfo.mic = event.mic;
        }
        mSeatsGroupLayout.updateUserMediaStatus(event.userInfo.userId, event.mic == MIC_STATUS_ON);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMediaOperateBroadcast(MediaOperateBroadcast event) {
        isMicOn = event.mic == MIC_STATUS_ON;
        mSelfUserInfo.mic = event.mic;
        SolutionToast.show(isMicOn ? R.string.you_unmuted_txt : R.string.you_be_muted_txt);
        mSeatsGroupLayout.updateUserMediaStatus(SolutionDataManager.ins().getUserId(), isMicOn);
        VoiceChatRTCManager.ins().startMuteAudio(!isMicOn);
        mBottomOptionLayout.updateMicStatus(isMicOn);
        int option = isMicOn ? VoiceChatDataManager.MIC_OPTION_ON : VoiceChatDataManager.MIC_OPTION_OFF;
        VoiceChatRTCManager.ins().getRTMClient().updateMediaStatus(mRoomInfo.roomId, mSelfUserInfo.userId, option,
                new IRequestCallback<RTMBizResponse>() {
                    @Override
                    public void onSuccess(RTMBizResponse data) {

                    }

                    @Override
                    public void onError(int errorCode, String message) {

                    }
                });
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onClearUserBroadcast(ClearUserBroadcast event) {
        if (TextUtils.equals(mRoomInfo.roomId, event.roomId) &&
                TextUtils.equals(SolutionDataManager.ins().getUserId(), event.userId)) {
            SolutionToast.show(R.string.you_force_log_out);
            isLeaveByKickOut = true;
            finish();
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudioStatsEvent(AudioStatsEvent event) {
        String builder = getString(R.string.latency_txt) + ":" + event.rtt + "ms " +
                getString(R.string.in_packed_loss) + ":" + String.format(Locale.US, "%d", (int) (event.upload * 100)) + "% " +
                getString(R.string.out_packed_loss) + ":" + String.format(Locale.US, "%d", (int) (event.download * 100)) + "%";
        mRoomStatsTv.setText(builder);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudioVolumeEvent(AudioVolumeEvent event) {
        AudioVolumeInfo[] infos = event.speakers;
        if (infos != null && infos.length != 0) {
            for (AudioVolumeInfo info : infos) {
                mSeatsGroupLayout.onUserSpeaker(info.uid, info.linearVolume);
            }
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onInteractResultBroadcast(InteractResultBroadcast event) {
        if (event.reply == VoiceChatDataManager.REPLY_TYPE_REJECT) {
            SolutionToast.show(getString(R.string.user_decline_you_invite, event.userInfo.userName));
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onSocketConnectEvent(SocketConnectEvent event) {
        if (event.status == SocketConnectEvent.ConnectStatus.DISCONNECTED) {
            showTopTip();
        } else if (event.status == SocketConnectEvent.ConnectStatus.RECONNECTED) {
            VoiceChatRTCManager.ins().getRTMClient().reconnectToServer(mReconnectCallback);
        } else if (event.status == SocketConnectEvent.ConnectStatus.CONNECTED) {
            hideTopTip();
        }
    }

    public static void openFromList(Activity activity, VCRoomInfo roomInfo) {
        Intent intent = new Intent(activity, VoiceChatRoomMainActivity.class);
        intent.putExtra(REFER_KEY, REFER_FROM_LIST);
        intent.putExtra(REFER_EXTRA_ROOM, GsonUtils.gson().toJson(roomInfo));
        VCUserInfo userInfo = new VCUserInfo();
        userInfo.userId = SolutionDataManager.ins().getUserId();
        userInfo.userName = SolutionDataManager.ins().getUserName();
        intent.putExtra(REFER_EXTRA_USER, GsonUtils.gson().toJson(userInfo));
        activity.startActivity(intent);
    }

    public static void openFromCreate(Activity activity, VCRoomInfo roomInfo, VCUserInfo userInfo, String rtcToken) {
        Intent intent = new Intent(activity, VoiceChatRoomMainActivity.class);
        intent.putExtra(REFER_KEY, REFER_FROM_CREATE);
        JoinRoomResponse response = new JoinRoomResponse();
        response.hostInfo = userInfo;
        response.userInfo = userInfo;
        response.roomInfo = roomInfo;
        response.rtcToken = rtcToken;
        response.audienceCount = 0;
        intent.putExtra(REFER_EXTRA_CREATE_JSON, GsonUtils.gson().toJson(response));
        activity.startActivity(intent);
    }
}
