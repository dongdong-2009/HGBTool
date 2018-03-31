//
//  HGBNetWorkTool.m
//  二维码条形码识别
//
//  Created by huangguangbao on 2017/6/9.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBNetWorkTool.h"
#import "HGBNetworkRequest.h"

#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"

@interface HGBNetWorkTool()

@end
@implementation HGBNetWorkTool
static HGBNetWorkTool *instance=nil;
#pragma mark init
+ (instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBNetWorkTool alloc]init];
    }
    return instance;
}

#pragma mark 服务
/**
 *  GET请求
 *
 *  @param url     请求路径
 *  @param params  请求参数-字典或字符串格式
 *  @param successBlock 请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failedBlock 请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
- (void)get:(NSString *)url params:(id)params andWithSuccessBlock:(NetworkRequestSuccess)successBlock failedBlock:(NetworkRequestFailed)failedBlock{


    HGBNetworkRequest *request = [[HGBNetworkRequest alloc]init];

    //请求配置
    request.requestMethod = @"GET";
    if(self.isSetSendFormat){
        request.sendFormat=self.sendFormat;
    }else{
        request.sendFormat=DATA_SEND_FORMAT_JSON;
    }
    if(self.isSetQuickContentType){
        request.quickContentType=self.quickContentType;
    }else{
        request.quickContentType=CONTENTTYPE_RAW;
    }
    if(self.headers&&[self.headers allKeys].count!=0){
        request.headParms=[NSMutableDictionary dictionaryWithDictionary:self.headers];
    }


    if (self.isGzip) {
        request.isGzip=self.isGzip;
    }
    if(self.isUnGzip){
        request.isUnGzip=self.isUnGzip;
    }

    //请求链接
    NSString *urlStr=url;
    if([params isKindOfClass:[NSDictionary class]]){
        NSDictionary *paramsDic=(NSDictionary *)params;
        if(paramsDic&&[paramsDic allKeys].count!=0){
            NSArray *keys=[paramsDic allKeys];
            int i=0;
            for(NSString *key in keys){
                id value=[paramsDic objectForKey:key];
                if(value==nil){
                    continue;
                }
                if(![value isKindOfClass:[NSString class]]){
                    value=[HGBNetworkRequest ObjectToJSONString:value];
                }
                if(i==0){
                    urlStr=[NSString stringWithFormat:@"%@?%@=%@",urlStr,key,value];
                }else{
                    urlStr=[NSString stringWithFormat:@"%@&%@=%@",urlStr,key,value];
                }
                i++;
            }
        }
    }else if([params isKindOfClass:[NSString class]]){
        NSString *paramsString=(NSString *)params;
        if([[paramsString substringToIndex:1] isEqualToString:@"?"]){
            url=[NSString stringWithFormat:@"%@%@",url,paramsString];
        }else{
            url=[NSString stringWithFormat:@"%@?%@",url,paramsString];
        }

    }else{
        NSError *error=[[NSError alloc]initWithDomain:@"错误" code:1999 userInfo:@{@"error":@"参数格式错误"}];
         failedBlock(error);
        return;
    }
    request.requestUrl=urlStr;


    //请求
    [request requestWithSuccessBlock:^(id responseObject) {
        successBlock(responseObject);
    
    } failedBlock:^(NSError *error) {
        failedBlock(error);
    }];
}
/**
 *  发送一个POST请求
 *
 *  @param url     请求路径
 *  @param params  请求参数-字典或字符串格式
 *  @param successBlock 请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failedBlock 请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
- (void)post:(NSString *)url params:(id)params andWithSuccessBlock:(NetworkRequestSuccess)successBlock failedBlock:(NetworkRequestFailed)failedBlock{

    if(params==nil){
        params=@{};
    }
    
    HGBNetworkRequest *request = [[HGBNetworkRequest alloc]init];

    //请求链接
    request.requestUrl=url;

    //请求配置
    request.requestMethod = @"POST";

    if(self.isSetSendFormat){
        request.sendFormat=self.sendFormat;
    }else{
        request.sendFormat=DATA_SEND_FORMAT_NO;
    }
    if(self.isSetQuickContentType){
        request.quickContentType=self.quickContentType;
    }else{
        request.quickContentType=CONTENTTYPE_RAW;
    }
    if(self.headers&&[self.headers allKeys].count!=0){
        request.headParms=[NSMutableDictionary dictionaryWithDictionary:self.headers];
    }
    if (self.isGzip) {
        request.isGzip=self.isGzip;
    }
    if(self.isUnGzip){
        request.isUnGzip=self.isUnGzip;
    }

    NSString *jsonString;
    //请求参数
    if([params isKindOfClass:[NSDictionary class]]){
        NSDictionary *paramsDic=(NSDictionary *)params;

        jsonString=[HGBNetworkRequest ObjectToJSONString:paramsDic];

    }else if([params isKindOfClass:[NSString class]]){
        jsonString=(NSString *)params;
    }else{
        NSError *error=[[NSError alloc]initWithDomain:@"错误" code:1999 userInfo:@{@"error":@"参数格式错误"}];
        failedBlock(error);
        return;
    }
    [request appendBodyParma:jsonString];

    //请求
    [request requestWithSuccessBlock:^(id responseObject) {
        successBlock(responseObject);
        
    } failedBlock:^(NSError *error) {
        failedBlock(error);
    }];
}

/**
 *  文件上传请求
 *
 *  @param url     请求路径
 *  @param fileData  文件数据
 *  @param fileName  文件名
 *  @param successBlock 请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failedBlock 请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
-(void)uploadFileWithUrl:(NSString *)url WithData:(NSData *)fileData fileName:(NSString *)fileName andWithSuccessBlock:(NetworkRequestSuccess)successBlock failedBlock:(NetworkRequestFailed)failedBlock{
    
    
    HGBNetworkRequest *request = [[HGBNetworkRequest alloc]init];

    //请求链接
    request.requestUrl = url;


    //请求配置
    request.requestMethod = @"POST";
    request.quickContentType=CONTENTTYPE_FILEDATA;

    //请求参数
    request.updateName=@"uploadFile";
    request.fileData=fileData;
    request.fileName=fileName;
    if (self.isGzip) {
        request.isGzip=self.isGzip;
    }

    //请求
    [request requestWithSuccessBlock:^(id responseObject) {
        successBlock(responseObject);
        
    } failedBlock:^(NSError *error) {
        failedBlock(error);
        
    }];
}
/**
 *  图片上传请求
 *
 *  @param url     请求路径
 *  @param image   图片
 *  @param fileName  文件名
 *  @param successBlock 请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failedBlock 请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
-(void)uploadImageWithUrl:(NSString *)url WithImage:(UIImage *)image fileName:(NSString *)fileName andWithSuccessBlock:(NetworkRequestSuccess)successBlock failedBlock:(NetworkRequestFailed)failedBlock{


    //参数转换
    NSData *fileData = UIImageJPEGRepresentation(image,0);
    UIImage *fileImage=image;
    while ((fileData.length / 1024) > 1000) {
        fileImage = [HGBNetWorkTool scaleImage:fileImage toScale:0.5];
        fileData = UIImageJPEGRepresentation(fileImage, 1);
    }


    HGBNetworkRequest *request = [[HGBNetworkRequest alloc]init];
    //请求链接
    request.requestUrl = url;

    //请求配置
    request.requestMethod = @"POST";

    request.quickContentType=CONTENTTYPE_FILEDATA;

    //请求参数
    request.updateName=@"uploadFile";
    request.fileData=fileData;
    request.fileName=fileName;
    
    if((!fileData)||fileName.length==0||fileName==nil){
        failedBlock(nil);
        return;
    }


    //请求
    [request requestWithSuccessBlock:^(id responseObject) {
        successBlock(responseObject);
        
    } failedBlock:^(NSError *error) {
        failedBlock(error);
        
    }];
}
/**
 下载

 @param url 下载链接
 @param path 存储地址
 @param completeBlock 返回内容
 */

