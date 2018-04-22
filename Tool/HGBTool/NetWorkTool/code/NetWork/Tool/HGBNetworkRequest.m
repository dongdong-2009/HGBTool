//
//  HGBNetworkRequest.m
//  网络框架
//
//  Created by huangguangbao on 2017/6/8.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBNetworkRequest.h"

#if __has_include(<AFNetworking.h>)
#import <AFNetworking.h>
#else
#import "AFNetworking.h"
#endif
#import "HGBGZip.h"


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

@interface HGBNetworkRequest ()
/**
 网络请求管理类
 */
@property (nonatomic,strong)AFURLSessionManager *manager;


/**
 成功回调
 */
@property (nonatomic,copy)NetworkRequestSuccess successBlock;
/**
 失败回调
 */
@property (nonatomic,copy)NetworkRequestFailed failedBlock;
/**
 *	@brief	是否需要https.
 */
@property (nonatomic,assign) BOOL isHttps;


@end
@implementation HGBNetworkRequest
#pragma mark init
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        self.manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:configuration];
        self.requestUrl = [NSString stringWithFormat:@"%@",@""];
        self.requestMethod = @"POST";
        self.sendFormat =DATA_SEND_FORMAT_NO ;
        self.mineType=@"image/jpeg";
        self.updateName=@"uploadFile";
    }
    return self;
}
#pragma mark 证书
/**
 *	@brief	双向认证设置证书.
 *  证书为P12.
 *
 *	@param 	cerFilePath 	证书路径.
 *  @param  cerPassword     证书密码.
 */
- (void)setHttpsBidirectionalAuthCertificateFilePath:(NSString *)cerFilePath cerPassword:(NSString *)cerPassword
{
    self.cerFilePath = cerFilePath;
    self.cerFilePassword = cerPassword;
    if (self.cerFilePath) {
        //         准备：将证书的二进制读取，放入set中
        NSString *url = [HGBNetworkRequest urlAnalysis:cerFilePath];
        NSData *cerData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
        NSSet *set = [[NSSet alloc] initWithObjects:cerData, nil];
        self.manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:set]; // 关键语句1
        self.manager.securityPolicy.allowInvalidCertificates = YES; // 关键语句2
    }
}
#pragma mark 参数
/**
 *	@brief	添加请求body标准(":")格式参数.
 *
 *	@param 	parma 	参数名.
 *	@param 	value 	参数数据值.
 */
- (void)appendFormatBodyParma:(NSString *)parma value:(id)value
{
    if (!_bodyParams) {
        _bodyParams = [NSString stringWithFormat:@"%@:%@",parma,value];
    }else{
        _bodyParams = [_bodyParams stringByAppendingFormat:@"&%@:%@",parma,value];
    }
}
/**
 *	@brief	添加请求body"="格式参数.
 *
 *	@param 	parma 	参数名.
 *	@param 	value 	参数数据值.
 */
- (void)appendEqualBodyParma:(NSString *)parma value:(id)value
{
    if (!_bodyParams) {
        _bodyParams = [NSString stringWithFormat:@"%@=%@",parma,value];
    }else{
        _bodyParams = [_bodyParams stringByAppendingFormat:@"&%@=%@",parma,value];
    }
}
/**
 *	@brief	添加请求body自定义格式参数.
 *
 *	@param 	parma 	参数字符串
 */
- (void)appendBodyParma:(id)parma
{
    if (!_bodyParams) {
        _bodyParams = [NSString stringWithFormat:@"%@",parma];
    }else{
        _bodyParams = [_bodyParams stringByAppendingFormat:@"%@",parma];
    }
}

#pragma mark - block机制支持
/**
 *	@brief	设置回调block
 *
 *	@param 	successBlock 	成功block
 *	@param 	failedBlock 	失败block
 */
