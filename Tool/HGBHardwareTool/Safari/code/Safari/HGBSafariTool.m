//
//  HGBSafariTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/2/4.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBSafariTool.h"
#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <SafariServices/SafariServices.h>

#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

@implementation HGBSafariTool
/**
 打开url

 @param url url
 @return 结果
 */
+(BOOL)openURL:(NSString *)url{
    if(url==nil){
        return NO;
    }
    NSURL *openURL=[NSURL URLWithString:url];
    if([[UIApplication sharedApplication]canOpenURL:openURL]){
        return  [[UIApplication sharedApplication]openURL:openURL];
    }else{
        return NO;
    }
}
/**
 添加书签

 @param title 标题
 @param prompt 描述
 @param url url
 @return 结果
 */
+(BOOL)addBookmarkWithTitle:(NSString *)title andWithPrompt:(NSString *)prompt andWithURL:(NSString *)url{
    NSURL *saveURL = [NSURL URLWithString:url];
    if(url==nil){
        return NO;
    }
    NSError *error;
    BOOL result = [[SSReadingList defaultReadingList] addReadingListItemWithURL:saveURL title:title previewText:prompt  error:&error];
    if(error){
        HGBLog(@"%@",error);
        return NO;
    }
    return result;
}
@end
