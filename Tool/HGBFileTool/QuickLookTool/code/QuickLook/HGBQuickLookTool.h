//
//  HGBQuickLookTool.h
//  测试
//
//  Created by huangguangbao on 2017/8/13.
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


/**
 错误类型
 */
typedef enum HGBQuickLookToolErrorType
{
    HGBQuickLookToolErrorTypePath=20//路径错误

}HGBQuickLookToolErrorType;

@class HGBQuickLookTool;
/**
 快速预览
 */
@protocol HGBQuickLookToolDelegate <NSObject>
@optional
/**
 打开成功

 @param quickLook quickLook
 */
-(void)quickLookDidOpenSucessed:(HGBQuickLookTool *)quickLook;
/**
 打开失败

 @param quickLook quickLook
 */
-(void)quickLook:(HGBQuickLookTool *)quickLook didOpenFailedWithError:(NSDictionary *)errorInfo;
/**
 关闭快速预览

 @param quickLook quickLook
 */
-(void)quickLookDidClose:(HGBQuickLookTool *)quickLook;

@end

@interface HGBQuickLookTool : NSObject
/**
 代理
 */
@property(assign,nonatomic)id<HGBQuickLookToolDelegate>delegate;
/**
 失败提示
 */
@property(assign,nonatomic)BOOL withoutFailPrompt;

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
