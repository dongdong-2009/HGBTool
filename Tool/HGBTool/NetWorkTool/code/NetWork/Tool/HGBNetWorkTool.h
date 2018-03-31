//
//  HGBNetWorkTool.h
//  二维码条形码识别
//
//  Created by huangguangbao on 2017/6/9.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HGBNetworkRequestHeader.h"

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif


/**
 错误类型
 */
typedef enum HGBNetWorkToolErrorType
{
    HGBNetWorkToolErrorTypeParams=0,//参数错误
    HGBNetWorkToolErrorTypeError=99,//错误
    HHGBNetWorkToolErrorTypePathError=24,//路径不合法
    HGBNetWorkToolErrorTypeExistPath=21//路径已存在

}HGBNetWorkToolErrorType;


@interface HGBNetWorkTool : NSObject
/**
 *    @brief    数据报文格式(默认FORMAT_NO).
 */
@property (nonatomic, assign) DATA_SEND_FORMAT  sendFormat;
/**
 是否设置了报文格式
 */
@property(assign,nonatomic)BOOL isSetSendFormat;
/**
 *  快捷设置报文请求头ContentType数据格式
 */
@property (nonatomic , assign)DATA_SEND_CONTENTTYPE quickContentType;
/**
 是否设置了快捷设置报文请求头ContentType数据格式
 */
@property(assign,nonatomic)BOOL isSetQuickContentType;
/**
 *    @brief    是否保存Cookie
 */
@property (nonatomic,assign) BOOL isSaveCookie;
/**
 *    @brief    是否上传报文压缩
 */
@property (nonatomic,assign) BOOL isGzip;
/**
 *    @brief    是否接收报文解压缩
 */
@property (nonatomic,assign) BOOL isUnGzip;

/**
 是否是https请求
 */
@property(assign,nonatomic)BOOL isHttps;
/**
 双向认证证书时的双向认证
 */
@property (nonatomic, copy) NSString *cerFilePath;
/**
 双向认证证书密码
 */
@property (nonatomic,copy) NSString *cerFilePassword;

/**
 请求头
 */
@property(strong,nonatomic)NSDictionary *headers;

#pragma mark 单例
+ (instancetype)shareInstance;

#pragma mark 服务
/**
 *  GET请求
 *
 *  @param url     请求路径
 *  @param params  请求参数-字典或字符串格式
 *  @param successBlock 请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failedBlock 请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
- (void)get:(NSString *)url params:(id)params andWithSuccessBlock:(NetworkRequestSuccess)successBlock failedBlock:(NetworkRequestFailed)failedBlock;
/**
 *  发送一个POST请求
 *
 *  @param url     请求路径
 *  @param params  请求参数-字典或字符串格式
 *  @param successBlock 请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failedBlock 请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
- (void)post:(NSString *)url params:(id)params andWithSuccessBlock:(NetworkRequestSuccess)successBlock failedBlock:(NetworkRequestFailed)failedBlock;

/**
 *  文件上传请求
 *
 *  @param url     请求路径
 *  @param fileData  文件数据
 *  @param fileName  文件名
 *  @param successBlock 请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failedBlock 请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
-(void)uploadFileWithUrl:(NSString *)url WithData:(NSData *)fileData fileName:(NSString *)fileName andWithSuccessBlock:(NetworkRequestSuccess)successBlock failedBlock:(NetworkRequestFailed)failedBlock;

/**
 *  图片上传请求
 *
 *  @param url     请求路径
 *  @param image   图片
 *  @param fileName  文件名
 *  @param successBlock 请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failedBlock 请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
-(void)uploadImageWithUrl:(NSString *)url WithImage:(UIImage *)image fileName:(NSString *)fileName andWithSuccessBlock:(NetworkRequestSuccess)successBlock failedBlock:(NetworkRequestFailed)failedBlock;
/**
 下载

 @param url 下载链接
 @param path 存储地址
 @param completeBlock 返回内容
 */

-(void)downLoadFileWithURL:(NSString *)url andWithStoreFile:(NSString *)path andWithCompleteBlock:(void (^)(BOOL status,NSDictionary *returnMessage))completeBlock;
@end
