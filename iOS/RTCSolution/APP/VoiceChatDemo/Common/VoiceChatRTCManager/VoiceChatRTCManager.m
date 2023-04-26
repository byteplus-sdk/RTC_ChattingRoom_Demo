// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
// 

#import "VoiceChatRTCManager.h"

@interface VoiceChatRTCManager () <ByteRTCVideoDelegate>

// RTC / RTS room object
@property (nonatomic, strong, nullable) ByteRTCRoom *rtcRoom;
@property (nonatomic, strong) VoiceChatRoomParamInfoModel *paramInfoModel;
@property (nonatomic, assign) int audioMixingID;
@property (nonatomic, assign) BOOL isEnableAudioCapture;

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
    self.rtcRoom = [self.rtcEngineKit createRTCRoom:roomID];
    self.rtcRoom.delegate = self;
    self.isEnableAudioCapture = NO;
    // Turn on/off local audio capture
    [self.rtcEngineKit stopAudioCapture];
    [self.rtcEngineKit stopVideoCapture];
    // Set the audio routing mode, YES speaker/NO earpiece
    [self.rtcEngineKit setDefaultAudioRoute:ByteRTCAudioRouteSpeakerphone];
    // Turn on/off speaker volume keying
    ByteRTCAudioPropertiesConfig *audioPropertiesConfig = [[ByteRTCAudioPropertiesConfig alloc] init];
    audioPropertiesConfig.interval = 300;
    [self.rtcEngineKit enableAudioPropertiesReport:audioPropertiesConfig];
    // Set up the local rendering and encoding mirror (the same local and remote)
    [self.rtcEngineKit setLocalVideoMirrorType:ByteRTCMirrorTypeRenderAndEncoder];
    // Set user to incognito state
    [self.rtcRoom setUserVisibility:NO];
    // Join the room, start connecting the microphone, you need to apply for AppId and Token
    ByteRTCUserInfo *userInfo = [[ByteRTCUserInfo alloc] init];
    userInfo.userId = uid;
    
    ByteRTCRoomConfig *config = [[ByteRTCRoomConfig alloc] init];
    config.profile = ByteRTCRoomProfileInteractivePodcast;
    config.isAutoPublish = YES;
    config.isAutoSubscribeAudio = YES;
    
    [self.rtcRoom joinRoom:token userInfo:userInfo roomConfig:config];
}

- (void)leaveRTCRoom {
    // Leave the room
    [self makeGuest:NO];
    [self publishAudioStream:NO];
    [self.rtcRoom leaveRoom];
    [self.rtcRoom destroy];
    self.rtcRoom = nil;
}

- (void)makeGuest:(BOOL)isGuest {
    // Turn on/off local audio capture
    if (isGuest) {
        [SystemAuthority authorizationStatusWithType:AuthorizationTypeAudio
                                               block:^(BOOL isAuthorize) {
            if (isAuthorize) {
                [self.rtcEngineKit startAudioCapture];
                [self.rtcRoom setUserVisibility:YES];
                [self publishAudioStream:YES];
                self.isEnableAudioCapture = YES;
            }
        }];
    } else {
        [self.rtcEngineKit stopAudioCapture];
        [self.rtcRoom setUserVisibility:NO];
        self.isEnableAudioCapture = NO;
    }
}

- (void)publishAudioStream:(BOOL)isPublish {
    // Turn on/off local audio stream
    if (isPublish) {
        [self.rtcRoom publishStream:ByteRTCMediaStreamTypeAudio];
    } else {
        [self.rtcRoom unpublishStream:ByteRTCMediaStreamTypeAudio];
    }
}

#pragma mark - Background Music Method

- (void)startBackgroundMusic:(NSString *)filePath {
    // Start background music mixing
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    ByteRTCAudioMixingConfig *config = [[ByteRTCAudioMixingConfig alloc] init];
    config.type = ByteRTCAudioMixingTypePlayoutAndPublish;
    config.playCount = -1;
    [audioMixingManager startAudioMixing:_audioMixingID filePath:filePath config:config];
}

- (void)stopBackgroundMusic {
    // Stop background music mixing
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    [audioMixingManager stopAudioMixing:_audioMixingID];
}

- (void)pauseBackgroundMusic {
    // Pause background music mixing
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    [audioMixingManager pauseAudioMixing:_audioMixingID];
}

- (void)resumeBackgroundMusic {
    // Continue background music mixing
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    [audioMixingManager resumeAudioMixing:_audioMixingID];
}

- (void)setRecordingVolume:(NSInteger)volume {
    // Set the volume of the mixed music
    [self.rtcEngineKit setCaptureVolume:ByteRTCStreamIndexMain volume:(int)volume];
}

- (void)setMusicVolume:(NSInteger)volume {
    // Set the volume of the mixed music
    ByteRTCAudioMixingManager *audioMixingManager = [self.rtcEngineKit getAudioMixingManager];
    
    [audioMixingManager setAudioMixingVolume:_audioMixingID volume:(int)volume type:ByteRTCAudioMixingTypePlayoutAndPublish];
}

#pragma mark - ByteRTCRoomDelegate

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRoomStateChanged:(NSString *)roomId
        withUid:(NSString *)uid
          state:(NSInteger)state
      extraInfo:(NSString *)extraInfo {
    [super rtcRoom:rtcRoom onRoomStateChanged:roomId withUid:uid state:state extraInfo:extraInfo];
    
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        RTCJoinModel *joinModel = [RTCJoinModel modelArrayWithClass:extraInfo state:state roomId:roomId];
        if ([self.delegate respondsToSelector:@selector(voiceChatRTCManager:onRoomStateChanged:)]) {
            [self.delegate voiceChatRTCManager:self onRoomStateChanged:joinModel];
        }
    });
}

#pragma mark - ByteRTCVideoDelegate

- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onNetworkQuality:(ByteRTCNetworkQualityStats *)localQuality remoteQualities:(NSArray<ByteRTCNetworkQualityStats *> *)remoteQualities {
    if (self.isEnableAudioCapture) {
        self.paramInfoModel.rtt = [NSString stringWithFormat:@"%.0ld",(long)localQuality.rtt];
    } else {
        self.paramInfoModel.rtt = [NSString stringWithFormat:@"%.0ld",(long)remoteQualities.firstObject.rtt];
    }
    // Downlink network quality score
    self.paramInfoModel.rxQuality = localQuality.rxQuality;
    // Uplink network quality score
    self.paramInfoModel.txQuality = localQuality.txQuality;
    [self updateRoomParamInfoModel];
}

#pragma mark - ByteRTCVideoDelegate

- (void)rtcEngine:(ByteRTCVideo *)engine onRemoteAudioPropertiesReport:(NSArray<ByteRTCRemoteAudioPropertiesInfo *> *)audioPropertiesInfos totalRemoteVolume:(NSInteger)totalRemoteVolume {
    // Volume callback
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < audioPropertiesInfos.count; i++) {
        ByteRTCRemoteAudioPropertiesInfo *model = audioPropertiesInfos[i];
        [dic setValue:@(model.audioPropertiesInfo.linearVolume) forKey:model.streamKey.userId];
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


#pragma mark - Getter

- (VoiceChatRoomParamInfoModel *)paramInfoModel {
    if (!_paramInfoModel) {
        _paramInfoModel = [[VoiceChatRoomParamInfoModel alloc] init];
    }
    return _paramInfoModel;
}

@end
