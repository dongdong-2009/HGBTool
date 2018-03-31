//
//  HGBView3DTouchSheetModel.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/2/3.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface HGBView3DTouchSheetModel : NSObject
/**
 样式
 */
@property(assign,nonatomic)UIPreviewActionStyle previewActionStyle;
/**
 标题
 */
@property(strong,nonatomic)NSString *title;
/**
 3DTouch 底部弹出窗模型

 @param title 标题
 @param previewActionStyle 样式
 @return 结果
 */
+(HGBView3DTouchSheetModel *)instanceWithTitle:(NSString *)title andWithPreviewActionStyle:(UIPreviewActionStyle)previewActionStyle;
@end
