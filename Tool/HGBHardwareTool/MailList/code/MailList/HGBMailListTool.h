//
//  HGBMailListTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/10/31.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HGBMailModel.h"

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif


typedef NS_ENUM(NSUInteger, HGBMailListAuthStatus) {
    HGBMailListAuthStatusNotDetermined = 0,
    HGBMailListAuthStatusRestricted,
    HGBMailListAuthStatusDenied,
    HGBMailListAuthStatusAuthorized
};
typedef NS_ENUM(NSUInteger, HGBMailListError) {

    HGBMailListErrorAuthorized=11,//权限不足
    HGBMailListErrorError=98,//未知错误
    HGBMailListErrorFailed=99//失败
};


@class HGBMailListTool;
@protocol HGBMailListToolDelegate<NSObject>
@optional
/**
 获取全部联系人

 @param mailList 通讯簿工具
 @param mailArray 联系人集合
 */
- (void)mailList:(HGBMailListTool *)mailList didSucessedWithMailArray:(NSArray *)mailArray;
/**
 打开获取选中联系人

 @param mailList 通讯簿工具
 @param mail 联系人
 */

- (void)mailList:(HGBMailListTool *)mailList didSucessedWithMail:(HGBMailModel *)mail;
/**
 获取通讯录失败

 @param mailList 通讯簿工具
 @param errorInfo  错误信息
 */
-(void)mailList:(HGBMailListTool *)mailList didFailedWithError:(NSDictionary *)errorInfo;

/**
 取消打开通讯录失败

 @param mailList 通讯簿工具
 */
-(void)mailListDidCanceled:(HGBMailListTool *)mailList;
/**
 创建联系人成功

 @param mailList 通讯簿工具
 */
-(void)mailListDidCreateItemSucessed:(HGBMailListTool *)mailList;
@end

@interface HGBMailListTool : NSObject
/**
 代理
 */
@property(strong,nonatomic)id<HGBMailListToolDelegate>delegate;
/**
 是否打开联系人详情进行选择联系方式
 */
@property(assign,nonatomic)BOOL isCanOpenMailDetails;
/**
 代理
 */
@property(strong,nonatomic)UIViewController *parent;
#pragma mark init
/**
 单例

 @return 实例
 */
+ (instancetype)shareInstance;
#pragma mark 功能
/**
 打开通讯录选择联系人

 @param parent 父控制器
 @param delegate 代理
 */
-(void)openMailListBookInParent:(UIViewController *)parent andWithDelegate:(id<HGBMailListToolDelegate>)delegate;

/**
 获取全部联系人

 @param delegate 代理
 */
-(void)getMailListWithDelegate:(id<HGBMailListToolDelegate>)delegate;
/**
 创建联系人

 @param name 联系人姓名
 @param phone 手机号
 @param delegate 代理
 */
-(void)creatItemWithName:(NSString *)name phone:(NSString *)phone andWithDelegate:(id<HGBMailListToolDelegate>)delegate;

@end
