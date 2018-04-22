//
//  HGBServerSocketTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/4/22.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>




#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif



/**
 数据类型
 */
typedef enum HGBServerSocketToolDataType
{
    HGBServerSocketToolDataTypeData,//二进制数据
    HGBServerSocketToolDataTypeImage,//图片
    HGBServerSocketToolDataTypeDictionary,//字典
    HGBServerSocketToolDataTypeArray,//数组
    HGBServerSocketToolDataTypeString,//字符串
    HGBServerSocketToolDataTypeNumber//数字
}HGBServerSocketToolDataType;



@interface HGBServerSocketTool : NSObject
#pragma mark 服务端
/**
 是否已监听
 */
@property(assign,nonatomic)BOOL isListen;
/**
 服务端ip
 */
@property(strong,nonatomic)NSString *serverIp;
/**
 服务端端口
 */
@property(strong,nonatomic)NSString *serverPort;
/**
 单例

 @return 单例
 */
+ (instancetype)shareInstance;
#pragma mark 服务端
/**
 建立socket监听

 @param port 端口号
 @return 接口
 */

-(BOOL)listenToPort:(NSString *)port;
/**
 服务端断开连接
 */
-(void)disconnectServer;
/**
 服务端发送数据

 @param data 数据
 */
-(void)serverSendData:(id)data;
@end