- (void)requestWithSuccessBlock:(NetworkRequestSuccess)successBlock failedBlock:(NetworkRequestFailed)failedBlock
{
    
    self.successBlock = successBlock;
    self.failedBlock = failedBlock;


    self.requestUrl=[HGBNetworkRequest transToUrlFormatString:self.requestUrl];

    if([self.requestUrl containsString:@"https://"]){
        self.isHttps=YES;
    }else{
        self.isHttps=NO;
    }

    if(self.quickContentType!=CONTENTTYPE_FILEDATA){
        if(self.pramDic&&[self.pramDic allKeys].count>0){
            self.bodyParams=[HGBNetworkRequest ObjectToJSONString:self.pramDic];
        }
    }

    /*-----------------报文发送格式---------------------*/
    if (self.sendFormat == DATA_SEND_FORMAT_NO) {
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }else if (self.sendFormat == DATA_SEND_FORMAT_JSON){
        /*
         - `application/json`
         - `text/json`
         - `text/javascript`
         */
        self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }else if (self.sendFormat == DATA_SEND_FORMAT_XML){
        /*
         - `application/xml`
         - `text/xml`
         */
        self.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    }


    /*-----------------请求协议类型---------------------*/
    if (self.isHttps) {
        if(self.cerFilePath==nil||self.cerFilePath.length==0){
            self.manager.securityPolicy.validatesDomainName = NO;
            self.manager.securityPolicy.allowInvalidCertificates = YES;
        }else{
            self.cerFilePath=[HGBNetworkRequest urlAnalysis:self.cerFilePath];
            if(![HGBNetworkRequest urlExistCheck:self.cerFilePath]){
                self.manager.securityPolicy.validatesDomainName = NO;
                self.manager.securityPolicy.allowInvalidCertificates = YES;
            }else{
                [self setHttpsBidirectionalAuthCertificateFilePath:self.cerFilePath cerPassword:self.cerFilePassword];
            }
        }
    }
    HGBLog(@"requestUrl-%@",self.requestUrl);
    HGBLog(@"bodyParams-%@",self.bodyParams);
    HGBLog(@"headParms-%@",self.headParms);


    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:self.requestUrl] cachePolicy:(NSURLRequestReloadIgnoringLocalAndRemoteCacheData) timeoutInterval:120];
    
    request.HTTPMethod = self.requestMethod;
    

    /*-----------------请求方式---------------------*/
    if ([self.requestMethod isEqualToString:@"GET"]) {
    }else{
        if(self.quickContentType==CONTENTTYPE_NO){
            self.bodyParams = [HGBNetworkRequest stringEncodingWithStr:self.bodyParams];
        }
        NSData *data=[self.bodyParams dataUsingEncoding:NSUTF8StringEncoding];
        if (self.isGzip) {
            data=[HGBGZip gzipData:data];
            [request setValue:@"GZip" forHTTPHeaderField:@" Content-Encoding"];

        }
        [request setHTTPBody:data];
    }
    /*-----------------报文格式---------------------*/
    if (self.quickContentType==CONTENTTYPE_RAW){
        //设置Content-Type
        NSString *strContentType = [NSString stringWithFormat:@"application/raw;charset=utf-8"];
        [request setValue:strContentType forHTTPHeaderField:@"Content-Type"];
    }else if (self.quickContentType==CONTENTTYPE_X_W_FORMUNENCODE){
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
    }else if (self.quickContentType==CONTENTTYPE_FORMAT){
        [request setValue:@"application/form-data" forHTTPHeaderField:@"Content-Type"];
    }else if(self.quickContentType==CONTENTTYPE_FILEDATA){
        //文件上传数据
        if (self.fileData.length > 0) {
            request.HTTPBody = self.fileData;
            HGBLog(@"%@-%@-%@",self.fileName,self.updateName,self.mineType);
            
            request=[[AFHTTPRequestSerializer serializer]multipartFormRequestWithMethod:@"POST" URLString:self.requestUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                if(self.mineType&&self.mineType.length!=0){
                    [formData appendPartWithFileData:self.fileData name:self.updateName fileName:self.fileName mimeType:self.mineType];
                }else{
                    [formData appendPartWithFormData:self.fileData name:self.updateName];
                    
                }
                if(self.pramDic&&[self.pramDic allKeys].count>0){
                    NSArray *keys=[self.pramDic allKeys];
                    for(NSString *key in keys){
                        NSString *obj=[self.pramDic objectForKey:key];
                        [formData appendPartWithFormData:[obj dataUsingEncoding:NSUTF8StringEncoding] name:key];
                    }
                }
            } error:nil];
            return;
        }
    }

    /*-----------------请求头---------------------*/
    NSArray *keyArr = [self.headParms allKeys];
    if ([keyArr count] > 0) {
        for (NSString *key in keyArr) {
            [request setValue:[self.headParms objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    NSURLSessionDataTask *dataTask = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if(self.isSaveCookie){
            [HGBNetworkRequest saveCookieTolocal];
        }
        if (error) {
            HGBLog(@"Error: %@", error.description);
            failedBlock(error);
            if(error.code==-1009||[error.localizedDescription containsString:@"断开"]){
                
            }
            
        } else {
            NSData *data=responseObject;
            if (self.isUnGzip&&[responseObject isKindOfClass:[NSData class]]) {
                 NSString *encode = [response textEncodingName];
                if ([encode isEqualToString:@"GZip"]) {
                     data=[HGBGZip ungzipData:data];
                }

            }
             successBlock(data);
            

        }
    }];
    [dataTask resume];
    
}
#pragma mark 工具
/**
 把Json对象转化成json字符串
 
 @param object json对象
 @return json字符串
 */
+ (NSString *)ObjectToJSONString:(id)object
{
    if(!([object isKindOfClass:[NSDictionary class]]||[object isKindOfClass:[NSArray class]]||[object isKindOfClass:[NSString class]])){
        return @"";
    }
    if([object isKindOfClass:[NSString class]]){
        return object;
    }
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return myString;
}
/**
 字符串编码

 @param str 原字符串
 @return 编码后字符串
 */
+(NSString *)stringEncodingWithStr:(NSString *)str
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, (CFStringRef)@"!NULL,'()*+,-./:;=?@_~%#[]", NULL, kCFStringEncodingUTF8));
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    return encodedString;
}
/**
 *  url空格处理
 *
 *  @param urlStr 原url
 *
 *  @return 新url
 */
