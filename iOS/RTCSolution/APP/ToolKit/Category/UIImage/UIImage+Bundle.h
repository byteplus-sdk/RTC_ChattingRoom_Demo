//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Bundle)

+ (nullable UIImage *)imageNamed:(NSString *)name
                      bundleName:(NSString *)bundle;

@end

NS_ASSUME_NONNULL_END
