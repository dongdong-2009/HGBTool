//
//  HGBHUD.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/5.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBHUD.h"
#import "HGBProgressHUD.h"

#define kWidth [[UIScreen mainScreen] bounds].size.width
#define kHeight [[UIScreen mainScreen] bounds].size.height

//屏幕比例
#define wScale kWidth / 750.0
#define hScale kHeight / 1334.0

@interface HGBHUD()
@property(strong,nonatomic)UIView *backView;
/**
 提示
*/
@property(strong,nonatomic)HGBProgressHUD *hud;


@end
@implementation HGBHUD

static HGBHUD *instance=nil;
#pragma mark init
+(instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBHUD alloc]init];
    }
    return instance;
}

#pragma mark 保存

/**
*  保存
*
*  @param view 显示界面
*/
-(void)showHUDSaveToView:(UIView *)view
{
    if([self.backView superview]){
        [self.backView removeFromSuperview];
    }
    if([self.hud superview]){
        [self.hud hide:YES];
    }
    self.backView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    self.backView.backgroundColor=[UIColor clearColor];
    [view addSubview:self.backView];
    self.hud=[HGBProgressHUD showHUDAddedTo:view animated:YES];
    self.hud.dimBackground=NO;
    self.hud.mode = HGBProgressHUDModeIndeterminate;

}


/**
*  隐藏保存
*/
-(void)hideSave
{
    [self.backView removeFromSuperview];
    [self.hud hide:YES];
}

/**
* //显示结果
*
*  @param view 显示界面
*/
-(void)showHUDResult:(NSString *)result ToView:(UIView *)view{
    if([self.backView superview]){
        [self.backView removeFromSuperview];
    }
    if([self.hud superview]){
        [self.hud hide:YES];
    }
    self.hud = [HGBProgressHUD showHUDAddedTo:view animated:YES];
    self.hud.mode = HGBProgressHUDModeText;
    self.hud.dimBackground=NO;
    if(self.title){
        self.hud.labelText=self.title;
    }else{
        self.hud.labelText = @"温馨提示";
    }
    self.hud.detailsLabelText=result;
    if(self.duration==0){
        [self.hud hide:YES afterDelay:2];
    }else{
        [self.hud hide:YES afterDelay:self.duration];
    }
}

/**
* 显示结果-无遮挡
*
*  @param view 显示界面
*/
-(void)showHUDResult:(NSString *)result WithoutBackToView:(UIView *)view{
    if([self.backView superview]){
        [self.backView removeFromSuperview];
    }
    if([self.hud superview]){
        [self.hud hide:YES];
    }
    self.hud = [HGBProgressHUD showHUDAddedTo:view animated:YES];
    self.hud.mode = HGBProgressHUDModeText;
    //    self.promptHud.labelText = @"温馨提示";
    self.hud.dimBackground=NO;
    self.hud.userInteractionEnabled=NO;
    //    CGFloat margin = 92 ;  //距离底部和顶部的距离
    //    CGFloat offSetY = view.bounds.size.height / 2 - margin;
    CGFloat offSetY=(kHeight-64-10)*0.5*0.7;
    self.hud.yOffset = offSetY;
    self.hud.backgroundColor=[UIColor clearColor];
    self.hud.detailsLabelText=result;
    [self.hud hide:YES afterDelay:2];
}
@end

