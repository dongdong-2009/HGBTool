
//
//  HGBDownLoadTool.m
//  测试
//
//  Created by huangguangbao on 2018/2/5.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBDownLoadTool.h"
#import <UIKit/UIKit.h>

#define DownloadManageDirectoryName @"DownloadManage"
#define DownloadCachesDirectoryName @"DownloadCaches"
#define CommonGroupId @"common"


#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"



#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@interface HGBDownLoadTool()<NSURLSessionDownloadDelegate>
/**
 下载管理地址
 */
@property (strong, nonatomic)NSString *path;
/**
 下载管理
 */
@property(strong,nonatomic)NSURLSession *session;


/**
 任务集合
 */
@property(strong,nonatomic)NSMutableDictionary *taskModels;

/**
 正在下载的任务集合
 */
@property(strong,nonatomic)NSMutableDictionary *downLoadTaskModels;

/**
 后台任务
 */
@property (nonatomic, assign) UIBackgroundTaskIdentifier backTask;
/**
 定时器
 */
@property (nonatomic, strong) NSTimer *timer;


@end

@implementation HGBDownLoadTool
#pragma mark 单例
static HGBDownLoadTool *instance=nil;
/**
 单例

 @return 单例
 */
+(instancetype)shareInstance
{

    if (instance==nil) {
        instance=[[HGBDownLoadTool alloc]init];
        NSString *url=[NSString stringWithFormat:@"document://%@",DownloadCachesDirectoryName];
        url=[HGBDownLoadTool urlAnalysis:url];
        NSString *path=[[NSURL URLWithString:url]path];
        if(![HGBDownLoadTool isExitAtFilePath:path]){
            [HGBDownLoadTool createDirectoryPath:path];
        }
        [instance initDownLoadManage];

    }
    return instance;
}
#pragma mark 下载
/**
 开始下载

 @param task 下载任务
 @return 结果
 */
-(BOOL)startDownLoadWithDownLoadTask:(HGBDownLoadTask *)task{

    HGBDownLoadTask *taskModel=[self getDownLoadTaskWithId:task.id];
    if (taskModel==nil) {
        [self addDownLoadTaskWithTaskModel:task];
    }
     taskModel=self.taskModels[task.id];
    [self.downLoadTaskModels setObject:taskModel forKey:task.id];
    if (taskModel.session==nil) {
        NSURLSessionConfiguration *config=[NSURLSessionConfiguration defaultSessionConfiguration];
        if((taskModel.queue!=nil)){
            taskModel.session=[NSURLSession sessionWithConfiguration:config delegate: self delegateQueue:taskModel.queue];
        }else{
            taskModel.session=[NSURLSession sessionWithConfiguration:config delegate: self delegateQueue:[NSOperationQueue mainQueue]];
        }
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if(task.data){
            NSData *data=task.data;
            taskModel.downLoadTask=[taskModel.session downloadTaskWithResumeData:data];
            taskModel.downLoadTask.taskDescription=task.id;
            [taskModel.downLoadTask resume];

        }else{
            NSURL *url=[NSURL URLWithString:task.url];
            taskModel.downLoadTask=[taskModel.session downloadTaskWithURL:url];
            taskModel.downLoadTask.taskDescription=task.id;
            [taskModel.downLoadTask resume];
        }
    });
//    if(task.data){
//        NSData *data=task.data;
//        taskModel.downLoadTask=[self.session downloadTaskWithResumeData:data];
//        taskModel.downLoadTask.taskDescription=task.id;
//        [taskModel.downLoadTask resume];
//
//    }else{
//        NSURL *url=[NSURL URLWithString:task.url];
//        taskModel.downLoadTask=[self.session downloadTaskWithURL:url];
//        taskModel.downLoadTask.taskDescription=task.id;
//        [taskModel.downLoadTask resume];
//    }


    
    return YES;

}
/**
 取消下载

 @param task 下载任务
 @return 结果
 */
