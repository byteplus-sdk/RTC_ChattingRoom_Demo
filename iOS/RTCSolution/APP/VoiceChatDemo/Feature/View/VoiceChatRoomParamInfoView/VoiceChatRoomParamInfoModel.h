//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoiceChatRoomParamInfoModel : NSObject
@property (nonatomic, assign) NSInteger txQuality;
@property (nonatomic, assign) NSInteger rxQuality;
@property (nonatomic, strong) NSString *rtt;

@end

NS_ASSUME_NONNULL_END
