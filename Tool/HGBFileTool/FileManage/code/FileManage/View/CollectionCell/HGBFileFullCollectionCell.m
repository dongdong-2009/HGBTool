//
//  HGBFileFullCollectionCell.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/2/5.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBFileFullCollectionCell.h"
#import "HGBFileManageHeader.h"

@interface HGBFileFullCollectionCell()
/**
 图片按钮
 */
@property(strong,nonatomic)UIButton *imageButton;
/**
 选择按钮
 */
@property(strong,nonatomic)UIButton *selectButton;
@end

@implementation HGBFileFullCollectionCell
#pragma mark init
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self viewSetUp];
    }
    return self;
}
#pragma mark view
-(void)viewSetUp{

    self.backgroundColor=[UIColor whiteColor];
    self.contentView.backgroundColor=[UIColor whiteColor];
    self.imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kWidth*0.25, kWidth*0.25)];
    self.imageView.backgroundColor=[UIColor whiteColor];
    [self.contentView addSubview:self.imageView];

    self.titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(kWidth*0.025, kWidth*0.15, kWidth*0.2, kWidth*0.075)];
    self.titleLabel.textAlignment=NSTextAlignmentCenter;
    self.titleLabel.textColor=[UIColor darkGrayColor];
    self.titleLabel.font=[UIFont systemFontOfSize:kWidth*0.03];
    [self.contentView addSubview:self.titleLabel];

    self.imageButton=[UIButton buttonWithType:(UIButtonTypeSystem)];
    self.imageButton.frame=self.imageView.frame;
    self.imageButton.backgroundColor=[UIColor clearColor];
    [self.imageButton addTarget:self action:@selector(imageButtonHandle:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.contentView addSubview:self.imageButton];


//    self.selectButton=[UIButton buttonWithType:(UIButtonTypeCustom)];
//     self.selectButton.frame=CGRectMake(self.frame.size.width-46*wScale, 10*hScale, 36*wScale, 36*wScale);
//    [self.selectButton setImage:[UIImage imageNamed:@"HGBFileManageToolBundle.bundle/notselect.png"] forState:(UIControlStateNormal)];
//    [self.selectButton addTarget:self action:@selector(selectButtonHandle:) forControlEvents:(UIControlEventTouchUpInside)];
//    self.selectButton.hidden=YES;
//    [self.contentView addSubview:self.selectButton];


    UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressHandler:)];
    //要求点击保持最短时间
    longPress.minimumPressDuration=1;
    [self.contentView addGestureRecognizer:longPress];


}
-(void)layoutSubviews{
    self.imageView.frame=CGRectMake(0, 0, kWidth*0.25, kWidth*0.25);
    self.titleLabel.frame=CGRectMake(kWidth*0.025, kWidth*0.15, kWidth*0.2, kWidth*0.075);
     self.imageButton.frame=self.imageView.frame;
//     self.selectButton.frame=CGRectMake(self.frame.size.width-46*wScale, 10*hScale, 36*wScale, 36*wScale);

}
//-(void)setIsShowSelect:(BOOL)isShowSelect{
//    _isShowSelect=isShowSelect;
//    if(_isShowSelect){
//        self.selectButton.hidden=NO;
//    }else{
//        self.selectButton.hidden=YES;
//    }
//    if(_isSelect==YES){
//        [self.selectButton setImage:[UIImage imageNamed:@"HGBFileManageToolBundle.bundle/select.png"] forState:(UIControlStateNormal)];
//
//    }else{
//        [self.selectButton setImage:[UIImage imageNamed:@"HGBFileManageToolBundle.bundle/notselect.png"] forState:(UIControlStateNormal)];
//
//    }
//}
//#pragma mark button
//-(void)selectButtonHandle:(UIButton *)_b{
//    if(self.isSelect==YES){
//        self.isSelect=NO;
//        [self.selectButton setImage:[UIImage imageNamed:@"HGBFileManageToolBundle.bundle/notselect.png"] forState:(UIControlStateNormal)];
//    }else{
//        self.isSelect=YES;
//        [self.selectButton setImage:[UIImage imageNamed:@"HGBFileManageToolBundle.bundle/select.png"] forState:(UIControlStateNormal)];
//    }
//
//}
-(void)imageButtonHandle:(UIButton *)_b{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(fileFullCollectionCell:didClickImageWithIndexPath:)]){
        [self.delegate fileFullCollectionCell:self didClickImageWithIndexPath:self.indexPath];
    }
}
#pragma mark action
-(void)longPressHandler:(UILongPressGestureRecognizer *)_p{
//     self.isSelect=YES;
    if(self.delegate&&[self.delegate respondsToSelector:@selector(fileFullCollectionCell:didLongPressImageWithIndexPath:)]){
        [self.delegate fileFullCollectionCell:self didLongPressImageWithIndexPath:self.indexPath];
    }
}
@end
