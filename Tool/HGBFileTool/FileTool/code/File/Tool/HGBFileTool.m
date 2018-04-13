//
//  HGBFileTool.m
//  二维码条形码识别
//
//  Created by huangguangbao on 2017/6/9.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBFileTool.h"
#import "HGBFileBase64.h"

#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>
#import <UIKit/UIKit.h>


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif



static NSString *SFHFKeychainUtilsErrorDomain = @"SFHFKeychainUtilsErrorDomain";


@implementation HGBFileTool
#pragma mark 文件归档和反归档-普通
/**
 归档-普通

 @param object 要归档的数据
 @param destination 归档的路径或url
 @return 保存结果
 */
+ (BOOL)archiverWithObject:(id)object toDestination:(NSString *)destination
{
    if(destination==nil||destination.length==0){
        HGBLog(@"目标文件地址不能为空");
        return NO;
    }
    if(object==nil){
        HGBLog(@"数据不能为空");
        return NO;
    }

    destination=[HGBFileTool urlAnalysis:destination];
    NSString *filePath=[[NSURL URLWithString:destination]path];
    NSString *fileName = [filePath lastPathComponent];
    
    
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL isExit=[filemanage fileExistsAtPath:filePath];
    if(isExit){
        [filemanage removeItemAtPath:filePath error:nil];
    }else{
        NSString *directoryPath=[filePath stringByDeletingLastPathComponent];
        if(![HGBFileTool isExitAtFileSource:directoryPath]){
            [HGBFileTool createDirectorySource:directoryPath];
        }
    }
    
    NSMutableData *archiverData = [NSMutableData data];
    
    //创建归档工具
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:archiverData];
    //归档
    [archiver encodeObject:object forKey:fileName];
    
    //结束归档
    [archiver finishEncoding];
    BOOL flag=[archiverData writeToFile:filePath atomically:YES];
    return flag;
    
}
/**
 反归档-普通

 @param source 要解归档的路径或url
 @return 保存结果
 */
+ (id)unarcheiverWithFileSource:(NSString *)source
{
    if(source==nil||source.length==0){
        HGBLog(@"源文件地址不能为空");
        return nil;
    }

    source=[HGBFileTool urlAnalysis:source];
    NSString *filePath=[[NSURL URLWithString:source]path];
    NSString *fileName = [filePath lastPathComponent];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if(!data){
         HGBLog(@"数据为空");
        return nil;
    }
    //将NSData通过反归档,转化成CheckViolationModel的数组对象
    @try{
        NSKeyedUnarchiver *unarcheiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        //通过反归档得到复杂对象
        id reslutObj = [unarcheiver decodeObjectForKey:fileName];
        return reslutObj;
    }@catch(NSException *e){
         HGBLog(@"%@",e);
        return nil;
    }@finally{

    }

    
}
#pragma mark 文件归档和反归档-加密
/**
 归档-加密

 @param object 要归档的数据
 @param destination 归档路径或url
 @param key 密钥
 @return 保存结果
 */
+ (BOOL)archiverEncryptWithObject:(id)object toDestination:(NSString *)destination andWithKey:(NSString *)key
{
    if(destination==nil||destination.length==0){
        HGBLog(@"源文件地址不能为空");
        return NO;
    }
    if(object==nil){
        HGBLog(@"数据不能为空");
        return NO;
    }

    destination=[HGBFileTool urlAnalysis:destination];
    NSString *filePath=[[NSURL URLWithString:destination]path];
    NSString *fileName = [filePath lastPathComponent];

    NSString *encryptKey=key;
    if(encryptKey==nil){
        encryptKey=[NSString stringWithFormat:@"%@",fileName];
    }
    
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL isExit=[filemanage fileExistsAtPath:filePath];
    if(isExit){
        [filemanage removeItemAtPath:filePath error:nil];
    }else{
        NSString *directoryPath=[filePath stringByDeletingLastPathComponent];
        if(![HGBFileTool isExitAtFileSource:directoryPath]){
            [HGBFileTool createDirectorySource:directoryPath];
        }
    }
    
    NSMutableData *archiverData = [NSMutableData data];
    
    //创建归档工具
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:archiverData];
    //归档
    [archiver encodeObject:object forKey:fileName];
    
    //结束归档
    [archiver finishEncoding];
    archiverData=[NSMutableData dataWithData:[HGBFileTool AES256ParmEncryptData:archiverData WithKey:encryptKey]];
    
    BOOL flag=[archiverData writeToFile:filePath atomically:YES];
    return flag;
    
}
/**
 反归档-加密

 @param source 要解归档路径或url
 @param key 密钥
 @return 解归档后对象
 */
