//
//  HGBAudioRecorder.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/3/20.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBAudioRecorder.h"
#import "HGBAudioTool.h"

#define kWidth [[UIScreen mainScreen] bounds].size.width
#define kHeight [[UIScreen mainScreen] bounds].size.height
//屏幕比例
#define wScale kWidth / 750.0
#define hScale kHeight / 1334.0


#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"



#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@interface HGBAudioRecorder ()<HGBAudioToolDelegate>
/**
 开始
 */
@property(strong,nonatomic)UIButton * recordButton;
/**
 暂停
 */
@property(strong,nonatomic)UIButton * playerButton;
/**
 是否录音
 */
@property(assign,nonatomic)BOOL isRecorder;

@end

@implementation HGBAudioRecorder
#pragma mark life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavigationItem];//导航栏
    [self viewSetUp];//UI
    [[HGBAudioTool shareInstance] setDelegate:self];

}
#pragma mark 导航栏
//导航栏
-(void)createNavigationItem
{
    //导航栏
    self.navigationController.navigationBar.barTintColor=[UIColor colorWithRed:0.0/256 green:191.0/256 blue:256.0/256 alpha:1];
    [[UINavigationBar appearance]setBarTintColor:[UIColor colorWithRed:0.0/256 green:191.0/256 blue:256.0/256 alpha:1]];
    //标题
    UILabel *titleLab=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 136*wScale, 16)];
    titleLab.font=[UIFont boldSystemFontOfSize:16];
    titleLab.text=@"录音器";
    titleLab.textAlignment=NSTextAlignmentCenter;
    titleLab.textColor=[UIColor whiteColor];
    self.navigationItem.titleView=titleLab;


    //左键
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"返回"  style:UIBarButtonItemStylePlain target:self action:@selector(returnhandler)];
    [self.navigationItem.leftBarButtonItem setImageInsets:UIEdgeInsetsMake(0, -15, 0, 5)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];

}
//返回
-(void)returnhandler{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark UI
-(void)viewSetUp{
    self.view.backgroundColor=[UIColor whiteColor];



    self.recordButton=[UIButton buttonWithType:(UIButtonTypeSystem)];
    self.recordButton.frame=CGRectMake((kWidth-100)*0.5, 120,100, 100);
    self.recordButton.layer.masksToBounds=YES;
    self.recordButton.layer.cornerRadius=50;
    [self.recordButton addTarget:self action:@selector(startRecord:) forControlEvents:(UIControlEventTouchDown)];
     [self.recordButton addTarget:self action:@selector(stopRecord:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.recordButton addTarget:self action:@selector(cancelRecord:) forControlEvents:(UIControlEventTouchUpOutside)];
    [self.recordButton setTitle:@"录音" forState:(UIControlStateNormal)];
    self.recordButton.tag=0;
    [self.recordButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    self.recordButton.backgroundColor=[UIColor redColor];
    [self.view addSubview:self.recordButton];


    self.playerButton=[UIButton buttonWithType:(UIButtonTypeSystem)];
    self.playerButton.frame=CGRectMake((kWidth-100)*0.5, 250,100, 100);
    self.playerButton.layer.masksToBounds=YES;
    self.playerButton.layer.cornerRadius=50;
    [self.playerButton addTarget:self action:@selector(playRecord:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.playerButton setTitle:@"播放" forState:(UIControlStateNormal)];
    [self.playerButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    self.playerButton.backgroundColor=[UIColor blueColor];
    [self.view addSubview:self.playerButton];




}
-(void)setUrl:(NSString *)url{
    _url=url;
    if(url==nil){
        return;
    }
    NSString *lastPath=[self urlAnalysisToPath:url];

    NSString *dirPath=[lastPath stringByDeletingLastPathComponent];
    if(![self isExitAtFilePath:dirPath]){
        [self createDirectoryPath:dirPath];
    }
    if([self isExitAtFilePath:lastPath]){
        HGBLog(@"路径已存在");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(audioTool:didFailedWithError:)]){
            [self.delegate audioRecorder:self didFailedWithError:@{ReslutCode:@(HGBAudioToolErrorTypeExistPath).stringValue,ReslutMessage:@"路径已存在"}];
        }
        return;
    }
    [[HGBAudioTool shareInstance]initRecordingWithPath:lastPath andWithRate:44100.0 andWithNumberOfChannels:2 andWithPCMBitDepth:16 andwithQuality:3];
   



}

#pragma mark action
/**
 开始录音

 @param _b 按钮
 */
-(void)startRecord:(UIButton *)_b{
    if(_url==nil||_url.length==0){
        _url=[NSString stringWithFormat:@"document://%@.aac",[self getSecondTimeStringSince1970]];
    }
    [[HGBAudioTool shareInstance]initRecordingWithPath:_url andWithRate:44100.0 andWithNumberOfChannels:2 andWithPCMBitDepth:16 andwithQuality:3];
    [[HGBAudioTool shareInstance]startRecording];
}
/**
 结束录音

 @param _b 按钮
 */
-(void)stopRecord:(UIButton *)_b{
    [[HGBAudioTool shareInstance]stopRecording];
}
/**
 取消录音

 @param _b 按钮
 */
-(void)cancelRecord:(UIButton *)_b{
    [[HGBAudioTool shareInstance]cancelRecording];
}
/**
 播放录音

 @param _b 按钮
 */
-(void)playRecord:(UIButton *)_b{
    NSString *lasturl=[self urlAnalysisToPath:_url];


    [[HGBAudioTool shareInstance]initPlayerWithSource:lasturl];
    [[HGBAudioTool shareInstance]startPlayer];
}
#pragma mark delegate
-(void)audioToolDidCanceled:(HGBAudioTool *)audio{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(audioRecorderDidCanceled:)]) {
        [self.delegate audioRecorderDidCanceled:self];
    }
}
-(void)audioTool:(HGBAudioTool *)audio didFailedWithError:(NSDictionary *)errorInfo{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(audioRecorder:didFailedWithError:)]) {
        [self.delegate audioRecorder:self didFailedWithError:errorInfo];
    }
}
-(void)audioToolDidSucessed:(HGBAudioTool *)audio{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(audioRecorderDidSucessed:)]) {
        [self.delegate audioRecorderDidSucessed:self];
    }
}
-(void)audioTool:(HGBAudioTool *)audio didSucessedWithPath:(NSString *)path{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(audioRecorder:didSucessedWithPath:)]) {
        [self.delegate audioRecorder:self didSucessedWithPath:path];
    }
}
#pragma mark 获取时间
/**
 获取时间戳-秒级

 @return 秒级时间戳
 */
