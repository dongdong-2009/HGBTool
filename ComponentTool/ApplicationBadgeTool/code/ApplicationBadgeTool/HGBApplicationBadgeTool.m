//
//  HGBApplicationBadgeTool.m
//  HelloCordova
//
//  Created by huangguangbao on 2017/12/21.
//

#import "HGBApplicationBadgeTool.h"
#import <UIKit/UIKit.h>
@implementation HGBApplicationBadgeTool
#pragma mark 应用角标
/**
 设置应用角标

 @param badge 角标
 */
+(void)setApplicationBadge:(NSInteger )badge{
    [UIApplication sharedApplication].applicationIconBadgeNumber=badge;
}
/**
 应用角标+1
 */
+(void)addApplicationBadge{
    NSInteger badge=[UIApplication sharedApplication].applicationIconBadgeNumber;
    badge++;
    [UIApplication sharedApplication].applicationIconBadgeNumber=badge;
}
/**
 应用角标-1
 */
+(void)reduceApplicationBadge{
    NSInteger badge=[UIApplication sharedApplication].applicationIconBadgeNumber;
    if(badge>0){
        badge--;
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber=badge;
}
/**
 应用角标添加
 @param number 角标加的数目
 */
+(void)addApplicationBadgeWithNumber:(NSInteger)number{
    NSInteger badge=[UIApplication sharedApplication].applicationIconBadgeNumber;
    if(badge+number>=0){
        badge=badge+number;
    }else{
        badge=0;
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber=badge;

}
/**
 应用角标隐藏

 */
+(void)hideApplicationBadge{
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
}
/**
 获取应用角标

 @return  应用角标
 */
+(NSInteger)getApplicationBadge{
    return [UIApplication sharedApplication].applicationIconBadgeNumber;
}
@end
