
//
//  HGBWebViewFailedView.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/12/8.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBWebViewFailedView.h"
#import "HGBWebHeader.h"
@interface HGBWebViewFailedView()
@property(strong,nonatomic)id<HGBWebViewFailedViewDelegate>delegate;
@end

@implementation HGBWebViewFailedView
#pragma mark init
- (instancetype)initWithFrame:(CGRect)frame andWithDelegate:(id<HGBWebViewFailedViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate=delegate;
        [self viewSetUp];
    }
    return self;
}
#pragma mark view
-(void)viewSetUp{
    self.backgroundColor=[UIColor whiteColor];
    UIImageView *promptImageView=[[UIImageView alloc]initWithFrame:CGRectMake((kWidth-160)*0.5, 200, 160, 160)];
    promptImageView.image=[UIImage imageNamed:@"HGBWebView.bundle/web_load_error.png"];
    [self addSubview:promptImageView];

    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 380, kWidth, 30)];
    label.text=@"加载失败";
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor redColor];
    [self addSubview:label];

    UIButton *refrshButton=[UIButton buttonWithType:(UIButtonTypeCustom)];
    refrshButton.frame=CGRectMake((kWidth-80)*0.5, 420, 80, 80);
    [refrshButton setImage:[UIImage imageNamed:@"HGBWebView.bundle/web_refresh.png"] forState:(UIControlStateNormal)];
    [refrshButton addTarget:self action:@selector(refreshHandle:) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:refrshButton];

}
#pragma mark action
-(void)refreshHandle:(UIButton *)_b{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(webViewFailedViewRefreshAction)]){
        [self.delegate webViewFailedViewRefreshAction];
    }
}
@end
