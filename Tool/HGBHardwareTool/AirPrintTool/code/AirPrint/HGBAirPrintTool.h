//
//  HGBAirPrintTool.h
//  测试
//
//  Created by huangguangbao on 2018/1/3.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
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



@class HGBAirPrintTool;

/**
 错误类型
 */
typedef enum HGBAirPrintToolError
{
    HGBAirPrintToolErrorParams=0,//参数错误
    HGBAirPrintToolErrorDevice=10,//设备错误
    HGBAirPrintToolErrorPrint=99//打印错误

}HGBAirPrintToolError;




@protocol HGBAirPrintToolDelegate <NSObject>

@optional

/**
 打印成功

 @param print 打印工具
 */
- (void)printDidSucessed:(HGBAirPrintTool*)print;

/**
 取消打印

 @param print 打印工具
 */
- (void)printDidCanceled:(HGBAirPrintTool*)print;



/**
 打印工具出错

 @param print 打印工具
 @param errorInfo 错误信息
 */
- (void)print:(HGBAirPrintTool*)print didFailedWithError:(NSDictionary *)errorInfo;

/**
 打开打印设置

 @param print 打印工具
 */
- (void)printDidOpenPrintSet:(HGBAirPrintTool*)print;

/**
 关闭打印设置

 @param print 打印工具
 */
- (void)printDidClosePrintSet:(HGBAirPrintTool*)print;
/**
 打印开始

 @param print 打印工具
 */
- (void)printDidStart:(HGBAirPrintTool*)print;

/**
打印结束

 @param print 打印工具
 */
- (void)printDidFinished:(HGBAirPrintTool*)print;
@end

@interface HGBAirPrintTool : NSObject
/**
 代理
 */
@property(strong,nonatomic)id<HGBAirPrintToolDelegate> delegate;
/**
 打印按钮
 */
@property(strong,nonatomic)UIBarButtonItem *printButtonItem;
/**
 打印id
 */
@property(strong,nonatomic)NSString *printID;
/**
 打印标题
 */
@property(strong,nonatomic)NSString *title;
/**
 打印方向
 */
@property(assign,nonatomic)UIPrintInfoOrientation orientation;
/**
 打印输出类型
 */
@property(assign,nonatomic)UIPrintInfoOutputType outType;
/**
 打印样式
 */
@property(assign,nonatomic)UIPrintInfoDuplex duplex;
/**
 是否显示页面范围
 */
@property(assign,nonatomic)BOOL isShowPages;
/**
 是否显示页面
 */
@property(assign,nonatomic)BOOL isShowPage;
#pragma mark init

+ (instancetype)shareInstance;
#pragma mark 功能
/**
 打印文件

 @param source 数据源  View(UIWebView) NSString（url或path）NSData, NSURL, UIImage,   Array(array of NSString（url或path） NSData, NSURL, UIImage, )
 */
-(void)printWithSource:(id)source;

/**
 打印对象

 @param object 数据源   NSData, NSURL, UIImage
 */
-(void)printWithObject:(id)object;

/**
 打印数据

 @param data 数据
 */
-(void)printWithData:(NSData *)data;

/**
 打印view页面

 @param view view
 */
-(void)printWithView:(UIView *)view;
@end

