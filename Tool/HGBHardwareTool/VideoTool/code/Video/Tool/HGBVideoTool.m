//
//  HGBVideoTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/29.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBVideoTool.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <AudioToolbox/AudioToolbox.h>




#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"



#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@interface HGBVideoTool ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
/**
 父控制器
 */
@property (strong,nonatomic)UIViewController *parent;
/**
 媒体:录像支持
 */
@property(strong,nonatomic)UIImagePickerController *picker;


@end

@implementation HGBVideoTool
static HGBVideoTool *instance=nil;
#pragma mark init
/**
 单例

 @return 实例
 */
+(instancetype)shareInstance{
    if(instance==nil){
        instance=[[HGBVideoTool alloc]init];
    }
    return instance;
}


#pragma mark 调用录像
/**
 调用录像
 @param parent 父控制器
 */
-(BOOL)startVideoInParent:(UIViewController *)parent{
    if(parent==nil){
        parent=[HGBVideoTool currentViewController];
    }
    if([self.picker.view superview]){
        [self.picker dismissViewControllerAnimated:YES completion:nil];
    }

    self.parent=parent;
    if (![HGBVideoTool isCanUseCamera])
    {
        if(self.delegate&&[self.delegate respondsToSelector:@selector(videoTool:didFailedWithError:)]){
            [self.delegate videoTool:self didFailedWithError:@{ReslutCode:@(HGBVideoToolErrorTypeAuthority).stringValue,ReslutMessage:@"相机权限受限!"}];
        }
        NSString *errorStr = @"应用相机权限受限,请在设置中启用";
        [self alertAuthorityWithPrompt:errorStr];
        return NO;
    }


    self.picker.sourceType=UIImagePickerControllerSourceTypeCamera;
    self.picker.delegate=self;
    //设置录像媒体类型
    self.picker.mediaTypes=@[(NSString *)kUTTypeMovie];
    //kUTTypeVideo 有视频没声音 movie有视频有声音
    self.picker.cameraDevice=UIImagePickerControllerCameraDeviceRear;
    //视频质量
    self.picker.videoQuality=UIImagePickerControllerQualityTypeMedium;
    //设置捕获方式为视频录制
    self.picker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;

    [self.parent presentViewController:self.picker animated:YES completion:nil];

    if(self.delegate&&[self.delegate respondsToSelector:@selector(videoToolDidSucessed:)]){
        [self.delegate videoToolDidSucessed:self];
    }
    return YES;
}
/**
 打开视频

 @param source 视频源
 */
-(void)openPlayerWithSource:(NSString *)source{

    NSString *src=source;
    src=[HGBVideoTool urlAnalysis:src];
    if(![HGBVideoTool urlExistCheck:src]){
        HGBLog(@"文件不存在");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(videoTool:didFailedWithError:)]){
            [self.delegate videoTool:self didFailedWithError:@{ReslutCode:@(HGBVideoToolErrorTypeNotExistPath).stringValue,ReslutMessage:@"文件不存在"}];
        }
        return;
    }
    NSURL *url=[NSURL URLWithString:src];

    AVPlayerViewController *playerVC=[[AVPlayerViewController alloc]init];
    AVPlayer *player=[[AVPlayer alloc]initWithURL:url];
    [playerVC setPlayer:player];
    [[HGBVideoTool currentViewController] presentViewController:playerVC animated:YES completion:nil];
}
#pragma mark ImagePickerDelegate
//拿出图片
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSURL *url=info[UIImagePickerControllerMediaURL];
    if(self.isSaveToCache){
        [self saveFileToCaches:[url path]];
    }

    if(self.isSaveToAlbum){
        UISaveVideoAtPathToSavedPhotosAlbum([url pathExtension], self, @selector(video:  didFinishSavingWithError: contextInfo:),NULL);

    }
    //隐藏选取照片控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker=nil;
    instance=nil;

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    HGBLog(@"取消");
    if(self.delegate&&[self.delegate respondsToSelector:@selector(videoToolDidCanceled:)]){
        [self.delegate videoToolDidCanceled:self];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker=nil;
    instance=nil;
}
#pragma mark 保存到缓存
/**
 文件保存到缓存

 @param filePath 文件路径
 */
-(void)saveFileToCaches:(NSString *)filePath{
    NSString *dirPath=[NSString stringWithFormat:@"caches://media/%@",[filePath lastPathComponent]];
    dirPath=[[NSURL URLWithString:[HGBVideoTool urlAnalysis:dirPath]] path];
    NSString *path=[HGBVideoTool urlEncapsulation:dirPath];
    NSString *directoryPath=[dirPath stringByDeletingLastPathComponent];
    if(![HGBVideoTool isExitAtFilePath:directoryPath]){
        [HGBVideoTool createDirectoryPath:directoryPath];
    }

    [HGBVideoTool copyFilePath:filePath ToPath:dirPath];
    if([HGBVideoTool isExitAtFilePath:dirPath]){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(videoTool:didSucessSaveToCachePath:)]){
            [self.delegate videoTool:self didSucessSaveToCachePath:path];
        }
    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(videoToolDidFailToSaveToCache:)]){
            [self.delegate videoToolDidFailToSaveToCache:self];
        }
    }
}
/**
 图片保存到缓存

 @param image 图片
 */
