//
//  HGBDownLoadTableCell.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/3/15.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGBDownLoadTask.h"

@class HGBDownLoadTableCell;
@protocol HGBDownLoadTableCellDelegate<NSObject>

/**
 删除按钮点击事件

 @param cell cell
 @param task 任务
 */
- (void)downLoadCell:(HGBDownLoadTableCell *)cell didClickDeleteButtonWithTask:(HGBDownLoadTask *)task;
/**
 下载按钮点击事件

 @param cell cell
 @param task 任务
 */
- (void)downLoadCell:(HGBDownLoadTableCell *)cell didClickDownLoadButtonWithTask:(HGBDownLoadTask *)task;
@end



@interface HGBDownLoadTableCell : UITableViewCell
/**
 代理
 */
@property(strong,nonatomic)id<HGBDownLoadTableCellDelegate>delegate;

/**
 任务
 */
@property(strong,nonatomic)HGBDownLoadTask *task;
/**
 标题
 */
@property(strong,nonatomic)UILabel *title;
/**
 标题
 */
@property(strong,nonatomic)UIProgressView *progress;
/**
 删除按钮
 */
@property(strong,nonatomic)UIButton *downLoadButton;
/**
 删除按钮
 */
@property(strong,nonatomic)UIButton *deleteButton;
@end
