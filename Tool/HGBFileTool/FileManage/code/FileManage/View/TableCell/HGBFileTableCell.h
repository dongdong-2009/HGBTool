//
//  HGBFileTableCell.h
//  测试
//
//  Created by huangguangbao on 2017/8/15.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGBFileBaseTableCell.h"


@class HGBFileTableCell;
/**
 cell表层按钮
 */
@protocol HGBFileTableCellDelegate <NSObject>
/**
 图片被点击

 @param cell 组件
 @param indexPath 位置
 */
-(void)fileTableCell:(HGBFileTableCell *)cell didClickImageWithIndexPath:(NSIndexPath *)indexPath;

/**
 图片被长按

 @param cell 组件
 @param indexPath 位置
 */
-(void)fileTableCell:(HGBFileTableCell *)cell didLongPressImageWithIndexPath:(NSIndexPath *)indexPath;
@end


@interface HGBFileTableCell : HGBFileBaseTableCell
/**
 代理
 */
@property(strong,nonatomic)id<HGBFileTableCellDelegate>delegate;
///**
// 是否被选中
// */
//@property(assign,nonatomic)BOOL isSelect;
///**
// 是否被选中
// */
//@property(assign,nonatomic)BOOL isShowSelect;
/**
 icon
 */
@property(strong,nonatomic)UIImageView *iconImageView;
/**
 文件名
*/
@property(strong,nonatomic)UILabel *fileNameLabel;
/**
 文件信息
 */
@property(strong,nonatomic)UILabel *fileInfoLable;
/**
 下一级
 */
@property(strong,nonatomic)UIImageView *tapImageView;
@end