+ (id)unarcheiverWithEncryptFileSource:(NSString *)source andWithKey:(NSString *)key
{
    if(source==nil||source.length==0){
        HGBLog(@"源文件地址不能为空");
        return nil;
    }

    source=[HGBFileTool urlAnalysis:source];
    NSString *filePath=[[NSURL URLWithString:source]path];
    NSString *fileName = [filePath lastPathComponent];

    NSString *encryptKey=key;
    if(encryptKey==nil){
        encryptKey=[NSString stringWithFormat:@"%@",fileName];
    }
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    data=[HGBFileTool AES256ParmDecryptData:data WithKey:encryptKey];
    if(!data){
        HGBLog(@"数据为空");
        return nil;
    }
    //将NSData通过反归档,转化成CheckViolationModel的数组对象

    @try{
        NSKeyedUnarchiver *unarcheiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        //通过反归档得到复杂对象
        id reslutObj = [unarcheiver decodeObjectForKey:fileName];
        return reslutObj;
    }@catch(NSException *e){
         HGBLog(@"%@",e);
        return nil;
    }@finally{

    }

    
}
#pragma mark 文档通用

/**
 文件拷贝

 @param source 文件路径或url
 @param destination 复制文件路径或url
 @return 结果
 */
+(BOOL)copyFileSource:(NSString *)source toDestination:(NSString *)destination{
    if(source==nil||source.length==0){
        HGBLog(@"源文件地址不能为空");
        return NO;
    }
    if(destination==nil||destination.length==0){
        HGBLog(@"目标文件地址不能为空");
        return nil;
    }
    NSString* srcPath=[HGBFileTool urlAnalysisToPath:source];
   NSString* filePath=[HGBFileTool urlAnalysisToPath:destination];
    if(![HGBFileTool isExitAtFileSource:srcPath]){
        HGBLog(@"源文件不存在");
        return NO;
    }
    NSString *directoryPath=[filePath stringByDeletingLastPathComponent];
    if(![HGBFileTool isExitAtFileSource:directoryPath]){
        [HGBFileTool createDirectorySource:directoryPath];
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL flag=[filemanage copyItemAtPath:srcPath toPath:filePath error:nil];
    if(flag){
        return YES;
    }else{
        return NO;
    }
}

/**
 文件剪切

 @param source 文件路径或url
 @param destination 复制文件路径或url
 @return 结果
 */
+(BOOL)moveFileSource:(NSString *)source toDestination:(NSString *)destination{

    if(source==nil||source.length==0){
        HGBLog(@"源文件地址不能为空");
        return NO;
    }
    if(destination==nil||destination.length==0){
        HGBLog(@"目标文件地址不能为空");
        return nil;
    }
    NSString* srcPath=[HGBFileTool urlAnalysisToPath:source];
    NSString* filePath=[HGBFileTool urlAnalysisToPath:destination];
    if(![HGBFileTool isExitAtFileSource:srcPath]){
        HGBLog(@"源文件不存在");
        return NO;
    }
    NSString *directoryPath=[filePath stringByDeletingLastPathComponent];
    if(![HGBFileTool isExitAtFileSource:directoryPath]){
        [HGBFileTool createDirectorySource:directoryPath];
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL flag=[filemanage moveItemAtPath:srcPath toPath:filePath error:nil];
    if(flag){
        return YES;
    }else{
        return NO;
    }
}

/**
 删除文档

 @param source 归档的路径或url
 @return 结果
 */
+ (BOOL)removeFileSource:(NSString *)source{
    if(source==nil||source.length==0){
        HGBLog(@"源文件地址不能为空");
        return NO;
    }
   NSString* filePath=[HGBFileTool urlAnalysisToPath:source];

    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL isExit=[filemanage fileExistsAtPath:filePath];
    BOOL deleteFlag=NO;
    if(isExit){
         deleteFlag=[filemanage removeItemAtPath:filePath error:nil];
    }else{
        deleteFlag=NO;
    }
    return deleteFlag;
}
/**
 文档是否存在

 @param source 归档的路径或url
 @return 结果
 */
+(BOOL)isExitAtFileSource:(NSString *)source{
    if(source==nil||source.length==0){
        HGBLog(@"源文件地址不能为空");
        return NO;
    }
    NSString* filePath=[HGBFileTool urlAnalysisToPath:source];
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL isExit=[filemanage fileExistsAtPath:filePath];
    return isExit;
}

#pragma mark 文件夹

/**
 路径是不是文件夹

 @param source 路径或url
 @return 结果
 */
+(BOOL)isDirectoryAtSource:(NSString *)source{
    if(source==nil||source.length==0){
        HGBLog(@"源文件地址不能为空");
        return NO;
    }
    NSString* path=[HGBFileTool urlAnalysisToPath:source];
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL isDir,isExit;
    isExit=[filemanage fileExistsAtPath:path isDirectory:&isDir];
    if(isExit==YES&&isDir==YES){
        return YES;
    }else{
        return NO;
    }
}
/**
 创建文件夹

 @param source 路径或url
 @return 结果
 */
+(BOOL)createDirectorySource:(NSString *)source{
    if(source==nil||source.length==0){
        HGBLog(@"源文件地址不能为空");
        return NO;
    }
    NSString* directoryPath=[HGBFileTool urlAnalysisToPath:source];
    if([HGBFileTool isExitAtFileSource:directoryPath]){
        HGBLog(@"源文件不存在");
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

/**
 获取文件夹直接子路径

 @param source 文件夹路径或url
 @return 结果
 */
+(NSArray *)getDirectSubPathsInDirectorySource:(NSString *)source{
    if(source==nil||source.length==0){
        HGBLog(@"源文件地址不能为空");
        return nil;
    }
    NSString* directoryPath=[HGBFileTool urlAnalysisToPath:source];
    if(![HGBFileTool isExitAtFileSource:directoryPath]){
        HGBLog(@"源文件不存在");
        return nil;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    NSArray *paths=[filemanage contentsOfDirectoryAtPath:directoryPath error:nil];
    return paths;
}
/**
 获取文件夹所有子路径或url

 @param source 文件夹路径
 @return 结果
 */
+(NSArray *)getAllSubPathsInDirectorySource:(NSString *)source{
    if(source==nil||source.length==0){
        HGBLog(@"源文件地址不能为空");
        return nil;
    }
    NSString* directoryPath=[HGBFileTool urlAnalysisToPath:source];
    if(![HGBFileTool isExitAtFileSource:directoryPath]){
        HGBLog(@"源文件不存在");
        return nil;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    NSArray *paths=[filemanage subpathsAtPath:directoryPath];
    return paths;
}
#pragma mark 文件信息
/**
 获取文件信息

 @param source 文件路径或url
 @return 文件信息
 */
+(NSDictionary *)getFileInfoFromFileSource:(NSString *)source{

    if(source==nil||source.length==0){
        HGBLog(@"源文件地址不能为空");
        return nil;
    }
    NSString* filePath=[HGBFileTool urlAnalysisToPath:source];
    if(![HGBFileTool isExitAtFileSource:filePath]){
        HGBLog(@"源文件不存在");
        return nil;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    NSDictionary *infoDic=[filemanage attributesOfItemAtPath:filePath error:nil];
    return infoDic;
}
/**
 文档是否可读

 @param source 文件路径或url
 @return 结果
 */
+(BOOL)isReadableFileAtFileSource:(NSString *)source{
    if(source==nil||source.length==0){
        HGBLog(@"源文件地址不能为空");
        return NO;
    }
    NSString* filePath=[HGBFileTool urlAnalysisToPath:source];
    if(![HGBFileTool isExitAtFileSource:filePath]){
        HGBLog(@"源文件不存在");
        return NO;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL isRead=[filemanage isReadableFileAtPath:filePath];
    return isRead;
}
/**
 文档是否可写

 @param source 文件路径或url
 @return 结果
 */
+(BOOL)isWriteableFileAtFileSource:(NSString *)source{
    if(source==nil||source.length==0){
        HGBLog(@"源文件地址不能为空");
        return NO;
    }
    NSString* filePath=[HGBFileTool urlAnalysisToPath:source];
    if(![HGBFileTool isExitAtFileSource:filePath]){
        HGBLog(@"源文件不存在");
        return NO;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL isWrite=[filemanage isWritableFileAtPath:filePath];
    return isWrite;
}
/**
 文档是否可删

 @param source 文件路径或url
 @return 结果
 */
+(BOOL)isDeleteableFileAtFileSource:(NSString *)source{
    if(source==nil||source.length==0){
        HGBLog(@"源文件地址不能为空");
        return NO;
    }
    NSString* filePath=[HGBFileTool urlAnalysisToPath:source];
    if(![HGBFileTool isExitAtFileSource:filePath]){
        HGBLog(@"源文件不存在");
        return NO;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL isDelete=[filemanage isDeletableFileAtPath:filePath];
    return isDelete;
}


#pragma mark 加密
+ (NSData *)AES256ParmEncryptData:(NSData *)data WithKey:(NSString *)key   //加密
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}


+ (NSData *)AES256ParmDecryptData:(NSData *)data WithKey:(NSString *)key   //解密
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
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
    if(![HGBFileTool isURL:url]){
        return NO;
    }
    url=[HGBFileTool urlAnalysis:url];
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
    if(![HGBFileTool isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBFileTool urlAnalysis:url];
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
    if(![HGBFileTool isURL:url]){
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
    if(![HGBFileTool isURL:url]){
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
