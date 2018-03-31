//
//  HGBSizeTool.m
//  尺寸
//
//  Created by huangguangbao on 2017/6/7.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBSizeTool.h"
#import <UIKit/UIKit.h>

#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@implementation HGBSizeTool
#pragma mark 获取字符串宽高
/**
 @method 获取指定宽度情况ixa，字符串value的高度
 @param value 待计算的字符串
 @param fontSize 字体的大小
 @param width 限制字符串显示区域的宽度
 @result float 返回的高度
 */
+ (CGFloat)heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width
{
    if(value==nil){
        HGBLog(@"字符串为空");
        return 0;
    }
    CGRect r = [value boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]} context:nil];
    return r.size.height;
}
/**
 @method 获取指定高度情况ixa，字符串value的高度
 @param value 待计算的字符串
 @param fontSize 字体的大小
 @param height 限制字符串显示区域的高度
 @result float 返回的宽度
 */
+ (CGFloat)widthForString:(NSString *)value fontSize:(float)fontSize andheight:(float)height{
    if(value==nil){
        HGBLog(@"字符串为空");
        return 0;
    }
    CGRect r = [value boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]} context:nil];
    return r.size.width;
}
@end
