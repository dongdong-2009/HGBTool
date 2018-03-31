//
//  HGBCopyViewTool.m
//  HelloCordova
//
//  Created by huangguangbao on 2017/12/21.
//

#import "HGBCopyViewTool.h"
#import <UIKit/UIKit.h>

@implementation HGBCopyViewTool
#pragma mark 组件复制
/**
 复制view
 */
+(UIView *)duplicateComponent:(UIView *)view
{
    if(view==nil){
        return nil;
    }
    NSData * tempArchive = [NSKeyedArchiver archivedDataWithRootObject:view];
    return [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
}
@end
