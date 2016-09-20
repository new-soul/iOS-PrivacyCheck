//
//  PrivacyHelper.m
//  EGO_Business
//
//  Created by zhyy on 16/9/19.
//  Copyright © 2016年 qianxia_ios. All rights reserved.
//

#import "PrivacyHelper.h"

#import <AVFoundation/AVFoundation.h>
#import <AddressBook/ABAddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>

@implementation PrivacyHelper

+ (BOOL)checkLocationServiceAuthorization {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied) {
        [PrivacyHelper showOptonWithTitle:@"未能使用定位"];
        return false;
    } else {
        return true;
    }
}

+ (BOOL)checkNotificationServiceAuthorization {
    //TODO 判断是否第一次启动，第一次启动因为也是空，所以避免再次提示
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstshownotify"]){ // 第一次启动
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstshownotify"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return true;
    }else{
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone == setting.types) {
            [PrivacyHelper showOptonWithTitle:@"未能使用推送通知"];
            return false;
        }
        return true;
    }
    
}

+(void)CheckAddressBookAuthorization:(BoolBlock) block
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    
    if (authStatus == kABAuthorizationStatusDenied || authStatus == kABAuthorizationStatusRestricted)
    {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                 {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         if (error)
                                                         {
                                                             NSLog(@"Error: %@", (__bridge NSError *)error);
                                                         }
                                                         else if (!granted)
                                                         {
                                                             [PrivacyHelper showOptonWithTitle:@"未能使用通讯录"];
                                                             //                                                             isallow = false;
                                                             block(false);
                                                         }
                                                         else
                                                         {
                                                             block(true);
                                                         }
                                                     });
                                                 });
    }
    else
    {
        block(true);
    }
    
}

+ (BOOL)checkCameraAuthorization {
    NSString *mediaType = AVMediaTypeVideo;// Or AVMediaTypeAudio
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    // This status is normally not visible—the AVCaptureDevice class methods for discovering devices do not return devices the user is restricted from accessing.
    if (authStatus ==AVAuthorizationStatusRestricted) {
        [PrivacyHelper showOptonWithTitle:@"未能使用照相机"];
        
        return false;
    }
    else if(authStatus == AVAuthorizationStatusDenied){
        // The user has explicitly denied permission for media capture.
        [PrivacyHelper showOptonWithTitle:@"未能使用照相机"];
        
        return false;
    }
    else if(authStatus == AVAuthorizationStatusAuthorized){//允许访问
        // The user has explicitly granted permission for media capture, or explicit user permission is not necessary for the media type in question.
        NSLog(@"Authorized");
        return true;
        
    }else if(authStatus == AVAuthorizationStatusNotDetermined){
        // Explicit user permission is required for media capture, but the user has not yet granted or denied such permission.
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(granted){//点击允许访问时调用
                //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                NSLog(@"Granted access to %@", mediaType);
            }
            else {
                NSLog(@"Not granted access to %@", mediaType);
            }
            
        }];
        return true;
    }else {
        NSLog(@"Unknown authorization status");
        return true;
    }
    
}

+ (BOOL)checkPhotoLibaryAuthorization {
    int author = [ALAssetsLibrary authorizationStatus];
    //    NSLog(@"author type:%d",author);
    if(author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
        // The user has explicitly denied permission for media capture.
        [PrivacyHelper showOptonWithTitle:@"未能使用相册"];
        return false;
    }
    return true;
}



+ (void)checkMircPhoneAuthorization:(BoolBlock) block {
    //检测麦克风功能是否打开
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        block(granted);
        if (!granted)
        {
            [PrivacyHelper showOptonWithTitle:@"未能使用麦克风"];
            
        }
        else
        {
            
            
        }
    }];
}

+ (void)showOptonWithTitle:(NSString *)title {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:@"请前往设置中打开"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:true completion:nil];
                                                         }];
    UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                              if ([[UIApplication sharedApplication] canOpenURL:url]) {
                                                                  [[UIApplication sharedApplication] openURL:url];
                                                              }
                                                              [alert dismissViewControllerAnimated:true completion:nil];
                                                          }];
    
    [alert addAction:cancelAction];
    [alert addAction:settingAction];
    NSLog(@"%@",[UIApplication sharedApplication].keyWindow.rootViewController);
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end
