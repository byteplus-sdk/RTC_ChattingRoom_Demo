// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
// 

#import "VoiceChatRoomViewController.h"
#import "ToolKit.h"
#import "VoiceChatRoomViewController+SocketControl.h"
#import "VoiceChatStaticView.h"
#import "VoiceChatHostAvatarView.h"
#import "VoiceChatRoomBottomView.h"
#import "VoiceChatPeopleNumView.h"
#import "VoiceChatSeatComponent.h"
#import "VoiceChatMusicComponent.h"
#import "VoiceChatTextInputComponent.h"
#import "VoiceChatRoomUserListComponent.h"
#import "VoiceChatRTCManager.h"

@interface VoiceChatRoomViewController () <VoiceChatRoomBottomViewDelegate, VoiceChatRTCManagerDelegate, VoiceChatSeatDelegate>
// Display static data View
@property (nonatomic, strong) VoiceChatStaticView *staticView;
// Host AvatarView
@property (nonatomic, strong) VoiceChatHostAvatarView *hostAvatarView;
// The bottom button encapsulates the View
@property (nonatomic, strong) VoiceChatRoomBottomView *bottomView;
// Wrapper related to background music
@property (nonatomic, strong) VoiceChatMusicComponent *musicComponent;
// Wrapper related to text input box
@property (nonatomic, strong) VoiceChatTextInputComponent *textInputComponent;
// Invite user list related wrapper
@property (nonatomic, strong) VoiceChatRoomUserListComponent *userListComponent;
// IM-related wrapper
@property (nonatomic, strong) BaseIMComponent *imComponent;
// Seat wrapper
@property (nonatomic, strong) VoiceChatSeatComponent *seatComponent;
// current room model
@property (nonatomic, strong) VoiceChatRoomModel *roomModel;
// Current host user model
@property (nonatomic, strong) VoiceChatUserModel *hostUserModel;
// Current room RTC Token
@property (nonatomic, copy) NSString *rtcToken;

@end

@implementation VoiceChatRoomViewController

- (instancetype)initWithRoomModel:(VoiceChatRoomModel *)roomModel {
    self = [super init];
    if (self) {
        // Audience join the room to use
        _roomModel = roomModel;
    }
    return self;
}

- (instancetype)initWithRoomModel:(VoiceChatRoomModel *)roomModel
                         rtcToken:(NSString *)rtcToken
                    hostUserModel:(VoiceChatUserModel *)hostUserModel {
    self = [super init];
    if (self) {
        // Host uses when creating a room
        _hostUserModel = hostUserModel;
        _roomModel = roomModel;
        _rtcToken = rtcToken;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexString:@"#394254"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearRedNotification) name:KClearRedNotification object:nil];
    // Add socket listener to listen for in-room event messages
    [self addSocketListener];
    [self addSubviewAndConstraints];
    // start join the room
    [self joinRoom];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

#pragma mark - Notification

- (void)clearRedNotification {
    // Clear the notification red dot mark on the bottom view and user list
    [self.bottomView updateButtonStatus:VoiceChatRoomBottomStatusPhone isRed:NO];
    [self.userListComponent updateWithRed:NO];
}

#pragma mark - RTS Listener

- (void)receivedJoinUser:(VoiceChatUserModel *)userModel
                   count:(NSInteger)count {
    // Received the message that the user joined
    [self addIMMessage:YES userModel:userModel];
    [self.staticView updatePeopleNum:count];
    // Update the user list view
    [self.userListComponent update];
}

- (void)receivedLeaveUser:(VoiceChatUserModel *)userModel
                    count:(NSInteger)count {
    // Receive a message that the user leaved
    [self addIMMessage:NO userModel:userModel];
    // Update the number of people in the room
    [self.staticView updatePeopleNum:count];
    [self.userListComponent update];
}

