//
//  HGBServerSocketTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/4/22.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBServerSocketTool.h"

#import <UIKit/UIKit.h>

#import "GCDAsyncSocket.h"

#ifdef DEBUG
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif



#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"




@interface HGBServerSocketTool()<GCDAsyncSocketDelegate>

#pragma mark 服务端
/**
 服务端socket
 */
@property (strong, nonatomic) GCDAsyncSocket *serverSocket;
/**
 是否主动断开连接
 */
@property(assign,nonatomic)BOOL isMakeDisConnect;



@end

@implementation HGBServerSocketTool

#pragma mark init
/**
 单例

 @return 单例
 */
+ (instancetype)shareInstance
{
    static HGBServerSocketTool *instacne = nil;
    if (instacne==nil) {
        instacne=[[HGBServerSocketTool alloc]init];
        //初始化

        [instacne initSocket];
    }
    return instacne;
}
-(void)initSocket{
    //初始化
    if(_serverSocket==nil){
        _serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }else{
        _serverSocket.delegate=self;
    }
}
#pragma mark 服务端
/**
 建立socket监听

 @param port 端口号
 @return 接口
 */

-(BOOL)listenToPort:(NSString *)port{
    if(port==nil||port.length==0){
        return NO;
    }
    self.serverPort=port;
    NSError *error = nil;
    [_serverSocket acceptOnPort:port.integerValue error:&error];

    //3.开启服务(实质第二步绑定端口的同时默认开启服务)
    if (error == nil)
    {

        HGBLog(@"开启成功");
        self.isListen=YES;
        return YES;
    }
    else
    {

        HGBLog(@"开启失败");
        self.isListen=NO;
         return NO;
    }
}
/**
 服务端断开连接
 */
-(void)disconnectServer{
    if ([_serverSocket isConnected]) {
        [_serverSocket disconnect];
    }
}
/**
 服务端发送数据

 @param data 数据
 */
-(void)serverSendData:(id)data{
    NSData *sendData=[HGBServerSocketTool messageEncapsulation:data];
    if(sendData==nil){
        return;
    }
    [_serverSocket writeData:sendData withTimeout:-1 tag:0];

}

