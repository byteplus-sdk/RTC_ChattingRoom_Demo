/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import "VoiceChatRoomListsViewController.h"
#import "VoiceChatCreateRoomViewController.h"
#import "VoiceChatRoomViewController.h"
#import "VoiceChatRoomTableView.h"
#import "VoiceChatRTCManager.h"
#import <Core/Localizator.h>

@interface VoiceChatRoomListsViewController () <VoiceChatRoomTableViewDelegate>

@property (nonatomic, strong) UIButton *createButton;
@property (nonatomic, strong) VoiceChatRoomTableView *roomTableView;
@property (nonatomic, copy) NSString *currentAppid;

@end

@implementation VoiceChatRoomListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bgView.hidden = NO;
    self.navView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.roomTableView];
    [self.roomTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.top.equalTo(self.navView.mas_bottom);
    }];
    
    [self.view addSubview:self.createButton];
    [self.createButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.width.mas_greaterThanOrEqualTo(171);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(- 48 - [DeviceInforTool getVirtualHomeHeight]);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navTitle = LocalizedString(@"Chatting room");
    [self.rightButton setImage:[UIImage imageNamed:@"refresh" bundleName:HomeBundleName] forState:UIControlStateNormal];
    
    [self loadDataWithGetLists];
}

- (void)rightButtonAction:(BaseButton *)sender {
    [super rightButtonAction:sender];
    
    [self loadDataWithGetLists];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

#pragma mark - load data

- (void)loadDataWithGetLists {
    __weak __typeof(self) wself = self;
    
    [VoiceChatRTMManager clearUser:^(RTMACKModel * _Nonnull model) {
        [VoiceChatRTMManager getActiveLiveRoomListWithBlock:^(NSArray<VoiceChatRoomModel *> * _Nonnull roomList, RTMACKModel * _Nonnull model) {
            if (model.result) {
                wself.roomTableView.dataLists = roomList;
            } else {
                wself.roomTableView.dataLists = @[];
                [[ToastComponents shareToastComponents] showWithMessage:model.message];
            }
        }];
    }];
}

#pragma mark - VoiceChatRoomTableViewDelegate

- (void)VoiceChatRoomTableView:(VoiceChatRoomTableView *)VoiceChatRoomTableView didSelectRowAtIndexPath:(VoiceChatRoomModel *)model {
    VoiceChatRoomViewController *next = [[VoiceChatRoomViewController alloc]
                                         initWithRoomModel:model];
    [self.navigationController pushViewController:next animated:YES];
}

#pragma mark - Touch Action

- (void)createButtonAction {
    VoiceChatCreateRoomViewController *next = [[VoiceChatCreateRoomViewController alloc] init];
    [self.navigationController pushViewController:next animated:YES];
}

#pragma mark - getter

- (UIButton *)createButton {
    if (!_createButton) {
        _createButton = [[UIButton alloc] init];
        _createButton.backgroundColor = [UIColor colorFromHexString:@"#4080FF"];
        [_createButton addTarget:self action:@selector(createButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _createButton.layer.cornerRadius = 25;
        _createButton.layer.masksToBounds = YES;
        _createButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        _createButton.adjustsImageWhenHighlighted = NO;
        [_createButton setImage:[UIImage imageNamed:@"voice_add" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_createButton setTitle:LocalizedString(@"Create a Room") forState:UIControlStateNormal];
        [_createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_createButton setImageEdgeInsets:UIEdgeInsetsMake(0, -4, 0, 4)];
        [_createButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, -4)];
        [_createButton setContentEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    return _createButton;
}

- (VoiceChatRoomTableView *)roomTableView {
    if (!_roomTableView) {
        _roomTableView = [[VoiceChatRoomTableView alloc] init];
        _roomTableView.delegate = self;
    }
    return _roomTableView;
}

- (void)dealloc {
    [[VoiceChatRTCManager shareRtc] disconnect];
    [PublicParameterCompoments clear];
}


@end
