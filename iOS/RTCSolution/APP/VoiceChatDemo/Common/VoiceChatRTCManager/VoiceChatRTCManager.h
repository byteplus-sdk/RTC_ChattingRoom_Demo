//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "BaseRTCManager.h"
#import "VoiceChatRTCManager.h"
#import "VoiceChatRoomParamInfoModel.h"

NS_ASSUME_NONNULL_BEGIN
@class VoiceChatRTCManager;
@protocol VoiceChatRTCManagerDelegate <NSObject>

/**
 * @brief Callback on room state changes. Via this callback you get notified of room relating warnings, errors and events. For example, the user joins the room, the user is removed from the room, and so on.
 * @param manager GameRTCManager model
 * @param userID UserID
 */
- (void)voiceChatRTCManager:(VoiceChatRTCManager *)manager
         onRoomStateChanged:(RTCJoinModel *)joinModel;

/**
 * @brief Audio quality status callback
 * @param voiceChatRTCManager GameRTCManager object
 * @param model quality status model object
 */
- (void)voiceChatRTCManager:(VoiceChatRTCManager *)voiceChatRTCManager changeParamInfo:(VoiceChatRoomParamInfoModel *)model;

/**
 * @brief Callback for volume information changes
 * @param videoChatRTCManager GameRTCManager object
 * @param volumeInfo Voice volume data, key is user id, value is volume decibel range [0,255].
 */
- (void)voiceChatRTCManager:(VoiceChatRTCManager *_Nonnull)voiceChatRTCManager reportAllAudioVolume:(NSDictionary<NSString *, NSNumber *> *_Nonnull)volumeInfo;

@end

@interface VoiceChatRTCManager : BaseRTCManager

@property (nonatomic, weak) id<VoiceChatRTCManagerDelegate> delegate;

+ (VoiceChatRTCManager *_Nullable)shareRtc;

#pragma mark - Base Method

/**
 * @brief Join the RTC room
 * @param token RTC Token
 * @param roomID RTC room ID
 * @param uid RTC user ID
 */
- (void)joinRTCRoomWithToken:(NSString *)token
                      roomID:(NSString *)roomID
                         uid:(NSString *)uid;

/**
 * @brief Leave RTC room
 */
- (void)leaveRTCRoom;

/**
 * @brief Become a guest
 * @param isGuest ture: The role is switched to be the host guest; false: The role is switched to be the audience
 */
- (void)makeGuest:(BOOL)isGuest;

/**
 * @brief Control the sending status of the local audio stream: send/not send
 * @param isPublish ture: Send, false：Not send
 */
- (void)publishAudioStream:(BOOL)isPublish;

#pragma mark - Background Music Method

/**
 * @brief Turn on the background music
 * @param filePath music sandbox path
 */
- (void)startBackgroundMusic:(NSString *)filePath;

/**
 * @brief Stop background music
 */
- (void)stopBackgroundMusic;

/**
 * @brief Pause background music
 */
- (void)pauseBackgroundMusic;

/**
 * @brief Resume background music playback
 */
- (void)resumeBackgroundMusic;

/**
 * @brief Set vocal volume
 * @param volume volume
 */
- (void)setRecordingVolume:(NSInteger)volume;

/**
 * @brief Set background volume
 * @param volume volume
 */
- (void)setMusicVolume:(NSInteger)volume;

@end

NS_ASSUME_NONNULL_END
