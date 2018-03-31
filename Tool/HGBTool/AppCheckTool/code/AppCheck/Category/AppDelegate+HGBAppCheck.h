//
//  AppDelegate+HGBAppCheck.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/13.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "AppDelegate.h"
#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

@interface AppDelegate (HGBAppCheck)
/**
 app自检初始化

 @param launchOptions 加载参数
 */
-(void)init_AppCheck_ServerWithOptions:(NSDictionary *)launchOptions;
@end
