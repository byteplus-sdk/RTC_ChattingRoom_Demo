//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "VoiceChatCreateRoomViewController.h"
#import "VoiceChatCreateRoomTipView.h"
#import "VoiceChatRoomViewController.h"
#import "VoiceChatSelectBgView.h"

@interface VoiceChatCreateRoomViewController ()

@property (nonatomic, strong) VoiceChatCreateRoomTipView *tipView;
@property (nonatomic, strong) UILabel *roomTitleLabel;
@property (nonatomic, strong) UILabel *roomNameLabel;
@property (nonatomic, strong) UILabel *bgTitleLabel;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) VoiceChatSelectBgView *selectBgView;
@property (nonatomic, strong) UIButton *joinButton;
@property (nonatomic, copy) NSString *bgImageName;

@end

@implementation VoiceChatCreateRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexString:@"#272E3B"];
    [self addSubviewAndConstraints];
    self.bgImageView.image = [UIImage imageNamed:[self.selectBgView getDefaults]];
    _bgImageName = [self.selectBgView getDefaults];

    __weak __typeof(self) wself = self;
    self.selectBgView.clickBlock = ^(NSString *_Nonnull imageName,
                                     NSString *_Nonnull smallImageName) {
        wself.bgImageView.image = [UIImage imageNamed:imageName];
        wself.bgImageName = imageName;
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navTitle = @"";
    self.navLeftImage = [UIImage imageNamed:@"voice_cancel" bundleName:HomeBundleName];
}

- (void)joinButtonAction:(UIButton *)sender {
    [[ToastComponent shareToastComponent] showLoading];
    __weak __typeof(self) wself = self;
    [VoiceChatRTSManager startLive:self.roomNameLabel.text
                          userName:[LocalUserComponent userModel].name
                       bgImageName:_bgImageName
                             block:^(NSString *_Nonnull RTCToken,
                                     VoiceChatRoomModel *_Nonnull roomModel,
                                     VoiceChatUserModel *_Nonnull hostUserModel,
                                     RTSACKModel *_Nonnull model) {
                                 if (model.result) {
                                     VoiceChatRoomViewController *next = [[VoiceChatRoomViewController alloc]
                                         initWithRoomModel:roomModel
                                                  rtcToken:RTCToken
                                             hostUserModel:hostUserModel];
                                     [wself.navigationController pushViewController:next animated:YES];
                                 } else {
                                     [[ToastComponent shareToastComponent] showWithMessage:model.message];
                                 }
                                 [[ToastComponent shareToastComponent] dismiss];
                             }];
}

#pragma mark - Private Action

- (void)addSubviewAndConstraints {
    [self.view addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.view bringSubviewToFront:self.navView];
    self.navView.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.tipView];
    [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(0);
        make.top.equalTo(self.navView.mas_bottom).offset(8);
    }];

    [self.view addSubview:self.roomTitleLabel];
    [self.roomTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.top.equalTo(self.navView.mas_bottom).offset(86);
    }];

    [self.view addSubview:self.roomNameLabel];
    [self.roomNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.roomTitleLabel);
        make.top.equalTo(self.roomTitleLabel.mas_bottom).offset(12);
    }];

    [self.view addSubview:self.bgTitleLabel];
    [self.bgTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.roomTitleLabel);
        make.top.equalTo(self.roomNameLabel.mas_bottom).offset(24);
    }];

    CGFloat selectBgViewHeight = ((SCREEN_WIDTH - (30 * 2)) - (12 * 2)) / 3;
    [self.view addSubview:self.selectBgView];
    [self.selectBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(selectBgViewHeight);
        make.top.equalTo(self.bgTitleLabel.mas_bottom).offset(12);
    }];

    [self.view addSubview:self.joinButton];
    [self.joinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.selectBgView.mas_bottom).offset(40);
    }];
}

#pragma mark - Getter

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.clipsToBounds = YES;
    }
    return _bgImageView;
}

- (UILabel *)roomTitleLabel {
    if (!_roomTitleLabel) {
        _roomTitleLabel = [[UILabel alloc] init];
        _roomTitleLabel.font = [UIFont systemFontOfSize:16];
        _roomTitleLabel.textColor = [UIColor colorFromHexString:@"#C9CDD4"];
        _roomTitleLabel.text = LocalizedString(@"name");
    }
    return _roomTitleLabel;
}

- (UILabel *)roomNameLabel {
    if (!_roomNameLabel) {
        _roomNameLabel = [[UILabel alloc] init];
        _roomNameLabel.font = [UIFont systemFontOfSize:14];
        _roomNameLabel.textColor = [UIColor colorFromHexString:@"#FFFFFF"];
        _roomNameLabel.text = [NSString stringWithFormat:LocalizedString(@"%@_voice_chat_room"), [LocalUserComponent userModel].name];
    }
    return _roomNameLabel;
}

- (UILabel *)bgTitleLabel {
    if (!_bgTitleLabel) {
        _bgTitleLabel = [[UILabel alloc] init];
        _bgTitleLabel.font = [UIFont systemFontOfSize:16];
        _bgTitleLabel.textColor = [UIColor colorFromHexString:@"#C9CDD4"];
        _bgTitleLabel.text = LocalizedString(@"background");
    }
    return _bgTitleLabel;
}

- (VoiceChatSelectBgView *)selectBgView {
    if (!_selectBgView) {
        _selectBgView = [[VoiceChatSelectBgView alloc] init];
        _selectBgView.backgroundColor = [UIColor clearColor];
    }
    return _selectBgView;
}

- (UIButton *)joinButton {
    if (!_joinButton) {
        _joinButton = [[UIButton alloc] init];
        [_joinButton setBackgroundImage:[UIImage imageNamed:@"voicechar_join" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_joinButton setTitle:LocalizedString(@"open_chat_room") forState:UIControlStateNormal];
        [_joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _joinButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        [_joinButton addTarget:self action:@selector(joinButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _joinButton.layer.cornerRadius = 22;
        _joinButton.layer.masksToBounds = YES;
    }
    return _joinButton;
}

- (VoiceChatCreateRoomTipView *)tipView {
    if (!_tipView) {
        _tipView = [[VoiceChatCreateRoomTipView alloc] init];
        _tipView.message =
            [NSString stringWithFormat:LocalizedString(@"application_experiencing_%@_title"), @"20"];
    }
    return _tipView;
}

@end