- (void)receivedFinishLive:(NSInteger)type roomID:(NSString *)roomID {
    if (![roomID isEqualToString:self.roomModel.roomID]) {
        return;
    }
    // Receive finished message then hang up
    [self hangUp:NO];
    if (type == 2) {
        // Leaving the room due to timeout
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"minutes_error_message") delay:0.8];
    } else {
        // Leaving the room because the live room is closed
        if (![self isHost]) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"live_ended") delay:0.8];
        }
    }
}

- (void)receivedJoinInteractWithUser:(VoiceChatUserModel *)userModel
                              seatID:(NSString *)seatID {
    // Received a message that a user is make guests
    VoiceChatSeatModel *seatModel = [[VoiceChatSeatModel alloc] init];
    seatModel.status = 1;
    seatModel.userModel = userModel;
    seatModel.index = seatID.integerValue;
    [self.seatComponent addSeatModel:seatModel];
    [self.userListComponent update];
    if ([userModel.uid isEqualToString:[LocalUserComponent userModel].uid]) {
        // Make guests yourself
        [self.bottomView updateBottomLists:userModel];
        [[VoiceChatRTCManager shareRtc] makeGuest:YES];
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"you_are_on_mic")];
    }
    // Display local IM messages
    BaseIMModel *model = [[BaseIMModel alloc] init];
    NSString *message = [NSString stringWithFormat:LocalizedString(@"%@_has_been_on_the_mic_message"),userModel.name];
    model.message = message;
    model.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.1 * 255];
    [self.imComponent addIM:model];
}

- (void)receivedLeaveInteractWithUser:(VoiceChatUserModel *)userModel
                               seatID:(NSString *)seatID
                                 type:(NSInteger)type {
    // Received a message that a user is make audience
    [self.seatComponent removeUserModel:userModel];
    [self.userListComponent update];
    if ([userModel.uid isEqualToString:[LocalUserComponent userModel].uid]) {
        // Make audience yourself
        [self.bottomView updateBottomLists:userModel];
        [[VoiceChatRTCManager shareRtc] makeGuest:NO];
        if (type == 1) {
            // Kicked off the seat by the host
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"you_have been_removed_from_the_mic")];
        } else if (type == 2) {
            // Actively become audience
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"you_have_leave_mic")];
        }
    }
    // Display local IM messages
    BaseIMModel *model = [[BaseIMModel alloc] init];
    NSString *message = [NSString stringWithFormat:LocalizedString(@"%@_has_been_on_the_mic_message"),userModel.name];
    model.message = message;
    model.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.1 * 255];
    [self.imComponent addIM:model];
}

- (void)receivedSeatStatusChange:(NSString *)seatID
                            type:(NSInteger)type {
    // Received the message of the status change of the seat
    VoiceChatSeatModel *seatModel = [[VoiceChatSeatModel alloc] init];
    seatModel.status = type;
    seatModel.userModel = nil;
    seatModel.index = seatID.integerValue;
    [self.seatComponent updateSeatModel:seatModel];
}

- (void)receivedMediaStatusChangeWithUser:(VoiceChatUserModel *)userModel
                                   seatID:(NSString *)seatID
                                      mic:(NSInteger)mic {
    // Received a media status change message
    VoiceChatSeatModel *seatModel = [[VoiceChatSeatModel alloc] init];
    seatModel.status = 1;
    seatModel.userModel = userModel;
    seatModel.index = seatID.integerValue;
    [self.seatComponent updateSeatModel:seatModel];
    if ([userModel.uid isEqualToString:[LocalUserComponent userModel].uid]) {
        // Received the state change of own microphone
        BOOL isPublish = (mic == 1) ? YES : NO;
        [self.bottomView updateButtonStatus:VoiceChatRoomBottomStatusLocalMic
                                   isSelect:!isPublish];
        [[VoiceChatRTCManager shareRtc] publishAudioStream:isPublish];
    }
    if ([userModel.uid isEqualToString:self.roomModel.hostUid]) {
        // Received host microphone status change
        [self.hostAvatarView updateHostMic:mic];
    }
}

