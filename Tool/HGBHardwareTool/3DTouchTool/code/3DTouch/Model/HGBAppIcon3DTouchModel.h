//
//  HGBAppIcon3DTouchModel.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/2/2.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface HGBAppIcon3DTouchModel : NSObject
/**
 图标
 */
@property(strong,nonatomic)NSString *icon;
/**
 系统图标
 */
@property(assign,nonatomic)UIApplicationShortcutIconType systemIcon;

/**
 标题
 */
@property(strong,nonatomic)NSString *title;
/**
 副标题
 */
@property(strong,nonatomic)NSString *subtitle;
/**
 类型
 */
@property(strong,nonatomic)NSString *type;
/**
 信息
 */
@property(strong,nonatomic)NSDictionary *userInfo;

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
+(HGBAppIcon3DTouchModel *)instanceWithTitle:(NSString *)title andWithType:(NSString *)type andWithSubTitle:(NSString *)subTitle andWithIcon:(NSString *)icon andWithSystemIcon:(UIApplicationShortcutIconType)systemIcon andwithUserInfo:(NSDictionary *)userInfo;
@end
