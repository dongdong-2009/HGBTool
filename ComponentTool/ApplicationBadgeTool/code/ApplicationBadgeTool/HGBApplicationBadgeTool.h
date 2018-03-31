//
//  HGBApplicationBadgeTool.h
//  HelloCordova
//
//  Created by huangguangbao on 2017/12/21.
//

#import <Foundation/Foundation.h>

@interface HGBApplicationBadgeTool : NSObject
#pragma mark 应用角标
/**
 获取应用角标

 @return  应用角标
 */
+(NSInteger)getApplicationBadge;
/**
 设置应用角标

 @param badge 角标
 */
+(void)setApplicationBadge:(NSInteger)badge;

/**
 应用角标+1
 */
+(void)addApplicationBadge;
/**
 应用角标-1
 */
+(void)reduceApplicationBadge;
/**
 应用角标添加
 @param number 角标加的数目
 */
+(void)addApplicationBadgeWithNumber:(NSInteger)number;
/**
 应用角标隐藏

 */
+(void)hideApplicationBadge;
@end