- (void)receivedMessageWithUser:(VoiceChatUserModel *)userModel
                        message:(NSString *)message {
    // Received message from remote user
    if (![userModel.uid isEqualToString:[LocalUserComponent userModel].uid]) {
        BaseIMModel *model = [[BaseIMModel alloc] init];
        NSString *imMessage = [NSString stringWithFormat:@"%@：%@",
                               userModel.name,
                               message];
        model.message = imMessage;
        model.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.1 * 255];
        [self.imComponent addIM:model];
    }
}

- (void)receivedInviteInteractWithUser:(VoiceChatUserModel *)hostUserModel
                                seatID:(NSString *)seatID {
    // Received the message of invitation to make guests
    AlertActionModel *alertModel = [[AlertActionModel alloc] init];
    alertModel.title = LocalizedString(@"accept");
    AlertActionModel *cancelModel = [[AlertActionModel alloc] init];
    cancelModel.title = LocalizedString(@"decline");
    [[AlertActionManager shareAlertActionManager] showWithMessage:LocalizedString(@"anchor_invites_you_to_the_mic") actions:@[cancelModel, alertModel]];
    __weak __typeof(self) wself = self;
    alertModel.alertModelClickBlock = ^(UIAlertAction * _Nonnull action) {
        if ([action.title isEqualToString:LocalizedString(@"accept")]) {
            [wself loadDataWithReplyInvite:1];
        }
    };
    cancelModel.alertModelClickBlock = ^(UIAlertAction * _Nonnull action) {
        if ([action.title isEqualToString:LocalizedString(@"decline")]) {
            [wself loadDataWithReplyInvite:2];
        }
    };
}

- (void)receivedApplyInteractWithUser:(VoiceChatUserModel *)userModel
                               seatID:(NSString *)seatID {
    // Received the message of applying for make guests
    if ([self isHost]) {
        [self.bottomView updateButtonStatus:VoiceChatRoomBottomStatusPhone isRed:YES];
        [self.userListComponent updateWithRed:YES];
        [self.userListComponent update];
    }
}

- (void)receivedInviteResultWithUser:(VoiceChatUserModel *)hostUserModel
                               reply:(NSInteger)reply {
    // Received invitation result message
    if ([self isHost] && reply == 2) {
        NSString *message = [NSString stringWithFormat:LocalizedString(@"viewer_%@_declined_your_invitation"), hostUserModel.name];
        [[ToastComponent shareToastComponent] showWithMessage:message];
        [self.userListComponent update];
    }
}

- (void)receivedMediaOperatWithUid:(NSInteger)mic {
    // Received a message to operate the microphone
    [VoiceChatRTSManager updateMediaStatus:self.roomModel.roomID
                                       mic:mic
                                     block:^(RTSACKModel * _Nonnull model) {
        
    }];
    if (mic == 1) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"anchor_has_unmuted_you")];
    } else {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"you_have_been_muted_by_the_host")];
    }
}

- (void)receivedClearUserWithUid:(NSString *)uid {
    // Received a message to clear the user
    [self hangUp:NO];
    [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"same_logged_in") delay:0.8];
}

- (void)hangUp:(BOOL)isServer {
    if (isServer) {
        if ([self isHost]) {
            [VoiceChatRTSManager finishLive:self.roomModel.roomID];
        } else {
            [VoiceChatRTSManager leaveLiveRoom:self.roomModel.roomID];
        }
    }
    [[VoiceChatRTCManager shareRtc] stopBackgroundMusic];
    [[VoiceChatRTCManager shareRtc] leaveRTCRoom];
    [self navigationControllerPop];
}

#pragma mark - Load Data

