//
//  HGBTabBarBadgeTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/12/22.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBTabBarBadgeTool.h"
#import "UITabBar+HGBTabBar.h"
#import <UIKit/UIKit.h>

@interface HGBTabBarBadgeTool ()
/**
 角标文字颜色
 */
@property(strong,nonatomic)UIColor *badgeTextColor;
/**
 角标颜色
 */
@property(strong,nonatomic)UIColor *badgeColor;
/**
 标记点颜色颜色
 */
@property(strong,nonatomic)UIColor *pointColor;
@end

@implementation HGBTabBarBadgeTool
static HGBTabBarBadgeTool *instance=nil;
/**
 单例
 */
+(instancetype)shareInstance{
    if(instance==nil){
        instance=[[HGBTabBarBadgeTool alloc]init];
    }
    return instance;
}
#pragma mark tableBar标记点
/**
 tabBar添加标记点

 @param controller controller
 */
-(void)addPointInController:(UIViewController *)controller{
    NSInteger index=0;
    for(UIViewController  *vc in controller.tabBarController.viewControllers){
        UIViewController *baseVC;
        if([vc isKindOfClass:[UINavigationController class]]){
            baseVC=vc.childViewControllers[0];
        }else{
            baseVC=vc;
        }
        if(baseVC==controller){
            break;
        }
        index++;
    }


    [controller.tabBarController.tabBar showBadgeOnItemIndex:index andWithColor:self.pointColor andWithTabItemsCount:controller.tabBarController.viewControllers.count];
}
/**
 设置tabBar提示点颜色

 @param pointColor 角标颜色
 @param controller controller
 */
-(void)setTabBarPointColor:(UIColor *)pointColor inController:(UIViewController *)controller{
    self.pointColor=pointColor;
}
/**
 tabBar标记点隐藏

 @param controller controller
 */
-(void)hideTabBarPointInController:(UIViewController *)controller{
  

    NSInteger index=0;
    for(UIViewController  *vc in controller.tabBarController.viewControllers){
        UIViewController *baseVC;
        if([vc isKindOfClass:[UINavigationController class]]){
            baseVC=vc.childViewControllers[0];
        }else{
            baseVC=vc;
        }
        if(baseVC==controller){
            break;
        }
        index++;
    }
    [controller.tabBarController.tabBar hideBadgeOnItemIndex:index];

}
#pragma mark tableBar角标
/**
 获取tabBar角标

 @param controller controller
 @return tabBar角标
 */

-(NSString *)getTabBarBadgeInController:(UIViewController *)controller{
     NSString *bage=controller.tabBarItem.badgeValue;
    return bage;
}
/**
 设置tabBar角标

 @param badge 角标
 @param controller controller
 */
-(void)setTabBarBadge:(NSString *)badge inController:(UIViewController *)controller{

    UITabBarItem *item = controller.tabBarItem;
    NSInteger index=0;

    for(UIViewController  *vc in controller.tabBarController.viewControllers){
        UIViewController *baseVC;
        if([vc isKindOfClass:[UINavigationController class]]){
            baseVC=vc.childViewControllers[0];
        }else{
            baseVC=vc;
        }
        if(baseVC==controller){
            break;
        }
        index++;
    }
    [item setBadgeValue:badge];

    [controller.tabBarController.tabBar showBadgeOnItemIndex:index andWithText:badge andWithTextColor:self.badgeTextColor andWithBackColor:self.badgeColor andWithTabItemsCount:controller.tabBarController.viewControllers.count];

}
/**
 tabBar角标+1

 @param controller controller
 */
-(void)addTabBarBadgeInController:(UIViewController *)controller{
    //    UITabBarItem *item = controller.tabBarItem;


    NSString *bage=controller.tabBarItem.badgeValue;
    NSInteger bageNum=bage.integerValue;
    bageNum++;
    bage=@(bageNum).stringValue;
    controller.tabBarItem.badgeValue=bage;


    NSInteger index=0;
    for(UIViewController  *vc in controller.tabBarController.viewControllers){
        UIViewController *baseVC;
        if([vc isKindOfClass:[UINavigationController class]]){
            baseVC=vc.childViewControllers[0];
        }else{
            baseVC=vc;
        }
        if(baseVC==controller){
            break;
        }
        index++;
    }
    [controller.tabBarController.tabBar showBadgeOnItemIndex:index andWithText:bage andWithTextColor:self.badgeTextColor andWithBackColor:self.badgeColor andWithTabItemsCount:controller.tabBarController.viewControllers.count];

}
/**
 tabBar角标-1

 @param controller controller
 */
