//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "VoiceChatUserModel.h"
#import <Foundation/Foundation.h>

@interface VoiceChatSeatModel : NSObject

/// status: 0 close, 1 open
@property (nonatomic, assign) NSInteger status;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) VoiceChatUserModel *userModel;

@end