- (void)loadDataWithJoinRoom {
    // Join business room
    [[ToastComponent shareToastComponent] showLoading];
    __weak __typeof(self) wself = self;
    [VoiceChatRTSManager joinLiveRoom:self.roomModel.roomID
                             userName:[LocalUserComponent userModel].name
                                block:^(NSString * _Nonnull RTCToken,
                                        VoiceChatRoomModel * _Nonnull roomModel,
                                        VoiceChatUserModel * _Nonnull userModel,
                                        VoiceChatUserModel * _Nonnull hostUserModel,
                                        NSArray<VoiceChatSeatModel *> * _Nonnull seatList,
                                        RTSACKModel * _Nonnull model) {
        [[ToastComponent shareToastComponent] dismiss];
        if (NOEmptyStr(roomModel.roomID)) {
            // Join RTC room
            [wself joinRTCRoomViewWithData:RTCToken
                                 roomModel:roomModel
                                 userModel:userModel
                             hostUserModel:hostUserModel
                                  seatList:seatList];
        } else {
            AlertActionModel *alertModel = [[AlertActionModel alloc] init];
            alertModel.title = LocalizedString(@"ok");
            alertModel.alertModelClickBlock = ^(UIAlertAction * _Nonnull action) {
                if ([action.title isEqualToString:LocalizedString(@"ok")]) {
                    [wself hangUp:NO];
                }
            };
            [[AlertActionManager shareAlertActionManager] showWithMessage:LocalizedString(@"joining_room_failed") actions:@[alertModel]];
        }
    }];
}

- (void)reconnectVoiceChatRoom {
    // Resume data request. After disconnecting and reconnecting successfully, the data needs to be restored.
    __weak __typeof(self) wself = self;
    [VoiceChatRTSManager reconnectWithBlock:^(NSString * _Nonnull RTCToken, VoiceChatRoomModel * _Nonnull roomModel, VoiceChatUserModel * _Nonnull userModel, VoiceChatUserModel * _Nonnull hostUserModel, NSArray<VoiceChatSeatModel *> * _Nonnull seatList, RTSACKModel * _Nonnull model) {
        if (model.result) {
            [self joinRTCRoomViewWithData:RTCToken
                                roomModel:roomModel
                                userModel:userModel
                            hostUserModel:hostUserModel
                                 seatList:seatList];
        } else if (model.code == RTSStatusCodeUserIsInactive ||
                   model.code == RTSStatusCodeRoomDisbanded ||
                   model.code == RTSStatusCodeUserNotFound) {
            [wself hangUp:NO];
        } else {
            // error
        }
    }];
}

- (void)loadDataWithReplyInvite:(NSInteger)type {
    // Reply to invite request
    [VoiceChatRTSManager replyInvite:self.roomModel.roomID
                                      reply:type
                                      block:^(RTSACKModel * _Nonnull model) {
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
        }
    }];
}

#pragma mark - VoiceChatRoomBottomViewDelegate

- (void)voiceChatRoomBottomView:(VoiceChatRoomBottomView *_Nonnull)voiceChatRoomBottomView
                     itemButton:(VoiceChatRoomItemButton *_Nullable)itemButton
                didSelectStatus:(VoiceChatRoomBottomStatus)status {
    if (status == VoiceChatRoomBottomStatusInput) {
        [self.textInputComponent showWithRoomModel:self.roomModel];
        __weak __typeof(self) wself = self;
        self.textInputComponent.clickSenderBlock = ^(NSString * _Nonnull text) {
            BaseIMModel *model = [[BaseIMModel alloc] init];
            NSString *message = [NSString stringWithFormat:@"%@：%@",
                                 [LocalUserComponent userModel].name,
                                 text];
            model.message = message;
            model.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.1 * 255];
            [wself.imComponent addIM:model];
        };
    } else if (status == VoiceChatRoomBottomStatusPhone) {
        [self.userListComponent showRoomModel:self.roomModel
                                        seatID:@"-1"
                                  dismissBlock:^{
            
        }];
    } else if (status == VoiceChatRoomBottomStatusMusic) {
        [self.musicComponent show];
    } else if (status == VoiceChatRoomBottomStatusLocalMic) {
        
    } else {
        if ([self isHost]) {
            [self showEndView];
        } else {
            [self hangUp:YES];
        }
    }
}

#pragma mark - VoiceChatSeatDelegate

