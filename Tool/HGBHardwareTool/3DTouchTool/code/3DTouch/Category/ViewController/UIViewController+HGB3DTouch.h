//
//  UIViewController+HGB3DTouch.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/2/2.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGBView3DTouchSheetModel.h"

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif


/**
 错误类型
 */
typedef enum HGB3DTouchErrorType
{
    HGB3DTouchErrorTypeParams=0,//参数错误
    HGB3DTouchErrorTypeOther=98,//其他
    HGB3DTouchErrorTypeDevice=10,//设备受限
    HGB3DTouchErrorTypeAuthorized=11,//权限
    HGB3DTouchErrorTypeSDKVersion=12,//参数错误


}HGB3DTouchErrorType;


/**
 结果

 @param status 状态
 @param returnMessage 信息
 */
typedef void  (^HGB3DTouchReslutBlock)(BOOL status,NSDictionary *returnMessage);

/**
 设置预览视图

 @param location 点击的view的位置
 @param sourceView 点击的view
 @return 控制器
 */
typedef UIViewController * (^HGB3DTouchPreviewBlock)(CGPoint location,UIView *sourceView);

/**
 底部弹窗block

 @param index 状态
 */
typedef void (^HGB3DTouchSheetClickBlock)(NSInteger index);


@interface UIViewController (HGB3DTouch)
/**
 为View注册3DTouch

 @param view 视图
 @param reslut 结果block

 @return 结果
 */
-(BOOL)add3DTocuhMonitorWithView:(UIView *)view andWithBlock:(HGB3DTouchReslutBlock)reslut;
/**
 监听3DTouch点击

 @param previewBlock 预览视图block
 @param sheetBlock 底部弹出窗点开事件block

 @return 结果
 */
-(BOOL)monitorWithWithPreviewBlock:(HGB3DTouchPreviewBlock )previewBlock andWithsheetBlock:(HGB3DTouchSheetClickBlock)sheetBlock;

/**
 设置底部弹出窗数据

 @param dataArray 底部弹出窗数据
 */
-(void)set3DTouchSheetWithData:(NSArray <HGBView3DTouchSheetModel *>*)dataArray;
@end
