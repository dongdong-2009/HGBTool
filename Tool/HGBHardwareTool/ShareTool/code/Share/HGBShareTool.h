//
//  HGBShareTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/2/3.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//快捷url提示
/**
 project://工程包内
 home://沙盒路径
 http:// https://网络路径
 document://沙盒Documents文件夹
 caches://沙盒Caches
 tmp://沙盒Tmp文件夹

 */

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif




/**
 错误类型
 */
typedef enum HGBShareErrorType
{
    HGBShareErrorTypeParams=0,//参数错误
    HGBShareErrorTypeError=99,//错误
    HGBShareErrorTypeAccount=14,//设备受限
    HGBShareErrorTypeCancel=2//取消

}HGBShareErrorType;

/**
 分享类型
 */
typedef enum HGBSLShareType
{
    HGBSLShareTypeTwitter,//Twitter
    HGBSLShareTypeFacebook,//Facebook
     HGBSLShareTypeSinaWeibo,//SinaWeibo
     HGBSLShareTypeTencentWeibo,//TencentWeibo
    HGBSLShareTypeLinkedIn//LinkedIn

}HGBSLShareType;



/**
 结果

 @param status 状态
 @param returnMessage 信息
 */
typedef void (^HGBShareReslutBlock)(BOOL status,NSDictionary *returnMessage);

@interface HGBShareTool : NSObject
/**
 分享

 @param source 数据 //可以 UIImage NSString NSURL NSData  NSAttributedString  或以上组成的数组
 @param parent 父控制器
 @param result 结果
 @return 结果
 */
+(BOOL)shareSource:(id)source inParent:(UIViewController *)parent andWithResult:(HGBShareReslutBlock)result;
/**
 分享

 @param title 标题
 @param url url
 @param image 图片
 @param parent 父控制器
 @param result 结果
 @return 结果
 */
+(BOOL)shareWithTitle:(NSString *)title andWithURL:(NSString *)url andWithImage:(UIImage *)image inParent:(UIViewController *)parent andWithResult:(HGBShareReslutBlock)result;
/**
 添加书签

 @param title 标题
 @param prompt 描述
 @param url url
 @return 结果
 */
+(BOOL)shareToSafariBookmarkWithTitle:(NSString *)title andWithPrompt:(NSString *)prompt andWithURL:(NSString *)url;
/**
 系统分享

 @param shareType 分享类型
 @param title 分享文字
 @param images 分享图片集合
 @param urls 分享url集合
 @param parent 父控制器
 @param result 结果
 @return 结果
 */
+(BOOL)slshareWithShareType:(HGBSLShareType)shareType andWithTitle:(NSString *)title andWithImages:(NSArray <UIImage *>*)images andWithURLs:(NSArray <NSString *>*)urls inParent:(UIViewController *)parent andWithResult:(HGBShareReslutBlock)result;
@end
