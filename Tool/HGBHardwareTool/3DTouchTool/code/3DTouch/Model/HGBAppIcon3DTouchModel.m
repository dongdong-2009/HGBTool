//
//  HGBAppIcon3DTouchModel.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/2/2.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBAppIcon3DTouchModel.h"

@implementation HGBAppIcon3DTouchModel

#pragma mark 功能
/**
 3DTouch模型

 @param title 标题
 @param type 类型
 @param subTitle 副标题
 @param icon 图标
 @param systemIcon 系统图标
 @param userInfo 其他信息
 @return 结果
 */
+(HGBAppIcon3DTouchModel *)instanceWithTitle:(NSString *)title andWithType:(NSString *)type andWithSubTitle:(NSString *)subTitle andWithIcon:(NSString *)icon andWithSystemIcon:(UIApplicationShortcutIconType)systemIcon andwithUserInfo:(NSDictionary *)userInfo{
    HGBAppIcon3DTouchModel *model=[[HGBAppIcon3DTouchModel alloc]init];
    model.title=title;
    model.subtitle=subTitle;
    model.type=type;
    model.icon=icon;
    model.systemIcon=systemIcon;
    model.userInfo=userInfo;
    return model;
}
-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler {
    
}

@end