-(BOOL)cancelDownLoadWithDownLoadTask:(HGBDownLoadTask *)task{
   __block HGBDownLoadTask *taskModel=[self getDownLoadTaskWithId:task.id];
    if (taskModel==nil) {
        HGBLog(@"任务未创建，无效任务");
        return NO;
    }
    NSURLSessionDownloadTask *downLoadTask=taskModel.downLoadTask;
    if(downLoadTask){
        [downLoadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            taskModel.data=resumeData;
            if (taskModel.status==HGBDownloadStateSuspended) {
                taskModel.status=HGBDownloadStateUnExpectedCancel;
            }else if (taskModel.status==HGBDownloadStateRuning){
                taskModel.status=HGBDownloadStateCancel;
            }
            [self changeDownLoadTaskWithTaskModel:taskModel];
             [self.downLoadTaskModels removeObjectForKey:taskModel.id];


        }];

    }

    return YES;
}
/**
 暂停下载

 @param task 下载任务
 @return 结果
 */
-(BOOL)suspendDownLoadWithDownLoadTask:(HGBDownLoadTask *)task{
    __block HGBDownLoadTask *taskModel=[self getDownLoadTaskWithId:task.id];
    if (taskModel==nil) {
        HGBLog(@"任务未创建，无效任务");
        return NO;
    }
    NSURLSessionDownloadTask *downLoadTask=taskModel.downLoadTask;
    if(downLoadTask){
        [downLoadTask suspend];
        taskModel.status=NSURLSessionTaskStateSuspended;
        [self changeDownLoadTaskWithTaskModel:taskModel];
    }

    return YES;
}
/**
 暂停下载恢复下载任务

 @param task 下载任务
 @return 结果
 */
-(BOOL)resumeDownLoadWithDownLoadTask:(HGBDownLoadTask *)task{
    __block HGBDownLoadTask *taskModel=[self getDownLoadTaskWithId:task.id];
    if (taskModel==nil) {
        HGBLog(@"任务未创建，无效任务");
        return NO;
    }
    NSURLSessionDownloadTask *downLoadTask=taskModel.downLoadTask;
    if(downLoadTask){
        [downLoadTask resume];
    }

    return YES;
}
/**
 取消所有任务
 */
-(void)cancelAllTasks{
    NSArray *keys=[self.taskModels allKeys];
    for (NSString *key in keys) {
        HGBDownLoadTask *taskModel =self.taskModels[key];
        [self cancelDownLoadWithDownLoadTask:taskModel];
    }

}
/**
 取消所有任务
 */
-(void)suspendAllTasks{
    NSArray *keys=[self.taskModels allKeys];
    for (NSString *key in keys) {
        HGBDownLoadTask *taskModel =self.taskModels[key];
        [self suspendDownLoadWithDownLoadTask:taskModel];
    }

}
#pragma mark download

/**
 *  @param session   session
 *  @param downloadTask 任务
 *  @param location :url
 */
//当下载完毕后调用该方法，该方法执行完毕之后，就把下载的文件从
//temp目录中删除
/**
 下载结束

 @param session session
 @param downloadTask 任务
 @param location 路径
 */
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSString *idid=downloadTask.taskDescription;
    NSData *data=[[NSData alloc]initWithContentsOfURL:location];
    HGBDownLoadTask *task=self.taskModels[idid];
    [self.downLoadTaskModels removeObjectForKey:idid];
    if (task) {
        task.progress=1;
        task.totalSize=data.length;
        task.downloadSize=data.length;
        task.status=HGBDownloadStateCompleted;
        [self changeDownLoadTaskWithTaskModel:task];
        NSString *path=[HGBDownLoadTool urlAnalysisToPath:task.path];
        [HGBDownLoadTool moveFilePath:location.path ToPath:path];
        if(self.resultBlock){
            self.resultBlock(YES,task,@{@"id":idid});
        }



    }
    if([[self.downLoadTaskModels allKeys]count]==0){
        [self stopBackgroundTask];
    }
}

/**
 下载过程中

 @param session session
 @param downloadTask 任务
 @param bytesWritten 当前下载了多少数据
 @param totalBytesWritten 已经下载了多少数据
 @param totalBytesExpectedToWrite 总共需要下载多少数据
 */
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSString *idid=downloadTask.taskDescription;
    CGFloat progress= ((CGFloat)totalBytesWritten)/(CGFloat)totalBytesExpectedToWrite;

    HGBDownLoadTask *task=self.taskModels[idid];
    if (task) {
        task.progress=progress;
        task.totalSize=totalBytesExpectedToWrite;
        task.downloadSize=totalBytesWritten;
        task.status=HGBDownloadStateRuning;
        [self changeDownLoadTaskWithTaskModel:task];
        if(self.resultBlock){
            self.resultBlock(YES,task,@{@"progress":@(progress).stringValue,@"downloadSize":@(totalBytesWritten).stringValue,@"totalSize":@(totalBytesExpectedToWrite).stringValue,@"id":idid});
        }
    }





}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes{
    
     
}
#pragma mark 监听
/**
 app将要进入后台

 @param _n 消息
 */
