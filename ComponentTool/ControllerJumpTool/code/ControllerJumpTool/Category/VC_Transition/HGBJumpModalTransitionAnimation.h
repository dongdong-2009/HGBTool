//
//  HGBJumpModalTransitionAnimation.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/12/22.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif


typedef enum {

    HGBJumpAnimationTypePresent,

    HGBJumpAnimationTypeDismiss

} HGBJumpAnimationType;

@interface HGBJumpModalTransitionAnimation : NSObject<UIViewControllerAnimatedTransitioning>
/**
 动画类型
 */
@property (nonatomic, assign) HGBJumpAnimationType animationType;
@end
