//
//  HGBWaterMarkTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/3/16.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBWaterMarkTool.h"

#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

@implementation HGBWaterMarkTool
#pragma mark 为图片加图片水印
/**
 图片加图片水印

 @param baseImage 基础图片
 @param image 图片
 @param imageRect 图片对应位置
 @return 组合后图片
 */
+(UIImage *)imageDrawWithBaseImage:(UIImage *)baseImage andWithImage:(UIImage *)image andWithImageRect:(CGRect)imageRect{
    // 开启绘图, 获取图片 上下文<图片大小>
    UIGraphicsBeginImageContext(baseImage.size);
    //将基础图片画上去
    [baseImage drawInRect:CGRectMake(0, 0, baseImage.size.width, baseImage.size.height)];

    // 将小图片画上去

    [image drawInRect:imageRect];

    // 获取最终的图片
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭上下文
    UIGraphicsEndImageContext();
    return finalImage;
}
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
+(UIImage *)imageDrawWithBaseImage:(UIImage *)baseImage andWithText:(NSString *)text andWithImageRect:(CGRect)imageRect andWithColor:(UIColor *)color andWithFont:(UIFont *)font{

    UIGraphicsBeginImageContext(baseImage.size);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();//创建颜色
    //创建上下文
    CGContextRef context=UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);

    CGContextSetStrokeColorWithColor(context,color.CGColor);



    CGContextSetTextDrawingMode(context, kCGTextFill);

    CGContextSetStrokeColorWithColor(context, color.CGColor);//线条颜色

    [baseImage drawInRect:CGRectMake(0, 0, baseImage.size.width, baseImage.size.height)];

    NSDictionary *attributes=@{NSFontAttributeName:font,NSBackgroundColorAttributeName: [UIColor clearColor],NSForegroundColorAttributeName:color};
    [text drawInRect:imageRect withAttributes:attributes];



    UIImage *finalImage=UIGraphicsGetImageFromCurrentImageContext();
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return finalImage;
}
#pragma mark color
/**
 十六进制色值转为颜色

 @param hexString 色值
 @return color
 */
+ (UIColor *)ColorWithHexString:(NSString *)hexString{
    if(hexString==nil){
        HGBLog(@"字符串不能为空");
        return nil;
    }
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red = [HGBWaterMarkTool colorComponentFrom:colorString start:0 length:1];
            green = [HGBWaterMarkTool colorComponentFrom:colorString start:1 length:1];
            blue = [HGBWaterMarkTool colorComponentFrom:colorString start:2 length:1];
            break;
        case 4: // #ARGB
            alpha = [HGBWaterMarkTool colorComponentFrom:colorString start:0 length:1];
            red = [HGBWaterMarkTool colorComponentFrom:colorString start:1 length:1];
            green = [HGBWaterMarkTool colorComponentFrom:colorString start:2 length:1];
            blue = [HGBWaterMarkTool colorComponentFrom:colorString start:3 length:1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red = [HGBWaterMarkTool colorComponentFrom:colorString start:0 length:2];
            green = [HGBWaterMarkTool colorComponentFrom:colorString start:2 length:2];
            blue = [HGBWaterMarkTool colorComponentFrom:colorString start:4 length:2];
            break;
        case 8: // #AARRGGBB
            alpha = [HGBWaterMarkTool colorComponentFrom:colorString start:0 length:2];
            red = [HGBWaterMarkTool colorComponentFrom:colorString start:2 length:2];
            green = [HGBWaterMarkTool colorComponentFrom:colorString start:4 length:2];
            blue = [HGBWaterMarkTool colorComponentFrom:colorString start:6 length:2];
            break;
        default:
            return nil;
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];

    return hexComponent / 255.0;
}

@end
