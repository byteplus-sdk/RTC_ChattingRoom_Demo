/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import "VoiceChatRTCManager.h"
#import "AlertActionManager.h"
#import "SystemAuthority.h"

@interface VoiceChatRTCManager () <ByteRTCVideoDelegate>

@property (nonatomic, strong) VoiceChatRoomParamInfoModel *paramInfoModel;
@property (nonatomic, assign) int audioMixingID;

@end

@implementation VoiceChatRTCManager

+ (VoiceChatRTCManager *_Nullable)shareRtc {
    static VoiceChatRTCManager *rtcManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rtcManager = [[VoiceChatRTCManager alloc] init];
    });
    return rtcManager;
}

#pragma mark - Publish Action

- (instancetype)init {
    self = [super init];
    if (self) {
        _audioMixingID = 3001;
    }
    return self;
}

- (void)joinRTCRoomWithToken:(NSString *)token
                      roomID:(NSString *)roomID
                         uid:(NSString *)uid {
    //关闭 本地音频/视频采集
    //Turn on/off local audio capture
    [self.rtcVideo stopAudioCapture];
    [self.rtcVideo stopVideoCapture];

    //设置音频路由模式，YES 扬声器/NO 听筒
    //Set the audio routing mode, YES speaker/NO earpiece
    [self.rtcVideo setAudioPlaybackDevice:ByteRTCAudioPlaybackDeviceSpeakerphone];
    
    //开启/关闭发言者音量键控
    //Turn on/off speaker volume keying
    ByteRTCAudioPropertiesConfig *audioPropertiesConfig = [[ByteRTCAudioPropertiesConfig alloc]init];
    audioPropertiesConfig.interval = 300;
    audioPropertiesConfig.enable_spectrum = NO;
    audioPropertiesConfig.enable_vad = NO;
    [self.rtcVideo enableAudioPropertiesReport:audioPropertiesConfig];
    
    //设置用户为隐身状态
    //Set user to incognito state
    [self.rtcRoom setUserVisibility:NO];

    //加入房间，开始连麦,需要申请AppId和Token
    //Join the room, start connecting the microphone, you need to apply for AppId and Token
    ByteRTCUserInfo *userInfo = [[ByteRTCUserInfo alloc] init];
    userInfo.userId = uid;
    
    ByteRTCRoomConfig *config = [[ByteRTCRoomConfig alloc] init];
    config.profile = ByteRTCRoomProfileLiveBroadcasting;
    config.isAutoPublish = YES;
    config.isAutoSubscribeAudio = YES;
    
    self.rtcRoom  = [self.rtcVideo createRTCRoom:roomID];
    self.rtcRoom.delegate = self;
    [self.rtcRoom joinRoomByToken:token userInfo:userInfo roomConfig:config];
    
    
        
}

#pragma mark - rtc method

- (void)makeCoHost:(BOOL)isCoHost {
    //开启/关闭 本地音频采集
    //Turn on/off local audio capture
    if (isCoHost) {
        [SystemAuthority authorizationStatusWithType:AuthorizationTypeAudio
                                               block:^(BOOL isAuthorize) {
            if (isAuthorize) {
                [self.rtcVideo startAudioCapture];
                [self muteLocalAudioStream:NO];
                [self.rtcRoom setUserVisibility:YES];
            }
        }];
    } else {
        [self.rtcVideo stopAudioCapture];
        [self.rtcRoom setUserVisibility:NO];
    }
}

- (void)muteLocalAudioStream:(BOOL)isMute {
    //开启/关闭 本地音频推流
    //Turn on/off local audio stream
    if (isMute) {
        [self.rtcRoom unpublishStream:ByteRTCMediaStreamTypeAudio];
    } else {
        [self.rtcRoom publishStream:ByteRTCMediaStreamTypeAudio];
    }
}

- (void)leaveRTCRoom {
    //离开频道
    //Leave the channel
    [self makeCoHost:NO];
    [self muteLocalAudioStream:YES];
    [self.rtcRoom leaveRoom];
    [self.rtcRoom destroy];
}

#pragma mark - Background Music Method

- (void)startBackgroundMusic:(NSString *)filePath {
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcVideo getAudioMixingManager];
    
    ByteRTCAudioMixingConfig *config = [[ByteRTCAudioMixingConfig alloc] init];
    config.type = ByteRTCAudioMixingTypePlayoutAndPublish;
    config.playCount = -1;
    [audioMixingManager startAudioMixing:_audioMixingID filePath:filePath config:config];
}

- (void)stopBackgroundMusic {
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcVideo getAudioMixingManager];
    [audioMixingManager stopAudioMixing:_audioMixingID];
}

- (void)pauseBackgroundMusic {
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcVideo getAudioMixingManager];
    
    [audioMixingManager pauseAudioMixing:_audioMixingID];
}

- (void)resumeBackgroundMusic {
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcVideo getAudioMixingManager];
    
    [audioMixingManager resumeAudioMixing:_audioMixingID];
}

- (void)setRecordingVolume:(NSInteger)volume {
    // 设置麦克风采集音量
    // Set the volume of the mixed music
    [self.rtcVideo setCaptureVolume:ByteRTCStreamIndexMain volume:(int)volume];
}

- (void)setMusicVolume:(NSInteger)volume {
    // 设置混音音乐音量
    // Set the volume of the mixed music
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcVideo getAudioMixingManager];
    
    [audioMixingManager setAudioMixingVolume:_audioMixingID volume:(int)volume type:ByteRTCAudioMixingTypePlayoutAndPublish];
}

#pragma mark - ByteRTCVideoDelegate

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onLocalStreamStats:(ByteRTCLocalStreamStats *)stats {
    if (stats.audio_stats.audioLossRate > 0) {
        self.paramInfoModel.sendLossRate = [NSString stringWithFormat:@"%.0f",stats.audio_stats.audioLossRate];
    }
    if (stats.audio_stats.rtt > 0) {
        self.paramInfoModel.rtt = [NSString stringWithFormat:@"%.0ld",(long)stats.audio_stats.rtt];
    }
    [self updateRoomParamInfoModel];
}

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRemoteStreamStats:(ByteRTCRemoteStreamStats *)stats {
    if (stats.audio_stats.audioLossRate > 0) {
        self.paramInfoModel.receivedLossRate = [NSString stringWithFormat:@"%.0f",stats.audio_stats.audioLossRate];
    }
    [self updateRoomParamInfoModel];
}

- (void)rtcEngine:(ByteRTCVideo * _Nonnull)engine onAudioVolumeIndication:(NSArray<ByteRTCAudioVolumeInfo *> * _Nonnull)speakers totalRemoteVolume:(NSInteger)totalRemoteVolume {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < speakers.count; i++) {
        ByteRTCAudioVolumeInfo *model = speakers[i];
        [dic setValue:@(model.linearVolume) forKey:model.uid];
    }
    if ([self.delegate respondsToSelector:@selector(voiceChatRTCManager:reportAllAudioVolume:)]) {
        [self.delegate voiceChatRTCManager:self reportAllAudioVolume:dic];
    }
}

#pragma mark - Private Action

- (void)updateRoomParamInfoModel {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(voiceChatRTCManager:changeParamInfo:)]) {
            [self.delegate voiceChatRTCManager:self changeParamInfo:self.paramInfoModel];
        }
    });
}


#pragma mark - getter

- (VoiceChatRoomParamInfoModel *)paramInfoModel {
    if (!_paramInfoModel) {
        _paramInfoModel = [[VoiceChatRoomParamInfoModel alloc] init];
    }
    return _paramInfoModel;
}

@end
