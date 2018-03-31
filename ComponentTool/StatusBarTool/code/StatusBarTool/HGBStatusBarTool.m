//
//  HGBStatusBarTool.m
//  HelloCordova
//
//  Created by huangguangbao on 2017/12/21.
//

#import "HGBStatusBarTool.h"

@implementation HGBStatusBarTool
#pragma mark 状态栏
/**
 设置状态栏是否隐藏-info.plist UIViewControllerBasedStatusBarAppearance NO

 @param isHidden 是否隐藏
 */
+(void)setStatusBarIsHidden:(BOOL)isHidden{
    [[UIApplication sharedApplication]setStatusBarHidden:isHidden withAnimation:NO];

    UIViewController *controller=[HGBStatusBarTool currentViewController];

    [controller prefersStatusBarHidden];
    [controller setNeedsStatusBarAppearanceUpdate];
}

/**
 设置状态栏样式-info.plist UIViewControllerBasedStatusBarAppearance NO

 @param statusBarStyle 状态栏样式
 */
+(void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle{

    [[UIApplication sharedApplication]setStatusBarStyle:statusBarStyle];
    UIViewController *controller=[HGBStatusBarTool currentViewController];

    [controller setNeedsStatusBarAppearanceUpdate];


}
#pragma mark 获取当前控制器

/**
 获取当前控制器

 @return 当前控制器
 */
+ (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [HGBStatusBarTool findBestViewController:viewController];
}

/**
 寻找上层控制器

 @param vc 控制器
 @return 上层控制器
 */
+ (UIViewController *)findBestViewController:(UIViewController *)vc
{
    if (vc.presentedViewController) {
        // Return presented view controller
        return [HGBStatusBarTool findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBStatusBarTool findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBStatusBarTool findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBStatusBarTool findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        return vc;
    }
}
@end