-(void)saveImageToCaches:(UIImage *)image{
    NSString *dirPath=[NSString stringWithFormat:@"caches://media/%@.png",[HGBVideoTool getSecondTimeStringSince1970]];
    dirPath=[[NSURL URLWithString:[HGBVideoTool urlAnalysis:dirPath]] path];
    NSString *path=[HGBVideoTool urlEncapsulation:dirPath];
    NSString *directoryPath=[dirPath stringByDeletingLastPathComponent];
    if(![HGBVideoTool isExitAtFilePath:directoryPath]){
        [HGBVideoTool createDirectoryPath:directoryPath];
    }
    NSData *data=UIImagePNGRepresentation(image);
    [data writeToFile:dirPath atomically:YES];

    if([HGBVideoTool isExitAtFilePath:dirPath]){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(videoTool:didSucessSaveToCachePath:)]){

            [self.delegate videoTool:self didSucessSaveToCachePath:path];
        }
    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(videoToolDidFailToSaveToCache:)]){
            [self.delegate videoToolDidFailToSaveToCache:self];
        }
    }
}
#pragma mark 保存相册结果
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if(error){
        HGBLog(@"视频保存相册失败");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(videoToolDidFailToSaveToAlbum:)]){
            [self.delegate videoToolDidFailToSaveToAlbum:self];
        }

    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(videoToolDidSucessToSaveToAlbum:)]){
            [self.delegate videoToolDidSucessToSaveToAlbum:self];
        }

    }
}
#pragma mark set
-(void)jumpToSet{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"麦克风访问权限受限" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alert addAction:action1];
    UIAlertAction *action2=[UIAlertAction actionWithTitle:@"去设置" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

        if([[UIApplication sharedApplication] canOpenURL:url]) {

            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];

        }

    }];
    [alert addAction:action2];
    [[HGBVideoTool currentViewController] presentViewController:alert animated:YES completion:nil];
}
#pragma mark 权限判断
/**
 相机权限判断

 @return 是否有权限
 */
+ (BOOL)isCanUseCamera {
    if (TARGET_IPHONE_SIMULATOR) {
        return NO;
    }
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        HGBLog(@"%@",granted ? @"相机准许":@"相机不准许");
    }];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return NO;
    }

    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}
#pragma mark prompt
-(void)alertWithPrompt:(NSString *)prompt{
#ifdef __IPHONE_8_0
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action=[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action];
    [[HGBVideoTool currentViewController] presentViewController:alert animated:YES completion:nil];
#else
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:prompt delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    alertview.tag=0;
    [alertview show];
#endif
}
-(void)alertAuthorityWithPrompt:(NSString *)prompt {
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"权限提示" message:prompt preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"设置" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        if(![HGBVideoTool openAppSetView]){
            [self alertWithPrompt:@"跳转失败,请在设置界面开启权限"];
        }

    }];
    [alert addAction:action1];
    UIAlertAction *action2=[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action2];
    [[HGBVideoTool currentViewController] presentViewController:alert animated:YES completion:nil];

}


/**
 打开设置界面

 @return 结果
 */
+(BOOL)openAppSetView{

    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {

#ifdef __IPHONE_10_0
        static BOOL sucessFlag=YES;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);

        [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:^(BOOL success) {
            sucessFlag=success;
            //发出已完成的信号
            dispatch_semaphore_signal(semaphore);
        }];


        //等待执行，不会占用资源
        dispatch_semaphore_wait(semaphore, 20);
        return sucessFlag;
#else
        return [[UIApplication sharedApplication]openURL:url];
#endif
    }else{
        return NO;
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

#pragma mark 文件
/**
 文件拷贝

 @param srcPath 文件路径
 @param filePath 复制文件路径
 @return 结果
 */
+(BOOL)copyFilePath:(NSString *)srcPath ToPath:(NSString *)filePath{
    if(![HGBVideoTool isExitAtFilePath:srcPath]){
        return NO;
    }
    NSString *directoryPath=[filePath stringByDeletingLastPathComponent];
    if(![HGBVideoTool isExitAtFilePath:directoryPath]){
        [HGBVideoTool createDirectoryPath:directoryPath];
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

 @param srcPath 文件路径
 @param filePath 复制文件路径
 @return 结果
 */
+(BOOL)moveFilePath:(NSString *)srcPath ToPath:(NSString *)filePath{
    if(![HGBVideoTool isExitAtFilePath:srcPath]){
        return NO;
    }
    NSString *directoryPath=[filePath stringByDeletingLastPathComponent];
    if(![HGBVideoTool isExitAtFilePath:directoryPath]){
        [HGBVideoTool createDirectoryPath:directoryPath];
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL flag=[filemanage moveItemAtPath:srcPath toPath:filePath error:nil];
    if(flag){
        return YES;
    }else{
        return NO;
    }
}
#pragma mark 文档通用
/**
 删除文档

 @param filePath 归档的路径
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

 @param filePath 归档的路径
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

#pragma mark 文件夹

/**
 创建文件夹

 @param directoryPath 路径
 @return 结果
 */
+(BOOL)createDirectoryPath:(NSString *)directoryPath{
    if([HGBVideoTool isExitAtFilePath:directoryPath]){
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
    if(![HGBVideoTool isURL:url]){
        return NO;
    }
     url=[HGBVideoTool urlAnalysis:url];
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
    if(![HGBVideoTool isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBVideoTool urlAnalysis:url];
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
    if(![HGBVideoTool isURL:url]){
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
    if(![HGBVideoTool isURL:url]){
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


#pragma mark 获取当前控制器

/**
 获取当前控制器

 @return 当前控制器
 */
+(UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [HGBVideoTool findBestViewController:viewController];
}

/**
 寻找上层控制器

 @param vc 控制器
 @return 上层控制器
 */
+ (UIViewController *)findBestViewController:(UIViewController *)vc
{
    if (vc.presentedViewController) {
        // Return presented view controller
        return [HGBVideoTool findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBVideoTool findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBVideoTool findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBVideoTool findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        return vc;
    }
}
#pragma mark get
-(UIImagePickerController *)picker{
    if(_picker==nil){
        _picker=[[UIImagePickerController alloc]init];
        _picker.delegate=self;
    }
    return _picker;
}
@end
