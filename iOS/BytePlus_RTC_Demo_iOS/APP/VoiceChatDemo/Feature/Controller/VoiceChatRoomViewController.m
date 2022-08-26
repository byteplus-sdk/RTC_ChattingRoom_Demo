/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import "VoiceChatRoomViewController.h"
#import "VoiceChatRoomViewController+SocketControl.h"
#import "VoiceChatStaticView.h"
#import "VoiceChatHostAvatarView.h"
#import "VoiceChatRoomBottomView.h"
#import "VoiceChatPeopleNumView.h"
#import "VoiceChatSeatCompoments.h"
#import "VoiceChatMusicCompoments.h"
#import "VoiceChatTextInputCompoments.h"
#import "VoiceChatRoomUserListCompoments.h"
#import "VoiceChatIMCompoments.h"
#import "VoiceChatRTCManager.h"
#import "NetworkingTool.h"
#import <Core/Localizator.h>

@interface VoiceChatRoomViewController () <VoiceChatRoomBottomViewDelegate, VoiceChatRTCManagerDelegate, VoiceChatSeatDelegate>

@property (nonatomic, strong) VoiceChatStaticView *staticView;
@property (nonatomic, strong) VoiceChatHostAvatarView *hostAvatarView;
@property (nonatomic, strong) VoiceChatRoomBottomView *bottomView;
@property (nonatomic, strong) VoiceChatMusicCompoments *musicCompoments;
@property (nonatomic, strong) VoiceChatTextInputCompoments *textInputCompoments;
@property (nonatomic, strong) VoiceChatRoomUserListCompoments *userListCompoments;
@property (nonatomic, strong) VoiceChatIMCompoments *imCompoments;
@property (nonatomic, strong) VoiceChatSeatCompoments *seatCompoments;
@property (nonatomic, strong) VoiceChatRoomModel *roomModel;
@property (nonatomic, strong) VoiceChatUserModel *hostUserModel;
@property (nonatomic, copy) NSString *rtcToken;

@end

@implementation VoiceChatRoomViewController

- (instancetype)initWithRoomModel:(VoiceChatRoomModel *)roomModel {
    self = [super init];
    if (self) {
        _roomModel = roomModel;
    }
    return self;
}

