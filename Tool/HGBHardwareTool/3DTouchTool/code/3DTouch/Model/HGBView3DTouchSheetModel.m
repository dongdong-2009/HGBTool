//
//  HGBView3DTouchSheetModel.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/2/3.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBView3DTouchSheetModel.h"

@implementation HGBView3DTouchSheetModel
/**
 3DTouch 底部弹出窗模型

 @param title 标题
 @param previewActionStyle 样式
 @return 结果
 */
+(HGBView3DTouchSheetModel *)instanceWithTitle:(NSString *)title andWithPreviewActionStyle:(UIPreviewActionStyle)previewActionStyle{
    HGBView3DTouchSheetModel *model=[[HGBView3DTouchSheetModel alloc]init];
    model.title=title;
    model.previewActionStyle=previewActionStyle;
    return model;
}
@end
