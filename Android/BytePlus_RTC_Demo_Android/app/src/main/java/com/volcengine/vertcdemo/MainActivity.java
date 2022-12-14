/**
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

package com.volcengine.vertcdemo;

import android.Manifest;
import android.app.AlertDialog;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.lifecycle.Lifecycle;

import com.ss.video.rtc.demo.basic_module.acivities.BaseActivity;
import com.ss.video.rtc.demo.basic_module.utils.WindowUtils;
import com.volcengine.vertcdemo.core.SolutionDataManager;
import com.volcengine.vertcdemo.core.eventbus.SolutionDemoEventManager;
import com.volcengine.vertcdemo.core.eventbus.TokenExpiredEvent;
import com.volcengine.vertcdemo.core.eventbus.UpgradeAppEvent;
import com.volcengine.vertcdemo.entity.AuditStateResult;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class MainActivity extends BaseActivity {

    private View mTabScenes;
    private View mTabProfile;

    private boolean mHasLayoutCompleted = false;

    private static final String TAG_SCENES = "fragment_tag_scenes";
    private static final String TAG_PROFILE = "fragment_tag_profile";

    private Fragment mFragmentScenes;
    private Fragment mFragmentProfile;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        String token = SolutionDataManager.ins().getToken();
        if (TextUtils.isEmpty(token)) {
            startActivity(new Intent(Actions.LOGIN));
        }
        requestPermissions(Manifest.permission.RECORD_AUDIO, Manifest.permission.CAMERA, Manifest.permission.WRITE_EXTERNAL_STORAGE);

        mTabScenes = findViewById(R.id.tab_scenes);
        mTabScenes.setOnClickListener(v -> switchMainLayout(true));

        mTabProfile = findViewById(R.id.tab_profile);
        mTabProfile.setOnClickListener(v -> switchMainLayout(false));

        // region ?????????????????? Tab ??? Fragment
        final FragmentManager supportFragmentManager = getSupportFragmentManager();
        Fragment tabScene = supportFragmentManager.findFragmentByTag(TAG_SCENES);
        if (tabScene == null) {
            tabScene = new SceneEntryFragment();
            supportFragmentManager
                    .beginTransaction()
                    .add(R.id.tab_content, tabScene, TAG_SCENES)
                    .commit();
        }

        mFragmentScenes = tabScene;

        Fragment tabProfile = supportFragmentManager.findFragmentByTag(TAG_PROFILE);
        if (tabProfile == null) {
            tabProfile = new ProfileFragment();
            supportFragmentManager
                    .beginTransaction()
                    .add(R.id.tab_content, tabProfile, TAG_PROFILE)
                    .commit();
        }
        mFragmentProfile = tabProfile;
        // endregion

        switchMainLayout(true);

        SolutionDemoEventManager.register(this);
    }

    @Override
    protected void onGlobalLayoutCompleted() {
        super.onGlobalLayoutCompleted();
        if (mHasLayoutCompleted) {
            return;
        }
        mHasLayoutCompleted = true;
    }

    @Override
    protected void setupStatusBar() {
        WindowUtils.setLayoutFullScreen(getWindow());
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        SolutionDemoEventManager.unregister(this);
    }

    private void switchMainLayout(boolean isEntrance) {
        mTabScenes.setSelected(isEntrance);
        mTabProfile.setSelected(!isEntrance);

        if (isEntrance) {
            getSupportFragmentManager()
                    .beginTransaction()
                    .hide(mFragmentProfile)
                    .show(mFragmentScenes)
                    .commit();
        } else {
            getSupportFragmentManager()
                    .beginTransaction()
                    .hide(mFragmentScenes)
                    .show(mFragmentProfile)
                    .commit();
        }
    }

    private void openUpdateDialog(AuditStateResult result) {
        if (getLifecycle().getCurrentState() != Lifecycle.State.RESUMED) {
            return;
        }
        AlertDialog.Builder builder = new AlertDialog.Builder(this, R.style.transparentDialog);
        View view = getLayoutInflater().inflate(R.layout.layout_verify_upgrade, null);
        builder.setView(view);
        TextView cancel = view.findViewById(R.id.verify_upgrade_dialog_cancel);
        TextView confirm = view.findViewById(R.id.verify_upgrade_dialog_confirm);
        builder.setCancelable(true);
        AlertDialog dialog = builder.create();
        cancel.setOnClickListener((d) -> dialog.dismiss());
        confirm.setOnClickListener(v -> {
            Intent i = new Intent(Intent.ACTION_VIEW);
            i.setData(Uri.parse(result.url));
            MainActivity.this.startActivity(i);
        });
        dialog.show();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onUpgradeAppEvent(UpgradeAppEvent event) {
        openUpdateDialog(event.result);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onTokenExpiredEvent(TokenExpiredEvent event) {
        switchMainLayout(true);
        startActivity(new Intent(Actions.LOGIN));
    }
}
