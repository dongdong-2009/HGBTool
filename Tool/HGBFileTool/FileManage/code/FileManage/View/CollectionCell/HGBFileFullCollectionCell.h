//
//  HGBFileFullCollectionCell.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/2/5.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HGBFileFullCollectionCell;

/**
 cell表层按钮
 */
@protocol HGBFileFullCollectionCellDelegate <NSObject>
/**
 图片被点击

 @param cell 组件
 @param indexPath 位置
 */
-(void)fileFullCollectionCell:(HGBFileFullCollectionCell *)cell didClickImageWithIndexPath:(NSIndexPath *)indexPath;

/**
 图片被长按

 @param cell 组件
 @param indexPath 位置
 */
-(void)fileFullCollectionCell:(HGBFileFullCollectionCell *)cell didLongPressImageWithIndexPath:(NSIndexPath *)indexPath;
@end

@interface HGBFileFullCollectionCell : UICollectionViewCell
/**
 代理
 */
@property(strong,nonatomic)id<HGBFileFullCollectionCellDelegate>delegate;
///**
// 是否被选中
// */
//@property(assign,nonatomic)BOOL isSelect;
///**
// 是否被选中
// */
//@property(assign,nonatomic)BOOL isShowSelect;
/**
 位置
 */
@property(strong,nonatomic)NSIndexPath *indexPath;

/**
 图片
 */
@property(strong,nonatomic)UIImageView *imageView;
/**
 标签
 */
@property(strong,nonatomic)UILabel *titleLabel;
@end
