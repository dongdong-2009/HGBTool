//
//  HGBCurrentControllerTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/12/22.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface HGBCurrentControllerTool : NSObject
#pragma mark 获取当前控制器
/**
 获取当前控制器

 @return 当前控制器
 */
+ (UIViewController *)currentViewController;
@end
