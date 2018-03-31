//
//  HGBDownLoadTableCell.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/3/15.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBDownLoadTableCell.h"
#import "HGBDownLoadHeader.h"

@implementation HGBDownLoadTableCell

#pragma mark init
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self p_ViewSetUp];
    }
    return self;
}
#pragma mark view
-(void)p_ViewSetUp
{
    self.contentView.backgroundColor=[UIColor whiteColor];
    self.alpha=1;
    self.title=[[UILabel alloc]initWithFrame:CGRectMake(30*wScale,0,kWidth-300*wScale,90*hScale)];
    self.title.text=@"标题";
    self.title.textAlignment=NSTextAlignmentLeft;
    self.title.backgroundColor=[UIColor whiteColor];
    self.title.font=[UIFont systemFontOfSize:17.7];
    self.title.textColor=[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    [self.contentView addSubview:self.title];

    self.progress=[[UIProgressView alloc]initWithFrame:CGRectMake(30*hScale, 100*hScale, kWidth-400*wScale, 10*hScale)];
    self.progress.backgroundColor = [UIColor grayColor];
     self.progress.progress = 0;
     self.progress.tintColor = [UIColor blueColor];
     self.progress.transform = CGAffineTransformMakeScale(1.0f, 1.0f);

    [self.contentView addSubview:self.progress];

    self.deleteButton=[UIButton buttonWithType:(UIButtonTypeSystem)];
    self.deleteButton.frame=CGRectMake(kWidth-240*wScale, 30*hScale, 100*wScale, 60*hScale);
    [self.deleteButton setTitle:@"删除" forState:(UIControlStateNormal)];
    [self.deleteButton setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
    [self.contentView addSubview:self.deleteButton];


    self.downLoadButton=[UIButton buttonWithType:(UIButtonTypeSystem)];
    self.downLoadButton.frame=CGRectMake(kWidth-120*wScale, 30*hScale, 100*wScale, 60*hScale);
    [self.downLoadButton setTitle:@"暂停" forState:(UIControlStateNormal)];
    [self.downLoadButton setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
    [self.contentView addSubview:self.downLoadButton];

}
#pragma mark action
-(void)deleteButtonAction:(UIButton *)_b{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(downLoadCell:didClickDeleteButtonWithTask:)]) {
        [self.delegate downLoadCell:self didClickDeleteButtonWithTask:self.task];
    }
}
-(void)downloadButtonAction:(UIButton *)_b{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(downLoadCell:didClickDownLoadButtonWithTask:)]) {
        [self.delegate downLoadCell:self didClickDownLoadButtonWithTask:self.task];
    }

}
#pragma mark set
-(void)setTask:(HGBDownLoadTask *)task{
    _task=task;
    self.progress.progress=_task.progress;
    self.title.text=_task.name;
    if(_task.status==HGBDownloadStateCancel){
        self.downLoadButton.enabled=YES;
        [self.downLoadButton setTitle:@"下载" forState:(UIControlStateNormal)];
    }else if (_task.status==HGBDownloadStateRuning){
        self.downLoadButton.enabled=YES;
        [self.downLoadButton setTitle:@"暂停" forState:(UIControlStateNormal)];
    }else if (_task.status==HGBDownloadStateCompleted){
        [self.downLoadButton setTitle:@"完成" forState:(UIControlStateNormal)];
        self.downLoadButton.enabled=NO;
    }
}

@end
