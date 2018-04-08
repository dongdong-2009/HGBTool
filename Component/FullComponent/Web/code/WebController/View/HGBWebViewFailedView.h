//
//  HGBWebViewFailedView.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/12/8.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 基础浏览器代理
 */
@protocol  HGBWebViewFailedViewDelegate<NSObject>
@optional
/**
 刷新按钮
 */
-(void)webViewFailedViewRefreshAction;
@end

@interface HGBWebViewFailedView : UIView
#pragma mark init
- (instancetype)initWithFrame:(CGRect)frame andWithDelegate:(id<HGBWebViewFailedViewDelegate>)delegate;
@end
