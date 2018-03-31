//
//  HGBWaterMarkTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/3/16.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

@interface HGBWaterMarkTool : NSObject
#pragma mark 为图片加图片水印
/**
 图片加图片水印

 @param baseImage 基础图片
 @param image 图片
 @param imageRect 图片对应位置
 @return 组合后图片
 */
+(UIImage *)imageDrawWithBaseImage:(UIImage *)baseImage andWithImage:(UIImage *)image andWithImageRect:(CGRect)imageRect;
#pragma mark 为图片加文字水印
/**
 图片加文字水印

 @param baseImage 基础图片
 @param text 文字
 @param imageRect 图片对应位置
 @param color 水印颜色集合
 @param font 字体
 @return 组合后图片
 */
+(UIImage *)imageDrawWithBaseImage:(UIImage *)baseImage andWithText:(NSString *)text andWithImageRect:(CGRect)imageRect andWithColor:(UIColor *)color andWithFont:(UIFont *)font;

//#pragma mark 为视频加图片水印
///**
// 视频加图片水印
//
// @param source 视频路径
// @param image 图片
// @param imageRect 图片对应位置
// @return 组合后图片
// */
//+(NSString *)videoDrawWithVideoSource:(NSString *)source andWithImage:(UIImage *)image andWithImageRect:(CGRect)imageRect;
//#pragma mark 为视频加文字水印
///**
// 视频加文字水印
//
// @param source 视频路径
// @param text 文字
// @param imageRect 图片对应位置
// @param color 水印颜色集合
// @param font 字体
// @return 组合后图片
// */
//+(NSString *)videoDrawWithVideoSource:(NSString *)source andWithText:(NSString *)text andWithImageRect:(CGRect)imageRect andWithColor:(UIColor *)color andWithFont:(UIFont *)font;


#pragma mark color
/**
 十六进制色值转为颜色

 @param hexString 色值
 @return color
 */
+ (UIColor *)ColorWithHexString:(NSString *)hexString;
@end
