//
//  UIViewController+HGB3DTouch.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/2/2.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "UIViewController+HGB3DTouch.h"





#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"


@interface UIViewController()

@end
@implementation UIViewController (HGB3DTouch)
static CGPoint _location;
static UIView *_sourceView;

/**
 预览
 */
static HGB3DTouchPreviewBlock _previewBlock;
/**
 弹窗点击事件
 */
static HGB3DTouchSheetClickBlock _sheetBlock;
/**
 弹窗
 */
static NSArray *_sheetArray;


/**
 为View注册3DTouch

 @param view 视图
 @param reslut 结果block

 @return 结果
 */
-(BOOL)add3DTocuhMonitorWithView:(UIView *)view andWithBlock:(HGB3DTouchReslutBlock)reslut{


#ifndef __IPHONE_9_0
    reslut(NO,@{ReslutCode:@(HGB3DTouchErrorTypeSDKVersion).stringValue,ReslutMessage:@"版本不支持"});
    HGBLog(@"版本不支持");
    return NO;
#endif
    if (TARGET_IPHONE_SIMULATOR) {
        reslut(NO,@{ReslutCode:@(HGB3DTouchErrorTypeDevice).stringValue,ReslutMessage:@"设备不支持"});
        HGBLog(@"设备不支持");
        return NO;
    }
    //注册3D Touch
    /**
     从iOS9开始，我们可以通过这个类来判断运行程序对应的设备是否支持3D Touch功能。
     UIForceTouchCapabilityUnknown = 0,     //未知
     UIForceTouchCapabilityUnavailable = 1, //不可用
     UIForceTouchCapabilityAvailable = 2    //可用
     */
    if ([self respondsToSelector:@selector(traitCollection)]) {

        if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {

            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {

                [self registerForPreviewingWithDelegate:(id)self sourceView:view];

                reslut(YES,@{ReslutCode:@(1).stringValue,ReslutMessage:@"成功"});
                return YES;
            }
        }
    }
    reslut(NO,@{ReslutCode:@(HGB3DTouchErrorTypeDevice).stringValue,ReslutMessage:@"设备不支持"});
    HGBLog(@"3DTouch不可用");
    return NO;

}
/**
 监听3DTouch点击

 @param previewBlock 预览视图block
 @param sheetBlock 底部弹出窗点开事件block

 @return 结果
 */
-(BOOL)monitorWithWithPreviewBlock:(HGB3DTouchPreviewBlock )previewBlock andWithsheetBlock:(HGB3DTouchSheetClickBlock)sheetBlock{

#ifndef __IPHONE_9_0

    HGBLog(@"版本不支持");
    return NO;
#endif
    if (TARGET_IPHONE_SIMULATOR) {
        HGBLog(@"设备不支持");
        return NO;
    }
    _previewBlock= previewBlock;
    _sheetBlock = sheetBlock;
    return YES;

}
/**
 设置底部弹出窗数据

 @param dataArray 底部弹出窗数据
 */
-(void)set3DTouchSheetWithData:(NSArray <HGBView3DTouchSheetModel *>*)dataArray{
    _sheetArray=dataArray;

}
#pragma mark - 3D Touch 预览Action代理
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {

    NSMutableArray *items = [NSMutableArray array];
    for(NSInteger i=0;i<_sheetArray.count;i++){
        HGBView3DTouchSheetModel *model=_sheetArray[i];
        UIPreviewAction *previewAction = [UIPreviewAction actionWithTitle:model.title style:model.previewActionStyle handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
            _sheetBlock(i);
        }];
        [items addObject:previewAction];
    }

    return items;
}

#pragma mark - UIViewControllerPreviewingDelegate
#pragma mark peek(preview)
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location NS_AVAILABLE_IOS(9_0) {
     _location=location;
    _sourceView=_sourceView;
    if(_previewBlock){

        return _previewBlock(location,previewingContext.sourceView);
    }
    return nil;
}

#pragma mark pop(push)
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit NS_AVAILABLE_IOS(9_0) {

    [self showViewController:viewControllerToCommit sender:self];
}
@end