- (instancetype)initWithRoomModel:(VoiceChatRoomModel *)roomModel
                         rtcToken:(NSString *)rtcToken
                    hostUserModel:(VoiceChatUserModel *)hostUserModel {
    self = [super init];
    if (self) {
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
    
    [self addSocketListener];
    [self addSubviewAndConstraints];
    [self joinRoom];
    
    __weak __typeof(self) wself = self;
    [VoiceChatRTCManager shareRtc].rtcJoinRoomBlock = ^(NSString * _Nonnull roomId, NSInteger errorCode, NSInteger joinType) {
        [wself receivedJoinRoom:roomId errorCode:errorCode joinType:joinType];
    };
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

- (void)voiceControlChange:(NSDictionary *)dic {
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSString *type = dic[@"type"];
        if ([type isEqualToString:@"resume"]) {
            NSDictionary *dataDic = dic[@"data"];
            VoiceChatRoomModel *roomModel = dataDic[@"roomModel"];
            VoiceChatUserModel *userModel = dataDic[@"userModel"];
            VoiceChatUserModel *hostUserModel = dataDic[@"hostUserModel"];
            NSArray *seatList = dataDic[@"seatList"];
            NSString *RTCToken = dataDic[@"RTCToken"];
            [self updateRoomViewWithData:RTCToken
                               roomModel:roomModel
                               userModel:userModel
                           hostUserModel:hostUserModel
                                seatList:seatList];
            
            for (VoiceChatSeatModel *seatModel in seatList) {
                if ([seatModel.userModel.uid isEqualToString:userModel.uid]) {
                    // Reconnect after disconnection, I need to turn on the microphone to collect
                    [[VoiceChatRTCManager shareRtc] makeCoHost:userModel.mic == UserMicOn];
                    break;
                }
            }
            
        } else if ([type isEqualToString:@"exit"]) {
            [self hangUp:NO];
        } else {
            
        }
    }
}

- (void)clearRedNotification {
    [self.bottomView updateButtonStatus:VoiceChatRoomBottomStatusPhone isRed:NO];
    [self.userListCompoments updateWithRed:NO];
}

#pragma mark - SocketControl


- (void)receivedJoinUser:(VoiceChatUserModel *)userModel
                   count:(NSInteger)count {
    VoiceChatIMModel *model = [[VoiceChatIMModel alloc] init];
    model.userModel = userModel;
    model.isJoin = YES;
    [self.imCompoments addIM:model];
    [self.staticView updatePeopleNum:count];
    [self.userListCompoments update];
}

- (void)receivedLeaveUser:(VoiceChatUserModel *)userModel
                    count:(NSInteger)count {
    VoiceChatIMModel *model = [[VoiceChatIMModel alloc] init];
    model.userModel = userModel;
    model.isJoin = NO;
    [self.imCompoments addIM:model];
    [self.staticView updatePeopleNum:count];
    [self.userListCompoments update];
}

- (void)receivedFinishLive:(NSInteger)type roomID:(NSString *)roomID {
    if (![roomID isEqualToString:self.roomModel.roomID]) {
        return;
    }
    [self hangUp:NO];
    if (type == 2) {
        [[ToastComponents shareToastComponents] showWithMessage:LocalizedString(@"The duration of this LIVE has reached 10 minutes.") delay:0.8];
    } else {
        if (![self isHost]) {
            [[ToastComponents shareToastComponents] showWithMessage:LocalizedString(@"Live has ended") delay:0.8];
        }
    }
}

- (void)receivedJoinInteractWithUser:(VoiceChatUserModel *)userModel
                              seatID:(NSString *)seatID {
    VoiceChatSeatModel *seatModel = [[VoiceChatSeatModel alloc] init];
    seatModel.status = 1;
    seatModel.userModel = userModel;
    seatModel.index = seatID.integerValue;
    [self.seatCompoments addSeatModel:seatModel];
    [self.userListCompoments update];
    if ([userModel.uid isEqualToString:[LocalUserComponents userModel].uid]) {
        [self.bottomView updateBottomLists:userModel];
        // RTC Start Audio Capture
        [[VoiceChatRTCManager shareRtc] makeCoHost:YES];
        [[ToastComponents shareToastComponents] showWithMessage:LocalizedString(@"You have been a guest")];
    }
    
    //IM
    VoiceChatIMModel *model = [[VoiceChatIMModel alloc] init];
    NSString *message = [NSString stringWithFormat:LocalizedString(@"%@ becomes a guest"),userModel.name];
    model.message = message;
    [self.imCompoments addIM:model];
}

- (void)receivedLeaveInteractWithUser:(VoiceChatUserModel *)userModel
                               seatID:(NSString *)seatID
                                 type:(NSInteger)type {
    [self.seatCompoments removeUserModel:userModel];
    [self.userListCompoments update];
    if ([userModel.uid isEqualToString:[LocalUserComponents userModel].uid]) {
        [self.bottomView updateBottomLists:userModel];
        // RTC Stop Audio Capture
        [[VoiceChatRTCManager shareRtc] makeCoHost:NO];
        
        if (type == 1) {
            [[ToastComponents shareToastComponents] showWithMessage:LocalizedString(@"You have been removed from guest.")];
        } else if (type == 2) {
            [[ToastComponents shareToastComponents] showWithMessage:LocalizedString(@"You have been an audience")];
        }
    }
    
    //IM
    VoiceChatIMModel *model = [[VoiceChatIMModel alloc] init];
    NSString *message = [NSString stringWithFormat:LocalizedString(@"%@ becomes an audience"),userModel.name];
    model.message = message;
    [self.imCompoments addIM:model];
}

- (void)receivedSeatStatusChange:(NSString *)seatID
                            type:(NSInteger)type {
    VoiceChatSeatModel *seatModel = [[VoiceChatSeatModel alloc] init];
    seatModel.status = type;
    seatModel.userModel = nil;
    seatModel.index = seatID.integerValue;
    [self.seatCompoments updateSeatModel:seatModel];
}

- (void)receivedMediaStatusChangeWithUser:(VoiceChatUserModel *)userModel
                                   seatID:(NSString *)seatID
                                      mic:(NSInteger)mic {
    if ([userModel.uid isEqualToString:[LocalUserComponents userModel].uid]) {
        [self.bottomView updateButtonStatus:VoiceChatRoomBottomStatusLocalMic
                                   isSelect:!mic];
    }
    VoiceChatSeatModel *seatModel = [[VoiceChatSeatModel alloc] init];
    seatModel.status = 1;
    seatModel.userModel = userModel;
    seatModel.index = seatID.integerValue;
    [self.seatCompoments updateSeatModel:seatModel];
    if ([userModel.uid isEqualToString:self.roomModel.hostUid]) {
        [self.hostAvatarView updateHostMic:mic];
    }
    if ([userModel.uid isEqualToString:[LocalUserComponents userModel].uid]) {
        // RTC Mute/Unmute Audio Capture
        [[VoiceChatRTCManager shareRtc] muteLocalAudioStream:!mic];
    }
}

- (void)receivedMessageWithUser:(VoiceChatUserModel *)userModel
                        message:(NSString *)message {
    if (![userModel.uid isEqualToString:[LocalUserComponents userModel].uid]) {
        VoiceChatIMModel *model = [[VoiceChatIMModel alloc] init];
        NSString *imMessage = [NSString stringWithFormat:@"%@：%@",
                               userModel.name,
                               message];
        model.userModel = userModel;
        model.message = imMessage;
        [self.imCompoments addIM:model];
    }
}

- (void)receivedInviteInteractWithUser:(VoiceChatUserModel *)hostUserModel
                                seatID:(NSString *)seatID {
    AlertActionModel *alertModel = [[AlertActionModel alloc] init];
    alertModel.title = LocalizedString(@"Accept");
    AlertActionModel *cancelModel = [[AlertActionModel alloc] init];
    cancelModel.title = LocalizedString(@"Decline");
    [[AlertActionManager shareAlertActionManager] showWithMessage:LocalizedString(@"Host is inviting you to go LIVE together") actions:@[cancelModel, alertModel]];
    
    __weak __typeof(self) wself = self;
    alertModel.alertModelClickBlock = ^(UIAlertAction * _Nonnull action) {
        if ([action.title isEqualToString:LocalizedString(@"Accept")]) {
            [wself loadDataWithReplyInvite:1];
        }
    };
    cancelModel.alertModelClickBlock = ^(UIAlertAction * _Nonnull action) {
        if ([action.title isEqualToString:LocalizedString(@"Decline")]) {
            [wself loadDataWithReplyInvite:2];
        }
    };
}

- (void)receivedApplyInteractWithUser:(VoiceChatUserModel *)userModel
                               seatID:(NSString *)seatID {
    if ([self isHost]) {
        [self.bottomView updateButtonStatus:VoiceChatRoomBottomStatusPhone isRed:YES];
        [self.userListCompoments updateWithRed:YES];
        [self.userListCompoments update];
    }
}

- (void)receivedInviteResultWithUser:(VoiceChatUserModel *)hostUserModel
                               reply:(NSInteger)reply {
    if ([self isHost] && reply == 2) {
        NSString *message = [NSString stringWithFormat:LocalizedString(@"%@ declines your invitation"), hostUserModel.name];
        [[ToastComponents shareToastComponents] showWithMessage:message];
        [self.userListCompoments update];
    }
}

- (void)receivedMediaOperatWithUid:(NSInteger)mic {
    [VoiceChatRTMManager updateMediaStatus:self.roomModel.roomID
                                              mic:mic
                                            block:^(RTMACKModel * _Nonnull model) {
        
    }];
    if (mic) {
        [[ToastComponents shareToastComponents] showWithMessage:LocalizedString(@"You have been unmuted")];
    } else {
        [[ToastComponents shareToastComponents] showWithMessage:LocalizedString(@"You have been muted")];
    }
}

- (void)receivedClearUserWithUid:(NSString *)uid {
    [self hangUp:NO];
    [[ToastComponents shareToastComponents] showWithMessage:LocalizedString(@"A user with the same ID has logged in. You will be forced to log out.") delay:0.8];
}

- (void)hangUp:(BOOL)isServer {
    if (isServer) {
        // rtm api
        if ([self isHost]) {
            [VoiceChatRTMManager finishLive:self.roomModel.roomID];
        } else {
            [VoiceChatRTMManager leaveLiveRoom:self.roomModel.roomID];
        }
    }
    // sdk api
    [[VoiceChatRTCManager shareRtc] stopBackgroundMusic];
    [[VoiceChatRTCManager shareRtc] leaveRTCRoom];
    // ui
    [self navigationControllerPop];
}


#pragma mark - Load Data

- (void)loadDataWithJoinRoom {
    __weak __typeof(self) wself = self;
    [VoiceChatRTMManager joinLiveRoom:self.roomModel.roomID
                                    userName:[LocalUserComponents userModel].name
                                       block:^(NSString * _Nonnull RTCToken,
                                               VoiceChatRoomModel * _Nonnull roomModel,
                                               VoiceChatUserModel * _Nonnull userModel,
                                               VoiceChatUserModel * _Nonnull hostUserModel,
                                               NSArray<VoiceChatSeatModel *> * _Nonnull seatList,
                                               RTMACKModel * _Nonnull model) {
        if (NOEmptyStr(roomModel.roomID)) {
            [wself updateRoomViewWithData:RTCToken
                                roomModel:roomModel
                                userModel:userModel
                            hostUserModel:hostUserModel
                                 seatList:seatList];
        } else {
            AlertActionModel *alertModel = [[AlertActionModel alloc] init];
            alertModel.title = LocalizedString(@"OK");
            alertModel.alertModelClickBlock = ^(UIAlertAction * _Nonnull action) {
                if ([action.title isEqualToString:LocalizedString(@"OK")]) {
                    [wself hangUp:NO];
                }
            };
            [[AlertActionManager shareAlertActionManager] showWithMessage:LocalizedString(@"Joining the room failed. You will be taken to the list page.") actions:@[alertModel]];
        }
    }];
}

- (void)reconnectVoiceChatRoom {
    __weak __typeof(self) wself = self;
    [VoiceChatRTMManager reconnectWithBlock:^(NSString * _Nonnull RTCToken, VoiceChatRoomModel * _Nonnull roomModel, VoiceChatUserModel * _Nonnull userModel, VoiceChatUserModel * _Nonnull hostUserModel, NSArray<VoiceChatSeatModel *> * _Nonnull seatList, RTMACKModel * _Nonnull model) {
        NSString *type = @"";
        if (model.result) {
            type = @"resume";
        } else if (model.code == RTMStatusCodeUserIsInactive ||
                   model.code == RTMStatusCodeRoomDisbanded ||
                   model.code == RTMStatusCodeUserNotFound) {
            type = @"exit";
        } else {
            
        }
        if (NOEmptyStr(type)) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:type forKey:@"type"];
            
            NSMutableDictionary *mutabledic = [[NSMutableDictionary alloc] init];
            [mutabledic setValue:roomModel forKey:@"roomModel"];
            [mutabledic setValue:userModel forKey:@"userModel"];
            [mutabledic setValue:hostUserModel forKey:@"hostUserModel"];
            [mutabledic setValue:seatList forKey:@"seatList"];
            [mutabledic setValue:RTCToken forKey:@"RTCToken"];
            [dic setValue:[mutabledic copy] forKey:@"data"];
            [wself voiceControlChange:dic];
        }
    }];
}