-(void)appWillBack:(NSNotification *)_n{
    if(self.isCanBackGround){
        [self startBackgroundTask];
    }

}
/**
 app进入前台

 @param _n 消息
 */
-(void)appTerminate:(NSNotification *)_n{
    [self saveAllTasks];
}
/**
 app将要终止

 @param _n 消息
 */
-(void)appActive:(NSNotification *)_n{
    [self stopBackgroundTask];
}
#pragma mark 下载管理
/**
 下载管理初始化
 @return 结果
 */
-(BOOL)initDownLoadManage{

    NSString *url=[NSString stringWithFormat:@"document://%@/%@.plist",DownloadManageDirectoryName,[HGBDownLoadTool getBundleID]];
    NSString *path=[HGBDownLoadTool urlAnalysisToPath:url];
    self.path=path;
    NSString *directoryPath=[path stringByDeletingLastPathComponent];
    if(![HGBDownLoadTool isExitAtFilePath:directoryPath]){
        [HGBDownLoadTool createDirectoryPath:directoryPath];
    }

    if([HGBDownLoadTool isExitAtFilePath:path]){
        NSDictionary *taskDics=[NSDictionary dictionaryWithContentsOfFile:path];
        if(taskDics){
            NSArray *keys=[taskDics allKeys];
            for(NSString *key in keys){
                NSDictionary *taskDic =taskDics[key];
                HGBDownLoadTask *task =[HGBDownLoadTask taskModelFormDictionary:taskDic];
                [self.taskModels setObject:task forKey:task.id];
            }
        }
    }else{
        [[NSDictionary dictionary] writeToFile:path atomically:YES];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appWillBack:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    return YES;
}

/**
 添加下载任务
 @param task 下载任务
 @return 结果
 */
-(BOOL)addDownLoadTaskWithTaskModel:(HGBDownLoadTask *)task{
    NSMutableDictionary *taskDics=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:self.path]];
    if (taskDics==nil) {
        taskDics=[NSMutableDictionary dictionary];
    }
    if ([self.taskModels objectForKey:task.id]) {
        return NO;
    }
    NSDictionary *taskDic=[HGBDownLoadTask dictionaryFromTaskModel:task];
    [taskDics setObject:taskDic forKey:task.id];
    [self.taskModels setObject:task forKey:task.id];

    BOOL flag=[taskDics writeToFile:self.path atomically:YES];
    if(flag){
        return YES;
    }else{
        HGBLog(@"下载任务处理失败");
        return NO;
    }
    
}
/**
  修改下载任务
 @param task 下载任务
 @return 结果
 */
-(BOOL)changeDownLoadTaskWithTaskModel:(HGBDownLoadTask *)task{
    NSMutableDictionary *taskDics=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:self.path]];
    if (taskDics==nil) {
        taskDics=[NSMutableDictionary dictionary];
    }
    NSDictionary *taskDic=[HGBDownLoadTask dictionaryFromTaskModel:task];
    [taskDics setObject:taskDic forKey:task.id];
     [self.taskModels setObject:task forKey:task.id];

    BOOL flag=[taskDics writeToFile:self.path atomically:YES];
    if(flag){
        return YES;
    }else{
        HGBLog(@"下载任务处理失败");
        return NO;
    }

}
-(void)saveAllTasks{
    NSArray *keys=[self.taskModels allKeys];
    for(NSString *key in keys){
        HGBDownLoadTask *task =self.taskModels[key];
        [self changeDownLoadTaskWithTaskModel:task];
    }
}
/**
 删除下载任务

 @param taskId 下载id
 @return 创建结果
 @return 结果
 */
-(BOOL)deleteDownLoadTaskWithId:(NSString *)taskId{

    HGBDownLoadTask *task=self.taskModels[taskId];
    if(task){
        [self.taskModels removeObjectForKey:taskId];
    }
    NSMutableDictionary *taskDics=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:self.path]];
    if (taskDics==nil) {
        taskDics=[NSMutableDictionary dictionary];
    }
    NSDictionary *taskDic=[taskDics objectForKey:taskId];
    if(taskDic){
        [taskDics removeObjectForKey:taskId];
    }
    BOOL flag=[taskDics writeToFile:self.path atomically:YES];
    if(flag){
        return YES;
    }else{
        HGBLog(@"下载任务删除失败");
        return NO;
    }





}
/**
 获取下载任务

 @param taskId 下载id
 @return 结果
 */
