//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "VoiceChatRTSManager.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoiceChatRoomViewController : UIViewController

/**
 * @brief Initialized with room data model, audience uses
 * @param roomModel room data model
 */
- (instancetype)initWithRoomModel:(VoiceChatRoomModel *)roomModel;

/**
 * @brief Initialized with data model and token, used by host
 * @param roomModel room data model
 * @param rtcToken RTC Token
 * @param hostUserModel host user model
 */
- (instancetype)initWithRoomModel:(VoiceChatRoomModel *)roomModel
                         rtcToken:(NSString *)rtcToken
                    hostUserModel:(VoiceChatUserModel *)hostUserModel;

#pragma mark - RTS Listener

/**
 * @brief Received the user joined the room
 * @param userModel user model
 * @param count the number of users in the current room
 */
- (void)receivedJoinUser:(VoiceChatUserModel *)userModel
                   count:(NSInteger)count;

/**
 * @brief Received the message that the user left
 * @param userModel user model
 * @param count the number of users in the current room
 */
- (void)receivedLeaveUser:(VoiceChatUserModel *)userModel
                    count:(NSInteger)count;

/**
 * @brief Received the news that the live broadcast is over
 * @param type The end type of the live broadcast. 2: Closed due to timeout, 3: Closed due to violation.
 * @param roomID room ID
 */
- (void)receivedFinishLive:(NSInteger)type roomID:(NSString *)roomID;

/**
 * @brief Received a message from a user make guest
 * @param userModel user model
 * @param seatID seat ID
 */
- (void)receivedJoinInteractWithUser:(VoiceChatUserModel *)userModel
                              seatID:(NSString *)seatID;

/**
 * @brief Receive a message that the user has make audience
 * @param userModel user model
 * @param seatID seat ID
 * @param type make audience type. 1: kicked off the make audience, 2: Actively make audience.
 */
- (void)receivedLeaveInteractWithUser:(VoiceChatUserModel *)userModel
                               seatID:(NSString *)seatID
                                 type:(NSInteger)type;

/**
 * @brief Received the message of the status change of the seat
 * @param seatID seat ID
 * @param type Seat status. 0: The microphone position is locked, 1: The normal microphone position
 */
- (void)receivedSeatStatusChange:(NSString *)seatID
                            type:(NSInteger)type;

/**
 * @brief Received a media status change message
 * @param seatID seat ID
 * @param mic Microphone switch status. 1: turn on the microphone, 0: turn off the microphone
 */
- (void)receivedMediaStatusChangeWithUser:(VoiceChatUserModel *)userModel
                                   seatID:(NSString *)seatID
                                      mic:(NSInteger)mic;

/**
 * @brief Received remote user message
 * @param userModel user model
 * @param message message content
 */
- (void)receivedMessageWithUser:(VoiceChatUserModel *)userModel
                        message:(NSString *)message;

/**
 * @brief Received the invitation to make guest
 * @param hostUserModel host user model
 * @param seatID seat ID
 */
- (void)receivedInviteInteractWithUser:(VoiceChatUserModel *)hostUserModel
                                seatID:(NSString *)seatID;

/**
 * @brief Received the message of applying for make guest
 * @param userModel user model
 * @param seatID seat ID
 */
- (void)receivedApplyInteractWithUser:(VoiceChatUserModel *)userModel
                               seatID:(NSString *)seatID;

/**
 * @brief Received invitation result message
 * @param hostUserModel host user model
 * @param reply The invitation result type. 2: Decline the invitation, 1: Agree to the invitation.
 */
- (void)receivedInviteResultWithUser:(VoiceChatUserModel *)hostUserModel
                               reply:(NSInteger)reply;

/**
 * @brief Received a message to operate the microphone
 * @param mic Microphone switch status. 1: turn on the microphone, 0: turn off the microphone
 */
- (void)receivedMediaOperatWithUid:(NSInteger)mic;

/**
 * @brief Received a message to clear the user
 * @param uid user ID
 */
- (void)receivedClearUserWithUid:(NSString *)uid;

@end

NS_ASSUME_NONNULL_END
