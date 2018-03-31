
//
//  HGBPasteboardTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/25.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBPasteboardTool.h"
#import <UIKit/UIKit.h>
@implementation HGBPasteboardTool
/**
 将数据放到粘贴板

 @param src 数据源
 @return 结果
 */
+(BOOL)pasteSource:(id)src{
     UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    if([src isKindOfClass:[NSString class]]){
         pboard.string = (NSString *)src;
    }else if ([src isKindOfClass:[NSArray<NSString *> class]]){
        pboard.strings=(NSArray<NSString *>  *)src;
    }else if([src isKindOfClass:[NSURL class]]){
        pboard.URL = (NSURL *)src;
    }else if ([src isKindOfClass:[NSArray<NSURL *> class]]){
        pboard.URLs=(NSArray<NSURL *>  *)src;
    }else if([src isKindOfClass:[UIImage class]]){
        pboard.image = (UIImage *)src;
    }else if ([src isKindOfClass:[NSArray<UIImage *> class]]){
        pboard.images=(NSArray<UIImage *>  *)src;
    }else if([src isKindOfClass:[UIColor class]]){
        pboard.color = (UIColor *)src;
    }else if ([src isKindOfClass:[NSArray<UIColor *> class]]){
        pboard.colors=(NSArray<UIColor *>  *)src;
    }else{
        return NO;
    }
    return YES;
}
/**
 获取粘贴板内容

 @return 粘贴板内容
 */
+(NSDictionary *)getPasteboardSource{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    if(pboard.string){
        [dic setObject:pboard.string forKey:@"string"];
    }else if(pboard.strings){
        [dic setObject:pboard.strings forKey:@"strings"];
    }else if(pboard.URL){
        [dic setObject:pboard.URL forKey:@"url"];
    }else if(pboard.URLs){
        [dic setObject:pboard.URLs forKey:@"urls"];
    }else if(pboard.image){
        [dic setObject:pboard.image forKey:@"image"];
    }else if(pboard.images){
        [dic setObject:pboard.URL forKey:@"images"];
    }else if(pboard.color){
        [dic setObject:pboard.URL forKey:@"color"];
    }else if(pboard.colors){
        [dic setObject:pboard.colors forKey:@"colors"];
    }
    return dic;
}
@end
