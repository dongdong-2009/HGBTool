//
//  HGBFileSpaceCollectionCell.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/2/5.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>


@class HGBFileSpaceCollectionCell;
/**
 cell表层按钮
 */
@protocol HGBFileSpaceCollectionCellDelegate <NSObject>
/**
 图片被点击

 @param cell 组件
 @param indexPath 位置
 */
-(void)fileSpaceCollectionCell:(HGBFileSpaceCollectionCell *)cell didClickImageWithIndexPath:(NSIndexPath *)indexPath;

/**
 图片被长按

 @param cell 组件
 @param indexPath 位置
 */
-(void)fileSpaceCollectionCell:(HGBFileSpaceCollectionCell *)cell didLongPressImageWithIndexPath:(NSIndexPath *)indexPath;
@end


@interface HGBFileSpaceCollectionCell : UICollectionViewCell
///**
// 是否被选中
// */
//@property(assign,nonatomic)BOOL isSelect;
///**
// 是否被选中
// */
//@property(assign,nonatomic)BOOL isShowSelect;
/**
 代理
 */
@property(strong,nonatomic)id<HGBFileSpaceCollectionCellDelegate>delegate;
/**
 位置
 */
@property(strong,nonatomic)NSIndexPath *indexPath;
//@property(assign,nonatomic)
/**
 图片
 */
@property(strong,nonatomic)UIImageView *imageView;
/**
 标签
 */
@property(strong,nonatomic)UILabel *titleLabel;
@end
