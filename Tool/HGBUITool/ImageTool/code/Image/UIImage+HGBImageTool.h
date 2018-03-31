//
//  UIImage+HGBImageTool.h
//  测试app
//
//  Created by huangguangbao on 2017/7/7.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 类型
 */
typedef enum HGBImageColorProcessingImageType
{
    HGBImageColorProcessingImageTypeWhiteAndBlack,//黑白图片
    HGBImageColorProcessingImageTypeDusk,//黄昏
    HGBImageColorProcessingImageTypeSnow,//雪
    HGBImageColorProcessingImageTypeOther//原图


}HGBImageColorProcessingImageType;


@interface UIImage (HGBImageTool)

#pragma mark  剪切图片
/**
 *   剪切图片
 *
 *  @param rect        剪切尺寸
 *
 *  return             剪切后图片
 */
-(UIImage*)cropImageWithRect:(CGRect)rect;
#pragma mark 图片尺寸变换
/**
 *   图片尺寸变换
 *
 *  @param scaleSize       变换比例
 *
 *  return             变换后图片
 */
- (UIImage *)configureImageWithScale:(CGFloat)scaleSize;
/**
 *   图片尺寸-将UIImage压缩到固定的宽度，高度也随之改变，而不变形
 *
 *
 *  @param width    图片宽度
 *
 *  return             变换后图片
 */
- (UIImage *)configureImageWithWidth:(CGFloat)width;

/**
 *   图片尺寸-将UIImage压缩到固定的宽度，高度也随之改变，而不变形
 *
 *  @param height    图片高度
 *  return             变换后图片
 */
- (UIImage *)configureImageWithHeight:(CGFloat)height;
#pragma mark 图片大小压缩
/**
 *   图片大小压缩
 *
 *  @param bytes   字节
 *  return             变换后图片
 */
-(UIImage *)configureWithBytes:(NSInteger)bytes;
/**
 *   图片大小压缩-不失真
 *
 *  @param bytes   字节

 *  return             变换后图片
 */
- (UIImage *)configureImageWithoutDistortWithBytes:(NSInteger)bytes;
#pragma mark  图片旋转
/**
 *   图片旋转
 *
 *  @param angle    变换角度
 *
 *  return             旋转后图片
 */
- (UIImage *)rotateImageWithAngle:(CGFloat)angle;
#pragma mark  获取圆形或椭圆图片
/**
 *   获取圆形或椭圆图片
 *
 *  return             旋转后图片
 */
- (UIImage *)getRoundImage;
#pragma mark  获取色彩处理图片
/**
 *   获取色彩处理图片
 *
 *  @param type    0 黑白图片
 *
 *  return             色彩处理后图片
 */
+ (UIImage *)getColorProcessingImageWithType:(HGBImageColorProcessingImageType )type;
#pragma mark 图片组合
/**
 图片组合
 @param images 图片集合
 @param imageRects 图片对应位置
 @return 组合后图片
 */
-(UIImage *)imageDrawdWithImages:(NSArray<UIImage *>*)images andWithImageRects:(NSArray<NSString *>*)imageRects;
#pragma mark  图片方向大小-根据屏幕方向
/**
 *   图片方向大小-根据屏幕方向
 *
 *  @param scaleSize       变换比例
 *
 *  return             旋转后图片
 */
-(UIImage *)rotateWithScale:(CGFloat)scaleSize;
#pragma mark 图片方向处理
/**
 拍照图片方向处理

 @return 图片
 */
-(UIImage *)fixOrientation;
@end