#pragma mark - GCDAsynSocket Delegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    self.isListen=YES;
    //sock 服务端的socket
    //newSocket 客户端连接的socket
    HGBLog(@"%@----%@",sock, newSocket);


    NSString *commond;
    //此处返回服务端初始化信息
    [newSocket writeData:[commond dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];

    //2.监听客户端有没有数据上传
    //-1代表不超时
    //tag标示作用
    [newSocket readDataWithTimeout:-1 tag:0];
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{


    HGBLog(@"链接成功!!!");
    [_serverSocket readDataWithTimeout:-1 tag:200];

}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {
    self.isListen=NO;
}
//收到消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{


    self.isListen=YES;

    NSMutableData *mdata = [data mutableCopy];

    //此处数据处理


    //数据解码
    HGBServerSocketToolDataType type=[HGBServerSocketTool messageAnalysisToType:mdata];
    id lastData=[HGBServerSocketTool messageAnalysis:mdata];
    HGBLog(@"%d-%@",type,lastData);

    [_serverSocket readDataWithTimeout:-1 tag:200];




}
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    self.isListen=NO;
}
-(NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length{
    return 5;
}

#pragma mark 数据格式转换
/**
 数据编码

 @param message 数据
 @return data
 */
+(NSData *)messageEncapsulation:(id)message{
    NSData *data;
    if([message isKindOfClass:[NSData class]]){
        data=message;
    }else if([message isKindOfClass:[NSString class]]){
        data=[message dataUsingEncoding:NSUTF8StringEncoding];
    }else if([message isKindOfClass:[NSArray class]]){
        message=[HGBServerSocketTool ObjectToJSONString:message];
        message=[@"array://" stringByAppendingString:message];
        data=[message dataUsingEncoding:NSUTF8StringEncoding];
    }else if([message isKindOfClass:[NSDictionary class]]){
        message=[HGBServerSocketTool ObjectToJSONString:message];
        message=[@"dictionary://" stringByAppendingString:message];
        data=[message dataUsingEncoding:NSUTF8StringEncoding];
    }else if([message isKindOfClass:[UIImage class]]){
        data=UIImagePNGRepresentation(message);
    }else if([message isKindOfClass:[NSNumber class]]){
        message=[NSString stringWithFormat:@"number://%@",message];
        data=[message dataUsingEncoding:NSUTF8StringEncoding];
    }
    return data;
}
/**
 数据解码

 @param data 数据
 @return 解码后数据
 */
+(id)messageAnalysis:(NSData *)data{
    id message;
    NSString *string=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if(string){
        if([string hasPrefix:@"array://"]){
            string=[string stringByReplacingOccurrencesOfString:@"array://" withString:@""];
            message=[HGBServerSocketTool JSONStringToObject:string];
        }else if ([string hasPrefix:@"dictionary://"]){
            string=[string stringByReplacingOccurrencesOfString:@"dictionary://" withString:@""];
            message=[HGBServerSocketTool JSONStringToObject:string];
        }else if ([string hasPrefix:@"number://"]){
            string=[string stringByReplacingOccurrencesOfString:@"number://" withString:@""];
            message=[[NSNumber alloc]initWithFloat:string.floatValue];
        }else{
            message=string;
        }
    }else{
        UIImage *image=[UIImage imageWithData:data];
        if(image){
            message=image;
        }else{
            message=data;
        }
    }
    return message;

}
/**
 数据解密后类型

 @param data 数据
 @return 解码后数据
 */
+(HGBServerSocketToolDataType)messageAnalysisToType:(NSData *)data{
    HGBServerSocketToolDataType type;
    NSString *string=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if(string){
        if([string hasPrefix:@"array://"]){
            type=HGBServerSocketToolDataTypeArray;
        }else if ([string hasPrefix:@"dictionary://"]){
            type=HGBServerSocketToolDataTypeDictionary;
        }else if ([string hasPrefix:@"number://"]){
            type=HGBServerSocketToolDataTypeNumber;
        }else{
            type=HGBServerSocketToolDataTypeString;
        }
    }else{
        UIImage *image=[UIImage imageWithData:data];
        if(image){
            type=HGBServerSocketToolDataTypeImage;
        }else{
            type=HGBServerSocketToolDataTypeData;
        }
    }
    return type;

}
#pragma mark get

-(NSString *)serverPort{
    if (_serverPort==nil) {
        _serverPort=@"8081";
    }
    return _serverPort;
}
-(NSString *)serverIp{
    if (_serverIp==nil) {
        _serverIp=@"192.168.1.102";
    }
    return _serverIp;
}
#pragma mark json
/**
 把Json对象转化成json字符串

 @param object json对象
 @return json字符串
 */
+ (NSString *)ObjectToJSONString:(id)object
{
    if(!([object isKindOfClass:[NSDictionary class]]||[object isKindOfClass:[NSArray class]]||[object isKindOfClass:[NSString class]])){
        return nil;
    }
    if([object isKindOfClass:[NSString class]]){
        return object;
    }
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return myString;
}
/**
 把Json字符串转化成json对象

 @param jsonString json字符串
 @return json字符串
 */
+ (id)JSONStringToObject:(NSString *)jsonString{
    if(![jsonString isKindOfClass:[NSString class]]){
        return nil;
    }
    jsonString=[HGBServerSocketTool jsonStringHandle:jsonString];
    NSError *error = nil;
    NSData  *data=[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if(jsonString.length>0&&[[jsonString substringToIndex:1] isEqualToString:@"{"]){
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if(error){
            HGBLog(@"%@",error);
            return jsonString;
        }else{
            return dic;
        }
    }else if(jsonString.length>0&&[[jsonString substringToIndex:1] isEqualToString:@"["]){
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if(error){
            HGBLog(@"%@",error);
            return jsonString;
        }else{
            return array;
        }
    }else{
        return jsonString;
    }


}
/**
 json字符串处理

 @param jsonString 字符串处理
 @return 处理后字符串
 */
+(NSString *)jsonStringHandle:(NSString *)jsonString{
    NSString *string=jsonString;
    //大括号

    //中括号
    while ([string containsString:@"【"]) {
        string=[string stringByReplacingOccurrencesOfString:@"【" withString:@"]"];
    }
    while ([string containsString:@"】"]) {
        string=[string stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
    }

    //小括弧
    while ([string containsString:@"（"]) {
        string=[string stringByReplacingOccurrencesOfString:@"（" withString:@"("];
    }

    while ([string containsString:@"）"]) {
        string=[string stringByReplacingOccurrencesOfString:@"）" withString:@")"];
    }


    while ([string containsString:@"("]) {
        string=[string stringByReplacingOccurrencesOfString:@"(" withString:@"["];
    }

    while ([string containsString:@")"]) {
        string=[string stringByReplacingOccurrencesOfString:@")" withString:@"]"];
    }


    //逗号
    while ([string containsString:@"，"]) {
        string=[string stringByReplacingOccurrencesOfString:@"，" withString:@","];
    }
    while ([string containsString:@";"]) {
        string=[string stringByReplacingOccurrencesOfString:@";" withString:@","];
    }
    while ([string containsString:@"；"]) {
        string=[string stringByReplacingOccurrencesOfString:@"；" withString:@","];
    }
    //引号
    while ([string containsString:@"“"]) {
        string=[string stringByReplacingOccurrencesOfString:@"“" withString:@"\""];
    }
    while ([string containsString:@"”"]) {
        string=[string stringByReplacingOccurrencesOfString:@"”" withString:@"\""];
    }
    while ([string containsString:@"‘"]) {
        string=[string stringByReplacingOccurrencesOfString:@"‘" withString:@"\""];
    }
    while ([string containsString:@"'"]) {
        string=[string stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    }
    //冒号
    while ([string containsString:@"："]) {
        string=[string stringByReplacingOccurrencesOfString:@"：" withString:@":"];
    }
    //等号
    while ([string containsString:@"="]) {
        string=[string stringByReplacingOccurrencesOfString:@"=" withString:@":"];
    }
    while ([string containsString:@"="]) {
        string=[string stringByReplacingOccurrencesOfString:@"=" withString:@":"];
    }
    return string;

}

@end