-(void)downLoadFileWithURL:(NSString *)url andWithStoreFile:(NSString *)path andWithCompleteBlock:(void (^)(BOOL status,NSDictionary *returnMessage))completeBlock{

    if(url==nil||url.length==0){
        completeBlock(NO,@{ReslutCode:@(HGBNetWorkToolErrorTypeParams).stringValue,ReslutMessage:@"参数错误"});
        return;
    }
    NSString *filePath;
    if(path==nil||path.length==0){
        filePath=[NSString stringWithFormat:@"document://%@.%@",[HGBNetWorkTool getSecondTimeStringSince1970],[url pathExtension]];
        filePath=[HGBNetWorkTool urlAnalysisToPath:filePath];
    }else{
        filePath=[HGBNetWorkTool urlAnalysisToPath:path];
        if([HGBNetWorkTool isExitAtFilePath:filePath]){
            completeBlock(NO,@{ReslutCode:@(HGBNetWorkToolErrorTypeExistPath).stringValue,ReslutMessage:@"下载保存地址已存在"});
            return;
        }

    }
    if(![filePath hasPrefix:NSHomeDirectory()]){
        completeBlock(NO,@{ReslutCode:@(HHGBNetWorkToolErrorTypePathError).stringValue,ReslutMessage:@"下载保存地址无效"});
        return;
    }
    NSString *directoryPath=[filePath stringByDeletingLastPathComponent];
    if(![HGBNetWorkTool isExitAtFilePath:directoryPath]){
        [HGBNetWorkTool createDirectoryPath:directoryPath];
    }
    NSURL *downloadURL=[NSURL URLWithString:url];
    NSURLSession *session=[NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask=[session downloadTaskWithURL:downloadURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
             completeBlock(NO,@{ReslutCode:@(error.code).stringValue,ReslutMessage:error.localizedDescription});
        }else{
            NSFileManager *f=[NSFileManager defaultManager];
            BOOL flag=[f moveItemAtPath:[location path] toPath:filePath error:nil];
            if(flag){
                completeBlock(YES,@{@"path":filePath,@"url":[HGBNetWorkTool urlEncapsulation:filePath]});
            }else{
                completeBlock(NO,@{ReslutCode:@(HGBNetWorkToolErrorTypeError).stringValue,ReslutMessage:@"下载失败"});
            }
        }


    }];

    [downloadTask resume];
}
#pragma mark 文件
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
/**
 创建文件夹

 @param directoryPath 路径
 @return 结果
 */
