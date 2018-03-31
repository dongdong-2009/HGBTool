//
//  HGBWeexPluginLoader.h
//  CordovaAndWeexBase
//
//  Created by huangguangbao on 2017/7/5.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

@interface HGBWeexPluginLoader : NSObject
+ (NSArray *)getPlugins;
@end
