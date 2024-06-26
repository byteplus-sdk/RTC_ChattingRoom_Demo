//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "PhonePrivacyView.h"

static NSString *const ServiceKey = @"https://docs.byteplus.com/legal/docs/terms-of-service";
static NSString *const PrivacyKey = @"https://docs.byteplus.com/legal/docs/privacy-policy";

@interface PhonePrivacyView () <UITextViewDelegate>

@property (nonatomic, strong) BaseButton *agreeButton;
@property (nonatomic, strong) UITextView *messageLabel;

@end

@implementation PhonePrivacyView

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *str1 = LocalizedString(@"Terms of Service");
        NSString *str2 = LocalizedString(@"Privacy Policy");
        NSString *all = [NSString stringWithFormat:LocalizedString(@"Agree to our %@ and acknowledge that you have read our %@"), str1, str2];
        NSRange range1 = [all rangeOfString:str1];
        NSRange range2 = [all rangeOfString:str2];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:all];

        CGFloat font = MIN(12, 12 * SCREEN_WIDTH / 375);
        [string beginEditing];
        [string addAttribute:NSForegroundColorAttributeName
                       value:[UIColor colorFromHexString:@"#86909C"]
                       range:NSMakeRange(0, all.length)];
        [string addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:font]
                       range:NSMakeRange(0, all.length)];
        [string addAttributes:@{NSLinkAttributeName: ServiceKey}
                        range:range1];
        [string addAttributes:@{NSLinkAttributeName: PrivacyKey}
                        range:range2];
        self.messageLabel.linkTextAttributes =
            @{NSForegroundColorAttributeName: [UIColor colorFromHexString:@"#0E42D2"]};
        self.messageLabel.editable = NO;
        self.messageLabel.scrollEnabled = NO;
        self.messageLabel.delegate = self;
        [string endEditing];

        self.messageLabel.attributedText = string;

        [self addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(24);
            make.right.equalTo(self).offset(16);
            make.top.equalTo(self.mas_centerY).offset(-16.5);
        }];

        [self addSubview:self.agreeButton];
        [self.agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(16, 16));
            make.left.mas_equalTo(0);
            make.centerY.equalTo(self);
        }];
    }
    return self;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    NSString *jumpUrl = @"";
    NSString *urlStr = [NSString stringWithFormat:@"%@", URL];
    if ([urlStr isEqualToString:ServiceKey]) {
        jumpUrl = ServiceKey;
    } else if ([urlStr isEqualToString:PrivacyKey]) {
        jumpUrl = PrivacyKey;
    }

    if (jumpUrl && [jumpUrl isKindOfClass:[NSString class]] && jumpUrl.length > 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:jumpUrl]
                                           options:@{}
                                 completionHandler:^(BOOL success){

                                 }];
    }

    return YES;
}

- (void)agreeButtonAction:(UIButton *)sender {
    _isAgree = !_isAgree;
    if (_isAgree) {
        [self.agreeButton setImage:[UIImage imageNamed:@"menus_select_s" bundleName:HomeBundleName] forState:UIControlStateNormal];
    } else {
        [self.agreeButton setImage:[UIImage imageNamed:@"menus_select" bundleName:HomeBundleName] forState:UIControlStateNormal];
    }
    if (self.changeAgree) {
        self.changeAgree(_isAgree);
    }
}

- (UITextView *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UITextView alloc] init];
        _messageLabel.backgroundColor = [UIColor clearColor];
    }
    return _messageLabel;
}

- (BaseButton *)agreeButton {
    if (!_agreeButton) {
        _agreeButton = [[BaseButton alloc] init];
        [_agreeButton addTarget:self action:@selector(agreeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_agreeButton setImage:[UIImage imageNamed:@"menus_select" bundleName:HomeBundleName] forState:UIControlStateNormal];
    }
    return _agreeButton;
}

@end
