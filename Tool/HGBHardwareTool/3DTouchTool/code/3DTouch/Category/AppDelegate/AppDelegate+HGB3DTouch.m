//
//  AppDelegate+HGB3DTouch.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/28.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "AppDelegate+HGB3DTouch.h"
#import "HGB3DTouchTool.h"
@implementation AppDelegate (HGB3DTouch)
/**
 3DTouch初始化

 @param launchOptions 加载参数
 */
-(void)init_3DTouch_ServerWithOptions:(NSDictionary *)launchOptions{
    if (TARGET_IPHONE_SIMULATOR) {
        return;
    }
    UIApplicationShortcutItem *shortcutItem = [launchOptions valueForKey:UIApplicationLaunchOptionsShortcutItemKey];
    if (shortcutItem) {
        [[HGB3DTouchTool shareInstance] sendAppIcon3DTocuhMessageWith3DTouchType:HGB3DTouchTypeIconLanuch andWithTitle:shortcutItem.localizedTitle andWithSubTitle:shortcutItem.localizedSubtitle andWithType:shortcutItem.type andWithUserInfo:shortcutItem.userInfo];
    }
    [HGB3DTouchTool shareInstance].monitorReslut = ^(HGB3DTouchType touchType, NSString *title, NSString *subTitle, NSString *type, NSDictionary *userInfo) {
        if([title isEqualToString:@"主页"]){
            NSLog(@"主页");
        }else if ([title isEqualToString:@"组件"]){
            NSLog(@"组件");
        }else if ([title isEqualToString:@"工具"]){
            NSLog(@"工具");
        }
    };

    HGBAppIcon3DTouchModel *model1=[HGBAppIcon3DTouchModel instanceWithTitle:@"主页" andWithType:@"page" andWithSubTitle:nil   andWithIcon:nil andWithSystemIcon:(UIApplicationShortcutIconTypeHome) andwithUserInfo:nil];
    HGBAppIcon3DTouchModel *model2=[HGBAppIcon3DTouchModel instanceWithTitle:@"组件" andWithType:@"page" andWithSubTitle:nil   andWithIcon:nil andWithSystemIcon:(UIApplicationShortcutIconTypeBookmark) andwithUserInfo:nil];
    HGBAppIcon3DTouchModel *model3=[HGBAppIcon3DTouchModel instanceWithTitle:@"工具" andWithType:@"page" andWithSubTitle:nil   andWithIcon:@"3DTouchBundle.bundle/favorite.png" andWithSystemIcon:(UIApplicationShortcutIconTypeFavorite) andwithUserInfo:nil];
    NSArray *items=@[model1,model2,model3];
    [[HGB3DTouchTool shareInstance] create3DTouchWithData:items];
    
}
//如果APP没被杀死，还存在后台，点开Touch会调用该代理方法
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    if (shortcutItem) {
        [[HGB3DTouchTool shareInstance] sendAppIcon3DTocuhMessageWith3DTouchType:HGB3DTouchTypeIconActive andWithTitle:shortcutItem.localizedTitle andWithSubTitle:shortcutItem.localizedSubtitle andWithType:shortcutItem.type andWithUserInfo:shortcutItem.userInfo];
    }

    if (completionHandler) {
        completionHandler(YES);
    }
}
@end