- (void)loadDataWithReplyInvite:(NSInteger)type {
    [VoiceChatRTMManager replyInvite:self.roomModel.roomID
                                      reply:type
                                      block:^(RTMACKModel * _Nonnull model) {
        if (!model.result) {
            [[ToastComponents shareToastComponents] showWithMessage:model.message];
        }
    }];
}

#pragma mark - VoiceChatRoomBottomViewDelegate

- (void)voiceChatRoomBottomView:(VoiceChatRoomBottomView *_Nonnull)voiceChatRoomBottomView
                     itemButton:(VoiceChatRoomItemButton *_Nullable)itemButton
                didSelectStatus:(VoiceChatRoomBottomStatus)status {
    if (status == VoiceChatRoomBottomStatusInput) {
        [self.textInputCompoments showWithRoomModel:self.roomModel];
        __weak __typeof(self) wself = self;
        self.textInputCompoments.clickSenderBlock = ^(NSString * _Nonnull text) {
            VoiceChatIMModel *model = [[VoiceChatIMModel alloc] init];
            NSString *message = [NSString stringWithFormat:@"%@：%@",
                                 [LocalUserComponents userModel].name,
                                 text];
            model.message = message;
            [wself.imCompoments addIM:model];
        };
    } else if (status == VoiceChatRoomBottomStatusPhone) {
        [self.userListCompoments showRoomModel:self.roomModel
                                        seatID:@"-1"
                                  dismissBlock:^{
            
        }];
    } else if (status == VoiceChatRoomBottomStatusMusic) {
        [self.musicCompoments show];
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

- (void)voiceChatSeatCompoments:(VoiceChatSeatCompoments *)voiceChatSeatCompoments
                    clickButton:(VoiceChatSeatModel *)seatModel
                    sheetStatus:(VoiceChatSheetStatus)sheetStatus {
    if (sheetStatus == VoiceChatSheetStatusInvite) {
        [self.userListCompoments showRoomModel:self.roomModel
                                        seatID:[NSString stringWithFormat:@"%ld", (long)seatModel.index]
                                  dismissBlock:^{
            
        }];
    }
}

#pragma mark - VoiceChatRTCManagerDelegate

- (void)voiceChatRTCManager:(VoiceChatRTCManager *)voiceChatRTCManager changeParamInfo:(VoiceChatRoomParamInfoModel *)model {
    [self.staticView updateParamInfoModel:model];
}

- (void)voiceChatRTCManager:(VoiceChatRTCManager *_Nonnull)voiceChatRTCManager reportAllAudioVolume:(NSDictionary<NSString *, NSNumber *> *_Nonnull)volumeInfo {
    if (volumeInfo.count > 0) {
        NSNumber *volumeValue = volumeInfo[self.roomModel.hostUid];
        [self.hostAvatarView updateHostVolume:volumeValue];
        [self.seatCompoments updateSeatVolume:volumeInfo];
    }
}

#pragma mark - Private Action

- (void)joinRoom {
    if (IsEmptyStr(self.hostUserModel.uid)) {
        [self loadDataWithJoinRoom];
        self.staticView.roomModel = self.roomModel;
    } else {
        [self updateRoomViewWithData:self.rtcToken
                           roomModel:self.roomModel
                           userModel:self.hostUserModel
                       hostUserModel:self.hostUserModel
                            seatList:[self getDefaultSeatDataList]];
    }
}

- (void)updateRoomViewWithData:(NSString *)rtcToken
                     roomModel:(VoiceChatRoomModel *)roomModel
                     userModel:(VoiceChatUserModel *)userModel
                 hostUserModel:(VoiceChatUserModel *)hostUserModel
                      seatList:(NSArray<VoiceChatSeatModel *> *)seatList {
    _hostUserModel = hostUserModel;
    _roomModel = roomModel;
    _rtcToken = rtcToken;
    //Activate SDK
    [VoiceChatRTCManager shareRtc].delegate = self;
    [[VoiceChatRTCManager shareRtc] joinRTCRoomWithToken:rtcToken
                                                  roomID:self.roomModel.roomID
                                                     uid:[LocalUserComponents userModel].uid];
    if (userModel.userRole == UserRoleHost) {
        [[VoiceChatRTCManager shareRtc] makeCoHost:userModel.mic == UserMicOn];
    }
    self.hostAvatarView.userModel = self.hostUserModel;
    self.staticView.roomModel = self.roomModel;
    [self.bottomView updateBottomLists:userModel];
    [self.seatCompoments showSeatView:seatList loginUserModel:userModel];
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
    
    [self imCompoments];
    [self textInputCompoments];
}

- (void)showEndView {
    __weak __typeof(self) wself = self;
    AlertActionModel *alertModel = [[AlertActionModel alloc] init];
    alertModel.title = LocalizedString(@"End LIVE");
    alertModel.alertModelClickBlock = ^(UIAlertAction *_Nonnull action) {
        if ([action.title isEqualToString:LocalizedString(@"End LIVE")]) {
            [wself hangUp:YES];
        }
    };
    AlertActionModel *alertCancelModel = [[AlertActionModel alloc] init];
    alertCancelModel.title = LocalizedString(@"Cancel");
    NSString *message = LocalizedString(@"Are you sure end this LIVE？");
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
    return [self.roomModel.hostUid isEqualToString:[LocalUserComponents userModel].uid];
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

- (void)receivedJoinRoom:(NSString *)roomId
               errorCode:(NSInteger)errorCode
                joinType:(NSInteger)joinType {
    if ([roomId isEqualToString:self.roomModel.roomID]) {
        if (joinType != 0 && errorCode == 0) {
            [self reconnectVoiceChatRoom];
        }
    }
}

#pragma mark - Getter

- (VoiceChatTextInputCompoments *)textInputCompoments {
    if (!_textInputCompoments) {
        _textInputCompoments = [[VoiceChatTextInputCompoments alloc] init];
    }
    return _textInputCompoments;
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

- (VoiceChatSeatCompoments *)seatCompoments {
    if (!_seatCompoments) {
        _seatCompoments = [[VoiceChatSeatCompoments alloc] initWithSuperView:self.view];
        _seatCompoments.delegate = self;
    }
    return _seatCompoments;
}

- (VoiceChatRoomBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[VoiceChatRoomBottomView alloc] init];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (VoiceChatRoomUserListCompoments *)userListCompoments {
    if (!_userListCompoments) {
        _userListCompoments = [[VoiceChatRoomUserListCompoments alloc] init];
    }
    return _userListCompoments;
}

- (VoiceChatIMCompoments *)imCompoments {
    if (!_imCompoments) {
        _imCompoments = [[VoiceChatIMCompoments alloc] initWithSuperView:self.view];
    }
    return _imCompoments;
}

- (VoiceChatMusicCompoments *)musicCompoments {
    if (!_musicCompoments) {
        _musicCompoments = [[VoiceChatMusicCompoments alloc] init];
    }
    return _musicCompoments;
}

- (void)dealloc {
    [[AlertActionManager shareAlertActionManager] dismiss:^{
        
    }];
}


@end