+(BOOL)createDirectoryPath:(NSString *)directoryPath{
    if([HGBNetWorkTool isExitAtFilePath:directoryPath]){
        return YES;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];
    BOOL flag=[filemanage createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:nil];
    if(flag){
        return YES;
    }else{
        return NO;
    }
}
#pragma mark 工具类
/**
 图片压缩

 @param image image
 @param scaleSize 比例
 @return 图片
 */
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    image = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationUp];
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
#pragma mark 时间
/**
 获取时间戳-秒级

 @return 秒级时间戳
 */
+ (NSString *)getSecondTimeStringSince1970
{
    NSDate* date = [NSDate date];
    NSTimeInterval interval=[date timeIntervalSince1970];  //  *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%f", interval]; //转为字符型
    NSString *timeStr = [NSString stringWithFormat:@"%lf",[timeString doubleValue]*1000000];

    if(timeStr.length>=16){
        return [timeStr substringToIndex:16];
    }else{
        return timeStr;
    }
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
    if(![HGBNetWorkTool isURL:url]){
        return nil;
    }
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
    if(![HGBNetWorkTool isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBNetWorkTool urlAnalysis:url];
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
    if(![HGBNetWorkTool isURL:url]){
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
    if(![HGBNetWorkTool isURL:url]){
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