- (void)voiceChatSeatComponent:(VoiceChatSeatComponent *)voiceChatSeatComponent
                    clickButton:(VoiceChatSeatModel *)seatModel
                    sheetStatus:(VoiceChatSheetStatus)sheetStatus {
    if (sheetStatus == VoiceChatSheetStatusInvite) {
        [self.userListComponent showRoomModel:self.roomModel
                                        seatID:[NSString stringWithFormat:@"%ld", (long)seatModel.index]
                                  dismissBlock:^{
            
        }];
    }
}

#pragma mark - VoiceChatRTCManagerDelegate

- (void)voiceChatRTCManager:(VoiceChatRTCManager *)manager
         onRoomStateChanged:(RTCJoinModel *)joinModel {
    if ([joinModel.roomId isEqualToString:self.roomModel.roomID]) {
        if (joinModel.joinType != 0 && joinModel.errorCode == 0) {
            // Disconnected and reconnected successfully
            [self reconnectVoiceChatRoom];
        }
    }
}

- (void)voiceChatRTCManager:(VoiceChatRTCManager *)voiceChatRTCManager changeParamInfo:(VoiceChatRoomParamInfoModel *)model {
    [self.staticView updateParamInfoModel:model];
}

- (void)voiceChatRTCManager:(VoiceChatRTCManager *_Nonnull)voiceChatRTCManager reportAllAudioVolume:(NSDictionary<NSString *, NSNumber *> *_Nonnull)volumeInfo {
    // Update user microphone volume change
    if (volumeInfo.count > 0) {
        NSNumber *volumeValue = volumeInfo[self.roomModel.hostUid];
        [self.hostAvatarView updateHostVolume:volumeValue];
        [self.seatComponent updateSeatVolume:volumeInfo];
    }
}

#pragma mark - Private Action

- (void)joinRoom {
    if (IsEmptyStr(self.hostUserModel.uid)) {
        // If it is a audience, need to join the business room first, and then join the RTC room.
        [self loadDataWithJoinRoom];
        // Render the default UI ahead of time
        self.staticView.roomModel = self.roomModel;
    } else {
        // If the host, update the UI directly.
        [self joinRTCRoomViewWithData:self.rtcToken
                            roomModel:self.roomModel
                            userModel:self.hostUserModel
                        hostUserModel:self.hostUserModel
                             seatList:[self getDefaultSeatDataList]];
    }
}

- (void)joinRTCRoomViewWithData:(NSString *)rtcToken
                      roomModel:(VoiceChatRoomModel *)roomModel
                      userModel:(VoiceChatUserModel *)userModel
                  hostUserModel:(VoiceChatUserModel *)hostUserModel
                       seatList:(NSArray<VoiceChatSeatModel *> *)seatList {
    _hostUserModel = hostUserModel;
    _roomModel = roomModel;
    _rtcToken = rtcToken;
    // Join RTC room
    [VoiceChatRTCManager shareRtc].delegate = self;
    [[VoiceChatRTCManager shareRtc] joinRTCRoomWithToken:rtcToken
                                                  roomID:self.roomModel.roomID
                                                     uid:[LocalUserComponent userModel].uid];
    if (userModel.userRole == UserRoleHost ||
        userModel.status == UserStatusActive) {
        // If the host or guest resumes the mic status
        [[VoiceChatRTCManager shareRtc] makeGuest:YES];
    } else {
        // If the audience resumes the mic state
        [[VoiceChatRTCManager shareRtc] makeGuest:NO];
    }
    // Update UI
    self.hostAvatarView.userModel = self.hostUserModel;
    self.staticView.roomModel = self.roomModel;
    [self.bottomView updateBottomLists:userModel];
    [self.bottomView updateButtonStatus:VoiceChatRoomBottomStatusLocalMic isSelect:(userModel.mic == UserMicOff) ? YES : NO];
    [self.seatComponent showSeatView:seatList loginUserModel:userModel];
}

