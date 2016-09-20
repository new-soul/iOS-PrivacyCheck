//
//  PrivacyHelper.h
//  EGO_Business
//
//  Created by zhyy on 16/9/19.
//  Copyright © 2016年 qianxia_ios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrivacyHelper : NSObject

typedef void(^BoolBlock)(BOOL enable);

+ (BOOL)checkLocationServiceAuthorization;
+ (BOOL)checkNotificationServiceAuthorization;
+ (void)CheckAddressBookAuthorization:(BoolBlock) block;
+ (BOOL)checkCameraAuthorization;
+ (BOOL)checkPhotoLibaryAuthorization;
+ (void)checkMircPhoneAuthorization:(BoolBlock) block;

@end
