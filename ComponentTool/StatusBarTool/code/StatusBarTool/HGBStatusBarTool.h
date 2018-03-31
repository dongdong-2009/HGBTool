//
//  HGBStatusBarTool.h
//  HelloCordova
//
//  Created by huangguangbao on 2017/12/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HGBStatusBarTool : NSObject
#pragma mark 状态栏
/**
 设置状态栏是否隐藏-info.plist UIViewControllerBasedStatusBarAppearance NO

 @param isHidden 是否隐藏
 */
+(void)setStatusBarIsHidden:(BOOL)isHidden;

/**
 设置状态栏样式-info.plist UIViewControllerBasedStatusBarAppearance NO

 @param statusBarStyle 状态栏样式
 */
+(void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle;
@end
