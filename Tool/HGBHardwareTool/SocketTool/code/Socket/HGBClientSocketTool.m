//
//  HGBClientSocketTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/4/22.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBClientSocketTool.h"
#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"



#ifdef DEBUG
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif
    


#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"




@interface HGBClientSocketTool()<GCDAsyncSocketDelegate>

/**
 客户端socket
 */
@property(strong,nonatomic)GCDAsyncSocket *clinetSocket;
/**
 定时器
 */
@property(strong,nonatomic)NSTimer *timer;

/**
 是否主动断开连接
 */
@property(assign,nonatomic)BOOL isMakeDisConnect;

@end

@implementation HGBClientSocketTool

#pragma mark init
/**
 单例

 @return 单例
 */
+ (instancetype)shareInstance
{
    static HGBClientSocketTool *instacne = nil;
    if (instacne==nil) {
        instacne=[[HGBClientSocketTool alloc]init];
        //初始化

        [instacne initSocket];
    }
    return instacne;
}
-(void)initSocket{
    //初始化
    if(_clinetSocket==nil){
        _clinetSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }else{
        _clinetSocket.delegate=self;
    }
}
#pragma mark 客户端
/**
 握手操作

 @param ip ip地址
 @param port 端口号
 */
- (void)connectActionIp:(NSString *)ip port:(NSString *)port {

     self.isMakeDisConnect=NO;
    self.clinetIp=ip;
    self.clinetPort=port;
    self.clinetIp=ip;
    //连接服务器
    BOOL flag=[_clinetSocket connectToHost:ip onPort:port.integerValue  withTimeout:-1 error:nil];
    self.isConnect=flag;



    //此处为链接协议初始化部分数据发送
    NSString *hostStr = [NSString stringWithFormat:@"Host: %@:%@\r\n",ip,port];

    NSMutableData *packetData = [[NSMutableData alloc] init];
    [packetData appendData:[[NSString stringWithFormat:@"GET /websocket HTTP/1.1\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];

    [packetData appendData:[hostStr dataUsingEncoding:NSUTF8StringEncoding]];

    [packetData appendData:[@"Upgrade: websocket\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    [packetData appendData:[@"Connection: Upgrade\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    [packetData appendData:[@"Sec-WebSocket-Version: 13\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    [packetData appendData:[@"Sec-WebSocket-Key: V4S42y8puxAEC5exqyu88w==\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    NSString *originStr = [NSString stringWithFormat:@"Origin: %@:%@\r\n\r\n",ip,port];
    [packetData appendData:[originStr dataUsingEncoding:NSUTF8StringEncoding]];

    [_clinetSocket writeData:packetData withTimeout:-1 tag:0];

}
/**
 客户端断开连接
 */
-(void)disconnectClient{
    self.isMakeDisConnect=YES;
    if ([_clinetSocket isConnected]) {
        [_clinetSocket disconnect];
    }
}
/**
 客户端发送数据

 @param data 数据
 */
-(void)clientSendData:(id)data{
    NSData *sendData=[HGBClientSocketTool messageEncapsulation:data];
    if(sendData==nil){
        return;
    }
    [_clinetSocket writeData:sendData withTimeout:-1 tag:0];

}
#pragma mark - GCDAsynSocket Delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{

    self.isConnect=YES;

    HGBLog(@"链接成功!!!");
    [self startMonitor];
    [_clinetSocket readDataWithTimeout:-1 tag:200];

}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {
    self.isConnect=NO;
     self.isMakeDisConnect=NO;
}
//收到消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{


    self.isConnect=YES;

    NSMutableData *mdata = [data mutableCopy];

    //此处数据处理


    //数据解码
    HGBClientSocketToolDataType type=[HGBClientSocketTool messageAnalysisToType:mdata];
    id lastData=[HGBClientSocketTool messageAnalysis:mdata];
    HGBLog(@"%d-%@",type,lastData);

    //客户端部分处理
    [_clinetSocket readDataWithTimeout:-1 tag:200];




}
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    self.isConnect=NO;
     self.isMakeDisConnect=NO;
}
-(NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length{
    return 5;
}
#pragma mark 重新链接
-(void)startMonitor{
    self.timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(heartConnect) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}
-(void)heartConnect{
     [self clientSendData:@"connect"];
    if(self.isMakeDisConnect==NO){

        [_clinetSocket connectToHost:self.clinetIp onPort:self.clinetPort.integerValue  withTimeout:-1 error:nil];
    }

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
        message=[HGBClientSocketTool ObjectToJSONString:message];
        message=[@"array://" stringByAppendingString:message];
        data=[message dataUsingEncoding:NSUTF8StringEncoding];
    }else if([message isKindOfClass:[NSDictionary class]]){
        message=[HGBClientSocketTool ObjectToJSONString:message];
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
            message=[HGBClientSocketTool JSONStringToObject:string];
        }else if ([string hasPrefix:@"dictionary://"]){
            string=[string stringByReplacingOccurrencesOfString:@"dictionary://" withString:@""];
            message=[HGBClientSocketTool JSONStringToObject:string];
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
+(HGBClientSocketToolDataType)messageAnalysisToType:(NSData *)data{
    HGBClientSocketToolDataType type;
    NSString *string=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if(string){
        if([string hasPrefix:@"array://"]){
            type=HGBClientSocketToolDataTypeArray;
        }else if ([string hasPrefix:@"dictionary://"]){
            type=HGBClientSocketToolDataTypeDictionary;
        }else if ([string hasPrefix:@"number://"]){
            type=HGBClientSocketToolDataTypeNumber;
        }else{
            type=HGBClientSocketToolDataTypeString;
        }
    }else{
        UIImage *image=[UIImage imageWithData:data];
        if(image){
            type=HGBClientSocketToolDataTypeImage;
        }else{
            type=HGBClientSocketToolDataTypeData;
        }
    }
    return type;

}
#pragma mark get
-(NSString *)clinetPort{
    if (_clinetPort==nil) {
        _clinetPort=@"8081";
    }
    return _clinetPort;
}
-(NSString *)clinetIp{
    if (_clinetIp==nil) {
        _clinetIp=@"192.168.1.102";
    }
    return _clinetIp;
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
    jsonString=[HGBClientSocketTool jsonStringHandle:jsonString];
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
