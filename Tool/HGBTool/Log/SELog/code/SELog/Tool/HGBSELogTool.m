//
//  HGBSELogTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/5/10.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBSELogTool.h"
#import <UIKit/UIKit.h>

#define HGBLogFolder @"SELog"

#define HGBSELogKey @"HGBSELog"


@interface HGBSELogTool()
@property(strong,nonatomic)NSString *logPath;
@end
@implementation HGBSELogTool
static HGBSELogTool *instance=nil;
#pragma mark init
+ (instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBSELogTool alloc]init];
        [instance initSDK];
    }
    return instance;
}
-(void)initSDK{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveLog:) name:HGBSELogKey object:nil];
}
#pragma mark 日志文件重定向
/**
 将日志文件重定向
 */
-(void)saveLog:(NSNotification *)_n
{
    NSDictionary *dic=[_n userInfo];
    if (dic) {
        NSString *log=[dic objectForKey:@"log"];
        if(self.logPath==nil){
            NSString *logListPath=[NSString stringWithFormat:@"document://%@/log.plist",HGBLogFolder];
            NSString *lastlogListPath=[HGBSELogTool urlAnalysisToPath:logListPath];
            NSMutableArray *logPathList=[NSMutableArray arrayWithContentsOfFile:lastlogListPath];
            if(logPathList==nil){
                logPathList=[NSMutableArray array];
            }

            NSString *logFilePath=[NSString stringWithFormat:@"document://%@/%@.log",HGBLogFolder,[HGBSELogTool getSecondTimeStringSince1970]];
            [logPathList insertObject:logListPath atIndex:0];
            [logPathList writeToFile:lastlogListPath atomically:YES];

            NSString *lastLogFilePath=[HGBSELogTool urlAnalysisToPath:logFilePath];
            NSString *directoryPath=[lastLogFilePath stringByDeletingLastPathComponent];
            if(![HGBSELogTool isExitAtFilePath:directoryPath]){
                [HGBSELogTool createDirectoryPath:directoryPath];
            }
            self.logPath=lastLogFilePath;
        }
        if (log&&self.logPath) {
            if (self.logBlock) {
                self.logBlock(log);
            }
            NSString *allLog=[[NSString alloc]initWithContentsOfFile:self.logPath encoding:NSUTF8StringEncoding error:nil];
            allLog=[NSString stringWithFormat:@"%@/n%@",allLog,log];
            [allLog writeToFile:self.logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }



}
#pragma mark 获取日志列表
/**
 获取日志路径列表文件路径

 @return 路径
 */
+(NSString *)getLogPathListFilePath{
    NSString *logListPath=[NSString stringWithFormat:@"document://%@/log.plist",HGBLogFolder];
    return logListPath;
}
/**
 获取日志路径列表

 @return 日志路径列表
 */
+(NSArray *)getLogListPaths{
    NSString *logListPath=[NSString stringWithFormat:@"document://%@/log.plist",HGBLogFolder];
    NSString *lastlogListPath=[HGBSELogTool urlAnalysisToPath:logListPath];
    NSMutableArray *logList=[NSMutableArray arrayWithContentsOfFile:lastlogListPath];
    if(logList==nil){
        logList=[NSMutableArray array];
    }
    return logList;
}
/**
 获取日志列表

 @return 日志列表
 */
+(NSArray *)getLogLists{
    NSString *logListPath=[NSString stringWithFormat:@"document://%@/log.plist",HGBLogFolder];
    NSString *lastlogListPath=[HGBSELogTool urlAnalysisToPath:logListPath];
    NSMutableArray *logPathList=[NSMutableArray arrayWithContentsOfFile:lastlogListPath];
    if(logPathList==nil){
        logPathList=[NSMutableArray array];
    }
    NSMutableArray *logList=[NSMutableArray array];
    for (NSString *logPath in logPathList) {
        NSString *lastPath=[HGBSELogTool urlAnalysisToPath:logPath];
        NSString *log=[[NSString alloc]initWithContentsOfFile:lastPath encoding:NSUTF8StringEncoding error:nil];
        if(log){
            [logList addObject:log];
        }
    }
    return logList;
}
#pragma mark 获取时间
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
#pragma mark 文件

/**
 删除文档

 @param filePath 文件路径
 @return 结果
 */
+ (BOOL)removeFilePath:(NSString *)filePath{
    if(filePath==nil||filePath.length==0){
        return YES;
    }
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
 路径是不是文件夹

 @param path 路径
 @return 结果
 */
+(BOOL)isDirectoryAtPath:(NSString *)path{
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

 @param directoryPath 路径
 @return 结果
 */
+(BOOL)createDirectoryPath:(NSString *)directoryPath{
    if([HGBSELogTool isExitAtFilePath:directoryPath]){
        return YES;
    }
    NSError *error;
    NSFileManager *filemanage=[NSFileManager defaultManager];
    BOOL flag=[filemanage createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:&error];
    if(flag){
        return YES;
    }else{
        return NO;
    }
}
/**
 文件剪切

 @param srcPath 文件路径
 @param filePath 复制文件路径
 @return 结果
 */
+(BOOL)moveFilePath:(NSString *)srcPath ToPath:(NSString *)filePath{
    if(![HGBSELogTool isExitAtFilePath:srcPath]){
        return NO;
    }
    NSString *directoryPath=[filePath stringByDeletingLastPathComponent];
    if(![HGBSELogTool isExitAtFilePath:directoryPath]){
        [HGBSELogTool createDirectoryPath:directoryPath];
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL flag=[filemanage moveItemAtPath:srcPath toPath:filePath error:nil];
    if(flag){
        return YES;
    }else{
        return NO;
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
    if(![HGBSELogTool isURL:url]){
        return NO;
    }
    url=[HGBSELogTool urlAnalysis:url];
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
    if(![HGBSELogTool isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBSELogTool urlAnalysis:url];
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
    if(![HGBSELogTool isURL:url]){
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
    if(![HGBSELogTool isURL:url]){
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