-(NSString *)getSecondTimeStringSince1970
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

#pragma mark 文档通用
/**
 删除文档

 @param filePath 归档的路径
 @return 结果
 */
- (BOOL)removeFilePath:(NSString *)filePath{
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

 @param filePath 归档的路径
 @return 结果
 */
-(BOOL)isExitAtFilePath:(NSString *)filePath{
    if(filePath==nil||filePath.length==0){
        return NO;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL isExit=[filemanage fileExistsAtPath:filePath];
    return isExit;
}

/**
 文件拷贝

 @param srcPath 文件路径
 @param filePath 复制文件路径
 @return 结果
 */
-(BOOL)copyFilePath:(NSString *)srcPath ToPath:(NSString *)filePath{
    if(![self isExitAtFilePath:srcPath]){
        return NO;
    }
    NSString *directoryPath=[filePath stringByDeletingLastPathComponent];
    if(![self isExitAtFilePath:directoryPath]){
        [self createDirectoryPath:directoryPath];
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL flag=[filemanage copyItemAtPath:srcPath toPath:filePath error:nil];
    if(flag){
        return YES;
    }else{
        return NO;
    }
}
#pragma mark 文件夹

/**
 创建文件夹

 @param directoryPath 路径
 @return 结果
 */
-(BOOL)createDirectoryPath:(NSString *)directoryPath{
    if([self isExitAtFilePath:directoryPath]){
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
#pragma mark url
/**
 判断路径是否是URL

 @param url url路径
 @return 结果
 */
-(BOOL)isURL:(NSString*)url{
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
-(BOOL)urlExistCheck:(NSString *)url{
    if(url==nil||url.length==0){
        return NO;
    }
    if(![self isURL:url]){
        return NO;
    }
     url=[self urlAnalysis:url];
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
-(NSString *)urlAnalysisToPath:(NSString *)url{
    if(url==nil){
        return nil;
    }
    if(![self isURL:url]){
        return nil;
    }
    NSString *urlstr=[self urlAnalysis:url];
    return [[NSURL URLWithString:urlstr]path];
}
/**
 url解析

 @return 解析后url
 */
-(NSString *)urlAnalysis:(NSString *)url{
    if(url==nil){
        return nil;
    }
    if(![self isURL:url]){
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
-(NSString *)urlEncapsulation:(NSString *)url{
    if(![self isURL:url]){
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
