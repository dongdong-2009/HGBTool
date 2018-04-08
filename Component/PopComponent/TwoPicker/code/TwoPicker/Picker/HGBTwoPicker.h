//
//  HGBTwoPicker.h
//  CTTX
//
//  Created by huangguangbao on 17/1/8.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HGBTwoPicker;
/**
 两项选择代理
 */
@protocol HGBTwoPickerDelegate <NSObject>
@optional
/**
 选择

 @param arr 信息
 */
-(void)twoPicker:(HGBTwoPicker *)picker didSelectedWithTitleArr:(NSArray *)arr;
/**
 选择

 @param firstIndex 第一坐标
 @param secondIndex 第二坐标
 */
-(void)twoPicker:(HGBTwoPicker *)picker didSelectedWithFirstIndex:(NSInteger)firstIndex andWithSecondIndex:(NSInteger)secondIndex;

/**
 取消
 */
-(void)twoPickerDidCanceled:(HGBTwoPicker *)picker;
@end

/**
 两项选择
 */
@interface HGBTwoPicker : UIViewController
/**
 标题
 */
@property (nonatomic,strong)NSString *titleStr;
/**
 标识
 */
@property(assign,nonatomic)NSInteger index;
/**
 字体颜色
 */
@property(strong,nonatomic)UIColor *textColor;
/**
 字体大小
 */
@property(assign,nonatomic)CGFloat fontSize;
/**
 选中项
 */
@property(strong,nonatomic)NSArray *selectedItems;
/**
 第一选中项-
 */
@property(assign,nonatomic)NSInteger firstSelectedIndex;

/**
 第二选中项
 */
@property(assign,nonatomic)NSInteger secondSelectedIndex;


/**
 数据源:dic-arr
 */
@property (nonatomic,strong)NSDictionary *dataSource;
/**
 是否排序
 */
@property(nonatomic,assign)BOOL isSequence;
/**
 创建
 */
+(instancetype)instanceWithParent:(UIViewController *)parent andWithDelegate:(id<HGBTwoPickerDelegate>)delegate;
/**
 弹出
 */
-(void)popInParentView;
@end