-(HGBDownLoadTask *)getDownLoadTaskWithId:(NSString *)taskId{
     HGBDownLoadTask *task=self.taskModels[taskId];
    return task;


}
/**
 获取一组下载任务列表

 @param groupId 组别id

 @return 结果
 */
-(NSArray <HGBDownLoadTask *>*)getDownLoadTasksWithGrounpId:(NSString *)groupId{

    NSMutableArray *tasks=[NSMutableArray array];
    NSArray *keys=[self.taskModels allKeys];
    for(NSString *key in keys){
        HGBDownLoadTask *task =self.taskModels[key];
        if([task.groupId isEqualToString:groupId]){
            [tasks addObject:task];
        }

    }
    return tasks;

}
/**
 获取下载任务列表
 @return 结果
 */
-(NSArray<HGBDownLoadTask *> *)getDownLoadTasks{

    NSMutableArray *tasks=[NSMutableArray array];
    NSArray *keys=[self.taskModels allKeys];
    for(NSString *key in keys){
        HGBDownLoadTask *task =self.taskModels[key];
        [tasks addObject:task];
    }
    return tasks;

}
#pragma mark 后台
/**
 开启后台模式-执行完毕后请结束任务
 */
-(void)startBackgroundTask{
    UIApplication*  app = [UIApplication sharedApplication];
    self.backTask =[app beginBackgroundTaskWithExpirationHandler:^(void) {
        //开启定时器 不断向系统请求后台任务执行的时间
        self.timer = [NSTimer scheduledTimerWithTimeInterval:25.0 target:self selector:@selector(applyForMoreTime) userInfo:nil repeats:YES];
        [self.timer fire];

    }];
}

-(void)applyForMoreTime {
    UIApplication*  app = [UIApplication sharedApplication];
    //如果系统给的剩余时间小于60秒 就终止当前的后台任务，再重新初始化一个后台任务，重新让系统分配时间，这样一直循环下去，保持APP在后台一直处于active状态。
    if (app.backgroundTimeRemaining < 60) {
        [app endBackgroundTask:self.backTask];
        self.backTask = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:self.backTask];
            self.backTask = UIBackgroundTaskInvalid;
        }];
    }
}

/**
 结束后台任务
 */
-(void)stopBackgroundTask{

    if(self.backTask){
        UIApplication*  app = [UIApplication sharedApplication];
        [app endBackgroundTask:self.backTask];
        self.backTask = UIBackgroundTaskInvalid;
        [self.timer invalidate];
    }
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
#pragma mark 获取 bundleID
/**
 获取BundleID

 @return BundleID
 */
+(NSString*) getBundleID

{

    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];

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
    if([HGBDownLoadTool isExitAtFilePath:directoryPath]){
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
    if(![HGBDownLoadTool isExitAtFilePath:srcPath]){
        return NO;
    }
    NSString *directoryPath=[filePath stringByDeletingLastPathComponent];
    if(![HGBDownLoadTool isExitAtFilePath:directoryPath]){
        [HGBDownLoadTool createDirectoryPath:directoryPath];
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
    if(![HGBDownLoadTool isURL:url]){
        return NO;
    }
     url=[HGBDownLoadTool urlAnalysis:url];
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
    if(![HGBDownLoadTool isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBDownLoadTool urlAnalysis:url];
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
    if(![HGBDownLoadTool isURL:url]){
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
    if(![HGBDownLoadTool isURL:url]){
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
#pragma mark get
-(NSMutableDictionary *)taskModels{
    if(_taskModels==nil){
        _taskModels=[NSMutableDictionary dictionary];
    }
    return _taskModels;
}
-(NSMutableDictionary *)downLoadTaskModels{
    if(_downLoadTaskModels==nil){
        _downLoadTaskModels=[NSMutableDictionary dictionary];
    }
    return _downLoadTaskModels;
}
-(NSURLSession *)session{
    if(_session==nil){
        NSURLSessionConfiguration *config=[NSURLSessionConfiguration defaultSessionConfiguration];
         _session=[NSURLSession sessionWithConfiguration:config delegate: self delegateQueue:[NSOperationQueue mainQueue]];

    }
    return _session;
}
@end
