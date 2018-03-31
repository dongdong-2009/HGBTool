//
//  HGBSafariTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/2/4.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

@interface HGBSafariTool : NSObject

/**
 打开url

 @param url url
 @return 结果
 */
+(BOOL)openURL:(NSString *)url;
/**
 添加书签

 @param title 标题
 @param prompt 描述
 @param url url
 @return 结果
 */
+(BOOL)addBookmarkWithTitle:(NSString *)title andWithPrompt:(NSString *)prompt andWithURL:(NSString *)url;
@end
