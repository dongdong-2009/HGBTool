//
//  HGBClientSocketTool.h
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
typedef enum HGBClientSocketToolDataType
{
    HGBClientSocketToolDataTypeData,//二进制数据
    HGBClientSocketToolDataTypeImage,//图片
    HGBClientSocketToolDataTypeDictionary,//字典
    HGBClientSocketToolDataTypeArray,//数组
    HGBClientSocketToolDataTypeString,//字符串
    HGBClientSocketToolDataTypeNumber//数字
}HGBClientSocketToolDataType;



@interface HGBClientSocketTool : NSObject


/**
 是否链接
 */
@property(assign,nonatomic)BOOL isConnect;
/**
 客户端ip
 */
@property(strong,nonatomic)NSString *clinetIp;
/**
 客户端端口
 */
@property(strong,nonatomic)NSString *clinetPort;

/**
 单例

 @return 单例
 */
+ (instancetype)shareInstance;

/**
 握手操作

 @param ip ip地址
 @param port 端口号
 */
- (void)connectActionIp:(NSString *)ip port:(NSString *)port;
/**
 客户端断开连接
 */
-(void)disconnectClient;
/**
 客户端发送数据

 @param data 数据
 */
-(void)clientSendData:(id)data;
@end
