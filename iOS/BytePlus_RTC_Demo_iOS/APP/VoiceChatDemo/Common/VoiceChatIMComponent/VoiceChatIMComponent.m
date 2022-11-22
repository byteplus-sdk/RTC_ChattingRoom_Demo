/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import "VoiceChatIMComponent.h"
#import "VoiceChatIMView.h"

@interface VoiceChatIMComponent ()

@property (nonatomic, strong) VoiceChatIMView *voiceChatIMView;

@end

@implementation VoiceChatIMComponent

- (instancetype)initWithSuperView:(UIView *)superView {
    self = [super init];
    if (self) {
        [superView addSubview:self.voiceChatIMView];
        [self.voiceChatIMView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.bottom.mas_equalTo(-101 - ([DeviceInforTool getVirtualHomeHeight]));
            make.top.mas_equalTo(355 + [DeviceInforTool getStatusBarHight] + 40);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)addIM:(VoiceChatIMModel *)model {
    NSMutableArray *datas = [[NSMutableArray alloc] initWithArray:self.voiceChatIMView.dataLists];
    [datas addObject:model];
    self.voiceChatIMView.dataLists = [datas copy];
}

#pragma mark - getter

- (VoiceChatIMView *)voiceChatIMView {
    if (!_voiceChatIMView) {
        _voiceChatIMView = [[VoiceChatIMView alloc] init];
    }
    return _voiceChatIMView;
}

@end
