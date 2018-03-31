//
//  HGBDownLoadTool.h
//  测试
//
//  Created by huangguangbao on 2018/2/5.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HGBDownLoadTask.h"

//快捷url提示
/**
 project://工程包内
 home://沙盒路径
 http:// https://网络路径
 document://  或defaults://沙盒Documents文件夹
 caches://沙盒Caches
 tmp://沙盒Tmp文件夹

 */

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif





/**
 错误类型
 */
typedef enum HGBDownLoadErrorType
{
    HGBDownLoadErrorTypeParams=0,//参数错误
    HGBDownLoadErrorTypeError=99,//错误
    HGBDownLoadErrorTypeNotExistURL=20,//路径不存在
    HGBDownLoadErrorTypeExistPath=21,//路径已存在
    HGBDownLoadErrorTypePathError=23//路径无效

}HGBDownLoadErrorType;


/**
 结果

 @param status 状态
 @param returnMessage 信息
 */
typedef void (^HGBDownLoadReslutBlock)(BOOL status,HGBDownLoadTask *task,NSDictionary *returnMessage);



@interface HGBDownLoadTool : NSObject
/**
 结果
 */
@property(strong,nonatomic)HGBDownLoadReslutBlock resultBlock;
/**
 是否可以后台下载-默认不可以
 */
@property(assign,nonatomic)BOOL isCanBackGround;
#pragma mark 单例
/**
 单例

 @return 单例
 */
+(instancetype)shareInstance;
#pragma mark 下载
/**
 开始下载

 @param task 下载任务
 @return 结果
 */
-(BOOL)startDownLoadWithDownLoadTask:(HGBDownLoadTask *)task;
/**
 取消下载

 @param task 下载任务
 @return 结果
 */
-(BOOL)cancelDownLoadWithDownLoadTask:(HGBDownLoadTask *)task;
/**
 暂停下载

 @param task 下载任务
 @return 结果
 */
-(BOOL)suspendDownLoadWithDownLoadTask:(HGBDownLoadTask *)task;
/**
 暂停下载恢复下载任务

 @param task 下载任务
 @return 结果
 */
-(BOOL)resumeDownLoadWithDownLoadTask:(HGBDownLoadTask *)task;
/**
 取消所有任务
 */
-(void)cancelAllTasks;
/**
 取消所有任务
 */
-(void)suspendAllTasks;

#pragma mark 下载管理
/**
 添加下载任务
 @param task 下载任务
 @return 结果
 */
-(BOOL)addDownLoadTaskWithTaskModel:(HGBDownLoadTask *)task;
/**
 删除下载任务

 @param taskId 下载id
 @return 结果
 */
-(BOOL)deleteDownLoadTaskWithId:(NSString *)taskId;
/**
 获取下载任务

 @param taskId 下载id
 @return 结果
 */
-(HGBDownLoadTask *)getDownLoadTaskWithId:(NSString *)taskId;
/**
 获取一组下载任务列表

 @param groupId 组别id

 @return 结果
 */
-(NSArray <HGBDownLoadTask *>*)getDownLoadTasksWithGrounpId:(NSString *)groupId;
/**
 获取下载任务列表
 @return 结果
 */
-(NSArray<HGBDownLoadTask *> *)getDownLoadTasks;
@end
