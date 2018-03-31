//
//  HGBControllerJumpTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/12/22.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBControllerJumpTool.h"

@implementation HGBControllerJumpTool
#pragma mark Present- Dismiss
/**
 模态视图推出-有导航栏

 @param controller 控制器
 */
+(void)presentControllerWithNavgation:(UIViewController *)controller{
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:controller];
    [[HGBControllerJumpTool currentViewController] presentViewController:nav animated:YES completion:nil];
}


/**
 模态视图推出-无导航栏

 @param controller 控制器
 */
+(void)presentController:(UIViewController *)controller{

    [[HGBControllerJumpTool currentViewController] presentViewController:controller animated:YES completion:nil];
}

/**
 返回到上一级控制器
 */
+(void)dismissToParentViewController{
    UIViewController *vc = [HGBControllerJumpTool currentViewController];
    [vc dismissViewControllerAnimated:YES completion:nil];
}
/**
 返回到根控制器
 */
+(void)dismissToRootViewController
{
    UIViewController *vc = [HGBControllerJumpTool currentViewController];
    while (vc.presentingViewController) {
        vc = vc.presentingViewController;
    }
    [vc dismissViewControllerAnimated:YES completion:nil];
}
/**
 返回到指定控制器

 @param controllerName 控制器名称
 */
+(void)dismissToControllerWithControllerName:(NSString *)controllerName{
    UIViewController *vc = [HGBControllerJumpTool currentViewController];
    UIViewController *vcc=[HGBControllerJumpTool currentViewController];
    while (vc.presentingViewController) {
        NSArray *controllers;
        if([vc.presentingViewController isKindOfClass:[UINavigationController class]]){
            UINavigationController *nav=(UINavigationController *)vc.presentingViewController;
            controllers=nav.childViewControllers;

        }
        BOOL breakFlag=NO;
        for(UIViewController *c in controllers){
            NSString *cName=[NSStringFromClass([c class]) copy];
            if([controllerName isEqualToString:cName]){
                breakFlag=YES;
                [vcc dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            vcc = c;

        }
        if(breakFlag==YES){
            vc=vcc;
            break;
        }
        if([controllerName isEqualToString:NSStringFromClass([vc.presentingViewController class])]){
            vc = vc.presentingViewController;
            [vc dismissViewControllerAnimated:YES completion:nil];

            break;
        }
        vc = vc.presentingViewController;

    }
}
/**
 返回指定次数

 @param count 返回层数
 */
+(void)dismissToControllerWithDismissCount:(NSInteger)count{
    int i=0;
    UIViewController *vc = [HGBControllerJumpTool currentViewController];
    if(count==0){
        return;
    }else if(count==1){
        [vc dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    while (vc.presentingViewController) {
        if(i>=count){
            break;
        }
        vc = vc.presentingViewController;
        i++;
    }

    [vc dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark Push-Pop
/**
 视图推出

 @param controller 控制器
 */
+(void)pushController:(UIViewController *)controller{
    [[HGBControllerJumpTool currentViewController].navigationController pushViewController:controller animated:YES];
}

/**
 返回到上一层控制器
 */
+(void)popToParentViewController{
    UIViewController *vc = [HGBControllerJumpTool currentViewController];
    [vc.navigationController popViewControllerAnimated:YES];
}
/**
 返回到根层视图控制器
 */
+(void)popToRootViewController{
    UIViewController *vc = [HGBControllerJumpTool currentViewController];
    [vc.navigationController popToRootViewControllerAnimated:YES];
}

/**
 返回到指定层控制器

 @param controllerName 控制器名称
 */
+(void)popToControllerWithControllerName:(NSString *)controllerName{
    UIViewController *vc = [HGBControllerJumpTool currentViewController];
    if(controllerName==nil||controllerName.length==0){
        return;
    }
    if(![vc.parentViewController isKindOfClass:[UINavigationController class]]){
        return;
    }
    NSArray *controllers=[HGBControllerJumpTool currentViewController].navigationController.viewControllers;
    NSInteger n=0;
    for(UIViewController *v in controllers){
        if([NSStringFromClass([v class]) isEqualToString:controllerName]){
            n=[controllers indexOfObject:v];
            break;
        }
    }

    for(long i=controllers.count-1;i>n;i--){
        UIViewController *vc=controllers[i];
        [vc.navigationController popViewControllerAnimated:YES];
    }

}

/**
 返回指定次数

 @param count 返回层数
 */
+(void)popToControllerWithPopCount:(NSInteger)count{
    UIViewController *vc = [HGBControllerJumpTool currentViewController];
    if(![vc.parentViewController isKindOfClass:[UINavigationController class]]){
        return;
    }
    NSArray *controllers=[HGBControllerJumpTool currentViewController].navigationController.viewControllers;
    for(long i=count;i>0;i--){
        UIViewController *vc=controllers[i];
        [vc.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark 获取当前控制器
/**
 获取当前控制器

 @return 当前控制器
 */
+ (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [HGBControllerJumpTool findBestViewController:viewController];
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
        return [HGBControllerJumpTool findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBControllerJumpTool findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBControllerJumpTool findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBControllerJumpTool findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}
@end
