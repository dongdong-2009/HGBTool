//
//  HGBTouchIDTool.h
//  指纹锁
//
//  Created by huangguangbao on 2017/6/23.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <UIKit/UIKit.h>


#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif


typedef NS_ENUM(NSUInteger, HGBOperatingTouchIDResult) {
    /** 当前设备不支持TouchID */
    HGBTouchIDResultTypeNotSupport = 10,
    /** TouchID 验证成功 */
    HGBTouchIDResultTypeSucess=1,
    
    /** TouchID 验证失败 */
    HGBTouchIDResultTypeFailed=99,
    
    /** TouchID 被用户取消 */
    HGBTouchIDResultTypeUserCancel=2,
    
    /** TouchID 被系统取消(如遇到来电,锁屏,按了Home键等) */
    HGBTouchIDResultTypeSystemCancel=3,
    
    /** 当前软件被挂起并取消了授权 (如App进入了后台等) */
    HGBTouchIDResultTypeAppCancel=4,
    
    /** 当前软件被挂起并取消了授权 (请求验证出错) */
    HGBTouchIDResultTypeInvalidContext=11,
    
    /** 用户不使用TouchID,选择手动输入密码 */
    HGBTouchIDResultTypeInputPassword=100,
    
    /** TouchID 无法启动,因为用户没有设置密码 */
    HGBTouchIDResultTypePasswordNotSet=60,
    
    /** TouchID 无法启动,因为用户没有设置TouchID */
    HGBTouchIDResultTypeNotSet=61,
    
    /** TouchID 无效 */
    HGBTouchIDResultTypeNotAvailable=62,
    
    /** TouchID 被锁定(连续多次验证TouchID失败,系统需要用户手动输入密码) */
    HGBTouchIDResultTypeLockout=13,
    
    /** TouchID 验证失败,未知原因 */
    HGBTouchIDResultTyoeUnknown=98,
    
    /** 系统版本不支持TouchID (必须高于iOS 8.0才能使用) */
    HGBTouchIDResultTypeVersionNotSupport=12
};



/**
 指纹解锁
 */
@interface HGBTouchIDTool : NSObject


/**
 验证设备是否支持指纹解锁
 
 @param block block
 @return 返回结果
 */
+ (BOOL)validationTouchIDIsSupportWithBlock:(void(^)(BOOL isSupport,LAContext *context, NSInteger policy, NSDictionary *messageInfo))block;

/**
 指纹解锁
 
 @param message 提示文本
 @param cancelTitle 取消按钮显示内容(此参数只有iOS10以上才能生效),默认显示：取消
 @param otherTitle 密码登录按钮显示内容(默认*密码登录*),如果传入空字符串@""/nil,则只会显示独立的取消按钮
 @param enabled 默认为NO点击密码使用系统解锁/YES时，自己操作点击密码登录
 @param resultBlock 返回结果
 */
+ (void)touchIDWithMessage:(NSString *)message cancelTitle:(NSString *)cancelTitle otherTitle:(NSString *)otherTitle enabled:(BOOL)enabled andWithOperatingrResultBlock:(void(^)(HGBOperatingTouchIDResult result,NSDictionary *messageInfo))resultBlock;
@end
