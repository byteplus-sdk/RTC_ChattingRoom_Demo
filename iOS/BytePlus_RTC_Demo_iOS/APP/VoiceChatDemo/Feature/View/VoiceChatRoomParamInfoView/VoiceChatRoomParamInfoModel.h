/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoiceChatRoomParamInfoModel : NSObject

@property (nonatomic, strong) NSString *sendLossRate;
@property (nonatomic, strong) NSString *receivedLossRate;
@property (nonatomic, strong) NSString *rtt;

@end

NS_ASSUME_NONNULL_END
