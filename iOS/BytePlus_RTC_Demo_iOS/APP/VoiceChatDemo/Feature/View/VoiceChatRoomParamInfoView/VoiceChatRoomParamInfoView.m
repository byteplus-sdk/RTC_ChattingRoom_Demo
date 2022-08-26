/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import "VoiceChatRoomParamInfoView.h"
#import "UIView+Fillet.h"
#import <Core/Localizator.h>

@interface VoiceChatRoomParamInfoView ()

@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation VoiceChatRoomParamInfoView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Publish Action


- (void)setParamInfoModel:(VoiceChatRoomParamInfoModel *)paramInfoModel {
    _paramInfoModel = paramInfoModel;
    
    self.messageLabel.text = [NSString stringWithFormat:@"%@ %@ms\n%@ %@%%\n%@ %@%%",
                              LocalizedString(@"Latency"),
                              paramInfoModel.rtt,
                              LocalizedString(@"Upload Packet Loss"),
                              paramInfoModel.sendLossRate,
                              LocalizedString(@"Download Packet Loss"),
                              paramInfoModel.receivedLossRate];
    
}

#pragma mark - Private Action

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:12];
        _messageLabel.textColor = [UIColor colorFromHexString:@"#00CF31"];
        _messageLabel.numberOfLines = 0;
    }
    return _messageLabel;
}

@end
