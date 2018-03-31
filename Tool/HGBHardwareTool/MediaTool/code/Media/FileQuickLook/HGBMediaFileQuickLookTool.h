//
//  HGBMediaFileQuickLookTool.h
//  测试
//
//  Created by huangguangbao on 2017/8/23.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

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
@class HGBMediaFileQuickLookTool;
/**
 快速预览
 */
@protocol HGBMediaFileQuickLookToolDelegate <NSObject>
@optional
/**
 打开成功

 @param quickLook quickLook
 */
-(void)quickLookDidOpenSucessed:(HGBMediaFileQuickLookTool *)quickLook;
/**
 打开失败

 @param quickLook quickLook
 */
-(void)quickLookDidOpenFailed:(HGBMediaFileQuickLookTool *)quickLook;
/**
 关闭快速预览

 @param quickLook quickLook
 */
-(void)quickLookDidClose:(HGBMediaFileQuickLookTool *)quickLook;

@end
@interface HGBMediaFileQuickLookTool : NSObject
#pragma mark 设置
/**
 设置代理

 @param delegate 代理
 */
+(void)setQuickLookDelegate:(id<HGBMediaFileQuickLookToolDelegate>)delegate;
/**
 设置失败提示

 @param withoutFailPrompt 失败提示标志
 */
+(void)setQuickLookWithoutFailPrompt:(BOOL)withoutFailPrompt;
#pragma mark 打开文件

/**
 快速浏览文件

 @param source 路径或url
 @param parent 父控制器
 */
+(void)lookFileAtSource:(NSString *)source inParent:(UIViewController *)parent;
@end
