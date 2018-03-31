//
//  HGBDownLoadTask.h
//  测试
//
//  Created by huangguangbao on 2018/3/13.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define HGBDownLoadTaskGrounpID @"common"



typedef NS_ENUM(NSInteger,HGBDownloadState){
    HGBDownloadStateRuning = 0,     /** 下载中 */
    HGBDownloadStateSuspended,     /** 下载暂停 */
    HGBDownloadStateCompleted,     /** 下载完成 */
    HGBDownloadStateCancel,        /** 下载取消 */
    HGBDownloadStateUnExpectedCancel,     /** 意外取消 */
    HGBDownloadStateFailed         /** 下载失败 */
};



@interface HGBDownLoadTask : NSObject

/**
 下载的远程链接
 */
@property (strong,nonatomic)NSString * url;


/**
 线程
 */
@property(strong,nonatomic)NSOperationQueue *queue;
/**
 下载管理
 */
@property(strong,nonatomic)NSURLSession *session;
/**
 下载任务
 */
@property(strong,nonatomic)NSURLSessionDownloadTask *downLoadTask;


#pragma mark 以下参数不需要设置-仅供读取
/**
 id
 */
@property (strong,nonatomic)NSString * id;
/**
 下载后保存地址
 */
@property (strong,nonatomic)NSString * path;
/**
 名称
 */
@property (strong,nonatomic)NSString * name;

/**
 组
 */
@property (strong,nonatomic)NSString * groupId;

/**
 下载缓存数据
 */
@property (strong,nonatomic)NSData * data;
/**
 下载状态
 */
@property (assign,nonatomic)HGBDownloadState status;

/**
 下载文件大小
 */
@property (assign,nonatomic) CGFloat totalSize;
/**
 已下载大小
 */
@property (assign,nonatomic)CGFloat downloadSize;
/**
 进度
 */
@property (assign,nonatomic)CGFloat progress;





/**
 快捷创建模型

 @param url 下载的url
 @param path 下载后保存在本地的地址
 @return 模型
 */
+(HGBDownLoadTask *)downLoadTaskModelWithUrl:(NSString *)url andWithPath:(NSString *)path;


/**
 将任务模型转化为字典

 @param taskModel 模型
 @return 字典
 */
+(NSDictionary *)dictionaryFromTaskModel:(HGBDownLoadTask *)taskModel;
/**
 将字典转化为任务模型

 @param dictionary 字典
 @return 模型
 */
+(HGBDownLoadTask *)taskModelFormDictionary:(NSDictionary *)dictionary;
@end
