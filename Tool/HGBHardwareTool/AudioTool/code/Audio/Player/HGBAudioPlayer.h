//
//  HGBAudioPlayer.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/30.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>



//快捷url提示
/**
 project://工程包内
 home://沙盒路径
 http:// https://网络路径
 document://  或defaults://沙盒Documents文件夹
 caches://沙盒Caches
 tmp://沙盒Tmp文件夹

 */


@class HGBAudioPlayer;
/**
 代理
 */
@protocol HGBAudioPlayerDelegate <NSObject>

@optional

/**
 成功

 @param player 媒体
 */
-(void)audioPlayerDidSucessed:(HGBAudioPlayer *)player;
/**
 失败

 @param player 媒体
 @param errorInfo 错误信息
 */
-(void)audioPlayer:(HGBAudioPlayer *)player didFailedWithError:(NSDictionary *)errorInfo;
/**
 取消

 @param player 媒体
 */
-(void)audioPlayerDidCanceled:(HGBAudioPlayer *)player;
@end


@interface HGBAudioPlayer : UIViewController
/**
 代理
 */
@property(strong,nonatomic)id<HGBAudioPlayerDelegate>delegate;
/**
 url
 */
@property(strong,nonatomic)NSString *url;


@end
