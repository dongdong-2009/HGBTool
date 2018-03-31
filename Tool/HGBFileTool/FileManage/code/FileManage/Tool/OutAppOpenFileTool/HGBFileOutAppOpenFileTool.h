//
//  HGBFileOutAppOpenFileTool.h
//  测试
//
//  Created by huangguangbao on 2017/8/16.
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

/**
 错误类型
 */
typedef enum HGBFileOutAppOpenFileToolErrorType
{
    HGBFileOutAppOpenFileToolErrorTypePath=20//路径错误

}HGBFileOutAppOpenFileToolErrorType;

@class HGBFileOutAppOpenFileTool;

/**
 快速预览
 */
@protocol HGBFileOutAppOpenFileToolDelegate <NSObject>
@optional
/**
 打开成功

 @param outLook outLook
 */
-(void)outLookDidOpenSucessed:(HGBFileOutAppOpenFileTool *)outLook;
/**
 打开失败

 @param outLook outLook
 */
-(void)outLook:(HGBFileOutAppOpenFileTool *)outLook didOpenFailedWithError:(NSDictionary *)errorInfo;
/**
 取消快速预览

 @param outLook outLook
 */
-(void)outLookDidCanceled:(HGBFileOutAppOpenFileTool *)outLook;
/**
 关闭快速预览

 @param outLook outLook
 */
-(void)outLookDidClose:(HGBFileOutAppOpenFileTool *)outLook;

@end


@interface HGBFileOutAppOpenFileTool : NSObject
/**
 失败提示
 */
@property(assign,nonatomic)BOOL withoutFailPrompt;

/**
 代理
 */
@property(assign,nonatomic)id<HGBFileOutAppOpenFileToolDelegate>delegate;
#pragma mark init
+(instancetype)shareInstance;
#pragma mark open



/**
 快速浏览文件

 @param source 路径或url
 @param parent 父控制器
 */
-(void)lookFileAtSource:(NSString *)source inParent:(UIViewController *)parent;
@end
