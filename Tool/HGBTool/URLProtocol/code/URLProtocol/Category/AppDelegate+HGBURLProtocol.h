//
//  AppDelegate+HGBURLProtocol.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/2/8.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (HGBURLProtocol)
/**
 黑白名单设置

 @param launchOptions 加载参数
 */
-(void)init_URLIntercept_ServerWithOptions:(NSDictionary *)launchOptions;
@end
