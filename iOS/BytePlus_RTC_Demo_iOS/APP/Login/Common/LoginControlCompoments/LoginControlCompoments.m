/*
 * Copyright 2022 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: MIT
 */

#import "LoginControlCompoments.h"
#import "NetworkingManager+Login.h"

@implementation LoginControlCompoments

+ (void)passwordFreeLogin:(NSString *)userName block:(void (^)(BOOL, NSString * _Nullable))block {
    [NetworkingManager passwordFreeLogin:userName
                                   block:^(BaseUserModel * _Nullable userModel,
                                           NSString * _Nullable loginToken,
                                           NetworkingResponse * _Nonnull response) {
        BOOL result = response.result;
        if (response.result) {
            [LocalUserComponents updateLocalUserModel:userModel];
        }
        if (block) {
            block(result, result? nil : response.message);
        }
    }];
}

@end