- (void)addSubviewAndConstraints {
    [self.view addSubview:self.staticView];
    [self.staticView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.hostAvatarView];
    [self.hostAvatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(74, 95));
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo([DeviceInforTool getStatusBarHight] + 69);
    }];
    
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([DeviceInforTool getVirtualHomeHeight] + 36 + 32);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.bottom.equalTo(self.view);
    }];
    
    [self imComponent];
    [self textInputComponent];
}

- (void)showEndView {
    __weak __typeof(self) wself = self;
    AlertActionModel *alertModel = [[AlertActionModel alloc] init];
    alertModel.title = LocalizedString(@"ok");
    alertModel.alertModelClickBlock = ^(UIAlertAction *_Nonnull action) {
        if ([action.title isEqualToString:LocalizedString(@"ok")]) {
            [wself hangUp:YES];
        }
    };
    AlertActionModel *alertCancelModel = [[AlertActionModel alloc] init];
    alertCancelModel.title = LocalizedString(@"cancel");
    NSString *message = LocalizedString(@"are_you_sure_to_end_the_voice_chatroom");
    [[AlertActionManager shareAlertActionManager] showWithMessage:message actions:@[ alertCancelModel, alertModel ]];
}

- (void)navigationControllerPop {
    UIViewController *jumpVC = nil;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([NSStringFromClass([vc class]) isEqualToString:@"VoiceChatRoomListsViewController"]) {
            jumpVC = vc;
            break;
        }
    }
    if (jumpVC) {
        [self.navigationController popToViewController:jumpVC animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)isHost {
    return [self.roomModel.hostUid isEqualToString:[LocalUserComponent userModel].uid];
}

- (NSArray *)getDefaultSeatDataList {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (int i = 0; i < 8; i++) {
        VoiceChatSeatModel *seatModel = [[VoiceChatSeatModel alloc] init];
        seatModel.status = 1;
        seatModel.index = i + 1;
        [list addObject:seatModel];
    }
    return [list copy];
}

- (void)addIMMessage:(BOOL)isJoin
           userModel:(VoiceChatUserModel *)userModel {
    NSString *unitStr = isJoin ? LocalizedString(@"voice_joined_the_room") : LocalizedString(@"voice_left_room");
    BaseIMModel *imModel = [[BaseIMModel alloc] init];
    imModel.message = [NSString stringWithFormat:@"%@ %@", userModel.name, unitStr];
    imModel.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.5];
    [self.imComponent addIM:imModel];
}

#pragma mark - Getter

- (VoiceChatTextInputComponent *)textInputComponent {
    if (!_textInputComponent) {
        _textInputComponent = [[VoiceChatTextInputComponent alloc] init];
    }
    return _textInputComponent;
}

- (VoiceChatStaticView *)staticView {
    if (!_staticView) {
        _staticView = [[VoiceChatStaticView alloc] init];
    }
    return _staticView;
}

- (VoiceChatHostAvatarView *)hostAvatarView {
    if (!_hostAvatarView) {
        _hostAvatarView = [[VoiceChatHostAvatarView alloc] init];
    }
    return _hostAvatarView;
}

- (VoiceChatSeatComponent *)seatComponent {
    if (!_seatComponent) {
        _seatComponent = [[VoiceChatSeatComponent alloc] initWithSuperView:self.view];
        _seatComponent.delegate = self;
    }
    return _seatComponent;
}

- (VoiceChatRoomBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[VoiceChatRoomBottomView alloc] init];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (VoiceChatRoomUserListComponent *)userListComponent {
    if (!_userListComponent) {
        _userListComponent = [[VoiceChatRoomUserListComponent alloc] init];
    }
    return _userListComponent;
}

- (BaseIMComponent *)imComponent {
    if (!_imComponent) {
        _imComponent = [[BaseIMComponent alloc] initWithSuperView:self.view];
    }
    return _imComponent;
}

- (VoiceChatMusicComponent *)musicComponent {
    if (!_musicComponent) {
        _musicComponent = [[VoiceChatMusicComponent alloc] init];
    }
    return _musicComponent;
}

- (void)dealloc {
    [[AlertActionManager shareAlertActionManager] dismiss:^{
        
    }];
}


@end
