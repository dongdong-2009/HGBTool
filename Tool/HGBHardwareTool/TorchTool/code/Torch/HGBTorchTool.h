//
//  HGBTorchTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/28.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

@interface HGBTorchTool : NSObject
#pragma mark 手电筒
/**
 打开手电筒
 */
+(BOOL)startOnTorch;
/**
 关闭手电筒
 */
+(BOOL)startOffTorch;
@end
