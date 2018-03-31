//
//  AppDelegate+HGBException.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/13.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (HGBException)
/**
 错误捕捉初始化

 @param launchOptions 加载参数
 */
-(void)init_Exception_ServerWithOptions:(NSDictionary *)launchOptions;
@end