-(void)reduceTabBarBadgeInController:(UIViewController *)controller{
    //    UITabBarItem *item = controller.tabBarItem;


    NSString *bage=controller.tabBarItem.badgeValue;
    NSInteger bageNum=bage.integerValue;

    if(bageNum>0){
        bageNum--;
    }
    bage=@(bageNum).stringValue;
    controller.tabBarItem.badgeValue=bage;



    NSInteger index=0;
    for(UIViewController  *vc in controller.tabBarController.viewControllers){
        UIViewController *baseVC;
        if([vc isKindOfClass:[UINavigationController class]]){
            baseVC=vc.childViewControllers[0];
        }else{
            baseVC=vc;
        }
        if(baseVC==controller){
            break;
        }
        index++;
    }
    if([bage isEqualToString:@"0"]){
        [self hideTabBarBadgeInController:controller];
        return;
    }
    [controller.tabBarController.tabBar showBadgeOnItemIndex:index andWithText:bage andWithTextColor:self.badgeTextColor andWithBackColor:self.badgeColor andWithTabItemsCount:controller.tabBarController.viewControllers.count];
}
/**
 tabBar角标增加

 @param number 增加的数目
 @param controller controller
 */
-(void)addTabBarBadgeWithNumber:(NSInteger)number InController:(UIViewController *)controller{
    //    UITabBarItem *item = controller.tabBarItem;

    NSString *bage=controller.tabBarItem.badgeValue;
    NSInteger bageNum=bage.integerValue;

    if(bageNum+number>=0){
        bageNum=bageNum+number;
    }else{
        bageNum=0;
    }
    bage=@(bageNum).stringValue;
    controller.tabBarItem.badgeValue=bage;



    NSInteger index=0;
    for(UIViewController  *vc in controller.tabBarController.viewControllers){
        UIViewController *baseVC;
        if([vc isKindOfClass:[UINavigationController class]]){
            baseVC=vc.childViewControllers[0];
        }else{
            baseVC=vc;
        }
        if(baseVC==controller){
            break;
        }
        index++;
    }
    if([bage isEqualToString:@"0"]){
        [self hideTabBarBadgeInController:controller];
        return;
    }
    [controller.tabBarController.tabBar showBadgeOnItemIndex:index andWithText:bage andWithTextColor:self.badgeTextColor andWithBackColor:self.badgeColor andWithTabItemsCount:controller.tabBarController.viewControllers.count];
}
/**
 tabBar角标隐藏

 @param controller controller
 */
-(void)hideTabBarBadgeInController:(UIViewController *)controller{
    //    UITabBarItem *item = controller.tabBarItem;

    NSInteger index=0;
    for(UIViewController  *vc in controller.tabBarController.viewControllers){
        UIViewController *baseVC;
        if([vc isKindOfClass:[UINavigationController class]]){
            baseVC=vc.childViewControllers[0];
        }else{
            baseVC=vc;
        }
        if(baseVC==controller){
            break;
        }
        index++;
    }
    [controller.tabBarController.tabBar hideBadgeOnItemIndex:index];
    controller.tabBarItem.badgeValue=nil;
}

/**
 设置tabBar角标颜色

 @param badgeColor 角标颜色
 @param controller controller
 */
-(void)setTabBarBadgeColor:(UIColor *)badgeColor inController:(UIViewController *)controller{

    self.badgeColor=badgeColor;
}

/**
 设置tabBar角标文字颜色

 @param badgeTextColor 角标文字颜色
 @param controller controller
 */
-(void)setTabBarBadgeTextColor:(UIColor *)badgeTextColor inController:(UIViewController *)controller{
    self.badgeTextColor=badgeTextColor;
}
#pragma mark 获取当前控制器

/**
 获取当前控制器

 @return 当前控制器
 */
+ (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [HGBTabBarBadgeTool findBestViewController:viewController];
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
        return [HGBTabBarBadgeTool findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBTabBarBadgeTool findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBTabBarBadgeTool findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBTabBarBadgeTool findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        return vc;
    }
}
@end
