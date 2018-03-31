//
//  HGBFileTableCell.m
//  测试
//
//  Created by huangguangbao on 2017/8/15.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBFileTableCell.h"
#import "HGBFileManageHeader.h"

@interface HGBFileTableCell()
/**
 底层
 */
@property(strong,nonatomic)UIView *functionView;

/**
 顶层view
 */
@property(strong,nonatomic)UIButton *headView;
/**
 图片按钮
 */
@property(strong,nonatomic)UIButton *imageButton;
/**
 选择按钮
 */
@property(strong,nonatomic)UIButton *selectButton;
@end
@implementation HGBFileTableCell
#pragma mark init
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self viewSetUp];
        [self drawWithHeight:120*hScale];
        self.bottomHiden=NO;
        self.topHiden=NO;
        self.shortHiden=YES;
    }
    return self;
}
-(void)viewSetUp
{
    self.backgroundColor=[UIColor whiteColor];
    self.iconImageView=[[UIImageView alloc]initWithFrame:CGRectMake(30*wScale,20*hScale,80*hScale,80*hScale)];
    [self.contentView addSubview:self.iconImageView];

    self.fileNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(45*wScale+80*hScale,25*hScale,kWidth-(105*wScale+80*hScale), 32*hScale)];
    self.fileNameLabel.text=@"文件名";

    self.fileNameLabel.font=[UIFont  systemFontOfSize:32*hScale];
    self.fileNameLabel.textColor=[UIColor blackColor];
    self.fileNameLabel.textAlignment=NSTextAlignmentLeft;
    [self addSubview:self.fileNameLabel];



    self.fileInfoLable=[[UILabel alloc]initWithFrame:CGRectMake(45*wScale+80*hScale,69*hScale,kWidth-(105*wScale+80*hScale), 24*hScale)];
    self.fileInfoLable.text=@"文件信息";

    self.fileInfoLable.font=[UIFont  systemFontOfSize:24*hScale];
    self.fileInfoLable.textColor=[UIColor blackColor];
    self.fileInfoLable.textAlignment=NSTextAlignmentLeft;
    [self addSubview:self.fileInfoLable];


    self.tapImageView=[[UIImageView alloc]initWithFrame:CGRectMake(kWidth-(35*wScale),40*hScale,20*wScale,40*hScale)];
    self.tapImageView.image=[UIImage imageNamed:@"HGBFileManageToolBundle.bundle/icon_next.png"];
    [self.contentView addSubview:self.tapImageView];


    self.headView=[UIButton buttonWithType:(UIButtonTypeSystem)];
    self.headView.frame=CGRectMake(0, 0, kWidth, 120*hScale);


    self.imageButton=[UIButton buttonWithType:(UIButtonTypeSystem)];
    self.imageButton.frame=CGRectMake(0, 0, kWidth, self.frame.size.height);
    self.imageButton.backgroundColor=[UIColor clearColor];
    [self.imageButton addTarget:self action:@selector(imageButtonHandle:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.contentView addSubview:self.imageButton];


//    [self.contentView addSubview:self.headView];


//    self.selectButton=[UIButton buttonWithType:(UIButtonTypeCustom)];
//     self.selectButton.frame=CGRectMake(self.frame.size.width-46*wScale, 47*hScale, 36*wScale, 36*wScale);
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
    [super layoutSubviews];
    self.imageButton.frame=CGRectMake(0, 0, kWidth, self.frame.size.height);
//    self.selectButton.frame=CGRectMake(self.frame.size.width-46*wScale, 47*hScale, 36*wScale, 36*wScale);

}
//-(void)setIsShowSelect:(BOOL)isShowSelect{
//    _isShowSelect=isShowSelect;
//    if(_isShowSelect){
//        self.selectButton.hidden=NO;
//        if([self.tapImageView superview]){
//            [self.tapImageView removeFromSuperview];
//        }
//    }else{
//        self.selectButton.hidden=YES;
//        if(![self.tapImageView superview]){
//            [self.contentView addSubview:self.tapImageView];
//        }
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
    if(self.delegate&&[self.delegate respondsToSelector:@selector(fileTableCell:didClickImageWithIndexPath:)]){
        [self.delegate fileTableCell:self didClickImageWithIndexPath:self.indexPath];
    }
}
#pragma mark action
-(void)longPressHandler:(UILongPressGestureRecognizer *)_p{
//    self.isSelect=YES;
    if(self.delegate&&[self.delegate respondsToSelector:@selector(fileTableCell:didLongPressImageWithIndexPath:)]){
        [self.delegate fileTableCell:self didLongPressImageWithIndexPath:self.indexPath];
    }
}
@end
