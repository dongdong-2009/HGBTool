//
//  HGBOutAppOpenFileTool.h
//  HelloCordova
//
//  Created by huangguangbao on 2017/7/19.
//
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
typedef enum HGBOutAppOpenFileToolErrorType
{
    HGBOutAppOpenFileToolErrorTypePath=20//路径错误

}HGBOutAppOpenFileToolErrorType;

@class HGBOutAppOpenFileTool;

/**
 快速预览
 */
@protocol HGBOutAppOpenFileToolDelegate <NSObject>
@optional
/**
 打开成功

 @param outLook outLook
 */
-(void)outLookDidOpenSucessed:(HGBOutAppOpenFileTool *)outLook;
/**
 打开失败

 @param outLook outLook
 */
-(void)outLook:(HGBOutAppOpenFileTool *)outLook didOpenFailedWithError:(NSDictionary *)errorInfo;
/**
 取消快速预览

 @param outLook outLook
 */
-(void)outLookDidCanceled:(HGBOutAppOpenFileTool *)outLook;
/**
 关闭快速预览

 @param outLook outLook
 */
-(void)outLookDidClose:(HGBOutAppOpenFileTool *)outLook;

@end

@interface HGBOutAppOpenFileTool : NSObject
#pragma mark init
+(instancetype)shareInstance;
#pragma mark 设置
/**
 代理
 */
@property(assign,nonatomic)id<HGBOutAppOpenFileToolDelegate>delegate;
/**
 失败提示
 */
@property(assign,nonatomic)BOOL withoutFailPrompt;
#pragma mark open



/**
 快速浏览文件

 @param source 路径或url
 @param parent 父控制器
 */
-(void)lookFileAtSource:(NSString *)source inParent:(UIViewController *)parent;
@end

