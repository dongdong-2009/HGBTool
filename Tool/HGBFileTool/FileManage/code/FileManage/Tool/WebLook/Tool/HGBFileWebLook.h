//
//  HGBFileWebLook.h
//  测试
//
//  Created by huangguangbao on 2017/8/17.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

//快捷url提示
/**
 project://工程包内
 home://沙盒路径
 http:// https://网络路径
 document://  或defaults://沙盒Documents文件夹
 caches://沙盒Caches
 tmp://沙盒Tmp文件夹

 */

@class HGBFileWebLook;
/**
 快速预览
 */
@protocol HGBFileWebLookToolDelegate <NSObject>
@optional
/**
 打开成功

 @param webLook quickLook
 */
-(void)webLookDidOpenSucessed:(HGBFileWebLook *)webLook;
/**
 打开失败

 @param webLook quickLook
 */
-(void)webLookDidOpenFailed:(HGBFileWebLook *)webLook;
/**
 关闭快速预览

 @param webLook quickLook
 */
-(void)webLookDidClose:(HGBFileWebLook *)webLook;

@end
@interface HGBFileWebLook : NSObject

/**
 失败提示
 */
@property(assign,nonatomic)BOOL withoutFailPrompt;
/**
 代理
 */
@property(assign,nonatomic)id<HGBFileWebLookToolDelegate>delegate;
#pragma mark init
+ (instancetype)shareInstance;
#pragma mark 打开文件


/**
 快速浏览文件

 @param source 路径或url
 @param parent 父控制器
 */
-(void)lookFileAtSource:(NSString *)source inParent:(UIViewController *)parent;
@end
