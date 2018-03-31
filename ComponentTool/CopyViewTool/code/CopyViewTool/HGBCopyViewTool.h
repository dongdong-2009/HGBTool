//
//  HGBCopyViewTool.h
//  HelloCordova
//
//  Created by huangguangbao on 2017/12/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HGBCopyViewTool : NSObject

#pragma mark 组件复制
/**
 复制view
 */
+ (UIView *)duplicateComponent:(UIView *)view;
@end
