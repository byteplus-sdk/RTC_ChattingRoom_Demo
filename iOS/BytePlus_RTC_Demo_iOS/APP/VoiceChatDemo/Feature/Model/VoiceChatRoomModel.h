/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoiceChatRoomModel : NSObject

@property (nonatomic, copy) NSString *appID;
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, copy) NSString *hostUid;
@property (nonatomic, copy) NSString *hostName;
@property (nonatomic, assign) NSInteger enableAudienceApply;
@property (nonatomic, copy) NSString *ext;
@property (nonatomic, copy) NSDictionary *extDic;
@property (nonatomic, assign) NSInteger audienceCount;

@end

NS_ASSUME_NONNULL_END