+(NSString *)transToUrlFormatString:(NSString *)urlStr{
    return [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

/**
 *  把cookie保存到本地
 */
+ (void)saveCookieTolocal
{
    NSMutableArray *cookieArray = [[NSMutableArray alloc] init];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [cookieArray addObject:cookie.name];
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        [cookieProperties setObject:cookie.name forKey:NSHTTPCookieName];
        [cookieProperties setObject:cookie.value forKey:NSHTTPCookieValue];
        [cookieProperties setObject:cookie.domain forKey:NSHTTPCookieDomain];
        [cookieProperties setObject:cookie.path forKey:NSHTTPCookiePath];
        [cookieProperties setObject:[NSNumber numberWithInteger:cookie.version] forKey:NSHTTPCookieVersion];
        
        [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
        
        [[NSUserDefaults standardUserDefaults] setValue:cookieProperties forKey:cookie.name];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:cookieArray forKey:@"cookieArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
/**
 文档是否存在

 @param filePath 文件路径
 @return 结果
 */
+(BOOL)isExitAtFilePath:(NSString *)filePath{
    if(filePath==nil||filePath.length==0){
        return NO;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL isExit=[filemanage fileExistsAtPath:filePath];
    return isExit;
}
#pragma mark url
/**
 判断路径是否是URL

 @param url url路径
 @return 结果
 */
+(BOOL)isURL:(NSString*)url{
    if([url hasPrefix:@"project://"]||[url hasPrefix:@"home://"]||[url hasPrefix:@"document://"]||[url hasPrefix:@"caches://"]||[url hasPrefix:@"tmp://"]||[url hasPrefix:@"defaults://"]||[url hasPrefix:@"/User"]||[url hasPrefix:@"/var"]||[url hasPrefix:@"http://"]||[url hasPrefix:@"https://"]||[url hasPrefix:@"file://"]){
        return YES;
    }else{
        return NO;
    }
}
/**
 url校验存在

 @param url url
 @return 是否存在
 */
+(BOOL)urlExistCheck:(NSString *)url{
    if(url==nil||url.length==0){
        return NO;
    }
    if(![HGBNetworkRequest isURL:url]){
        return NO;
    }
    url=[HGBNetworkRequest urlAnalysis:url];
    if(![url containsString:@"://"]){
        url=[[NSURL fileURLWithPath:url]absoluteString];
    }
    if([url hasPrefix:@"file://"]){
        NSString *filePath=[[NSURL URLWithString:url]path];
        if(filePath==nil||filePath.length==0){
            return NO;
        }
        NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
        return [filemanage fileExistsAtPath:filePath];
    }else{
        NSURL *urlCheck=[NSURL URLWithString:url];

        return [[UIApplication sharedApplication]canOpenURL:urlCheck];

    }
}
/**
 url解析

 @return 解析后url
 */
+(NSString *)urlAnalysisToPath:(NSString *)url{
    if(url==nil){
        return nil;
    }
    if(![HGBNetworkRequest isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBNetworkRequest urlAnalysis:url];
    return [[NSURL URLWithString:urlstr]path];
}
/**
 url解析

 @return 解析后url
 */
+(NSString *)urlAnalysis:(NSString *)url{
    if(url==nil){
        return nil;
    }
    if(![HGBNetworkRequest isURL:url]){
        return nil;
    }
    if([url containsString:@"://"]){
        //project://工程包内
        //home://沙盒路径
        //http:// https://网络路径
        //document://沙盒Documents文件夹
        //caches://沙盒Caches
        //tmp://沙盒Tmp文件夹
        if([url hasPrefix:@"project://"]||[url hasPrefix:@"home://"]||[url hasPrefix:@"document://"]||[url hasPrefix:@"defaults://"]||[url hasPrefix:@"caches://"]||[url hasPrefix:@"tmp://"]){
            if([url hasPrefix:@"project://"]){
                url=[url stringByReplacingOccurrencesOfString:@"project://" withString:@""];
                NSString *projectPath=[[NSBundle mainBundle]resourcePath];
                url=[projectPath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"home://"]){
                url=[url stringByReplacingOccurrencesOfString:@"home://" withString:@""];
                NSString *homePath=NSHomeDirectory();
                url=[homePath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"document://"]){
                url=[url stringByReplacingOccurrencesOfString:@"document://" withString:@""];
                NSString  *documentPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
                url=[documentPath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"defaults://"]){
                url=[url stringByReplacingOccurrencesOfString:@"defaults://" withString:@""];
                NSString  *documentPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
                url=[documentPath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"caches://"]){
                url=[url stringByReplacingOccurrencesOfString:@"caches://" withString:@""];
                NSString  *cachesPath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) lastObject];
                url=[cachesPath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"tmp://"]){
                url=[url stringByReplacingOccurrencesOfString:@"tmp://" withString:@""];
                NSString *tmpPath =NSTemporaryDirectory();
                url=[tmpPath stringByAppendingPathComponent:url];
            }
            url=[[NSURL fileURLWithPath:url]absoluteString];

        }else{

        }
    }else {
        url=[[NSURL fileURLWithPath:url]absoluteString];
    }
    return url;
}
/**
 url封装

 @return 封装后url
 */
+(NSString *)urlEncapsulation:(NSString *)url{
    if(![HGBNetworkRequest isURL:url]){
        return nil;
    }
    NSString *homePath=NSHomeDirectory();
    NSString  *documentPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
    NSString  *cachesPath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) lastObject];
    NSString *projectPath=[[NSBundle mainBundle]resourcePath];
    NSString *tmpPath =NSTemporaryDirectory();

    if([url hasPrefix:@"file://"]){
        url=[url stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    }
    if([url hasPrefix:projectPath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",projectPath] withString:@"project://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",projectPath] withString:@"project://"];
    }else if([url hasPrefix:documentPath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",documentPath] withString:@"defaults://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",documentPath] withString:@"defaults://"];
    }else if([url hasPrefix:cachesPath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",cachesPath] withString:@"caches://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",cachesPath] withString:@"caches://"];
    }else if([url hasPrefix:tmpPath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",tmpPath] withString:@"tmp://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",tmpPath] withString:@"tmp://"];
    }else if([url hasPrefix:homePath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",homePath] withString:@"home://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",homePath] withString:@"home://"];
    }else if([url containsString:@"://"]){

    }else{
        url=[[NSURL fileURLWithPath:url]absoluteString];
    }
    return url;
}
@end
