//
//  HGBVersionTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/11/16.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBVersionTool.h"
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>



#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif



#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"


@interface HGBVersionTool ()<SKStoreProductViewControllerDelegate>

@end
@implementation HGBVersionTool

#pragma mark 初始化
static HGBVersionTool *instance=nil;
+(instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBVersionTool alloc]init];
    }
    return instance;
}
#pragma mark 功能
/**
 下载应用

 @param plistUrl manifest.plist url
 @return 结果
 */
+(BOOL)downLoadAppWithManifestPlistUrl:(NSString *)plistUrl{
    if(plistUrl==nil){
        return NO;
    }
    NSString *bundleIDID;
    NSDictionary *dic=[[NSDictionary alloc]initWithContentsOfURL:[NSURL URLWithString:plistUrl]];
    if(dic){
        NSArray *items=[dic objectForKey:@"items"];
        if(items&&items.count>0){
            NSDictionary *item=items[0];
            if(item){
                NSDictionary *metadata=[item objectForKey:@"metadata"];
                if(metadata){
                    bundleIDID=[metadata objectForKey:@"bundle-identifier"];
                }
            }
        }
    }
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",plistUrl]];
    if([[UIApplication sharedApplication]canOpenURL:url]){
#ifdef __IPHONE_8_0
        static BOOL sucessFlag=YES;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:^(BOOL success) {
            sucessFlag=success;
            //发出已完成的信号
            dispatch_semaphore_signal(semaphore);
        }];
        if([bundleIDID isEqualToString:[self getBundleID]]){
            exit(0);
        }
        
        
        //等待执行，不会占用资源
        dispatch_semaphore_wait(semaphore, 20);
        return sucessFlag;
#else
        if([bundleIDID isEqualToString:[HGBVersionTool getBundleID]]){
            exit(0);
        }
        return [[UIApplication sharedApplication]openURL:url];
#endif
        
    }else{
        return NO;
    }
}
/**
 下载应用

 @param path manifest.plist path
 @return 结果
 */
+(BOOL)downLoadAppWithManifestPlistPath:(NSString *)path{
    if(path==nil){
        return NO;
    }
    NSString *url=[HGBVersionTool urlAnalysis:path];
    return  [HGBVersionTool downLoadAppWithManifestPlistUrl:[[NSURL URLWithString:url]absoluteString]];

}
/**
 打开appstore应用界面

 @param appId appid
 @param reslut 结果
 */
-(void)openAppInAppStoreWithAppID:(NSString *)appId andWithReslut:(void(^)(BOOL status,NSDictionary *message))reslut
{
    if(appId==nil){
        reslut(NO,@{ReslutCode:@(0),ReslutMessage:@"appleID不能为空"});
        return;
    }
    SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
    //加载一个新的视图展示
    storeProductViewContorller.delegate=self;
    [storeProductViewContorller loadProductWithParameters:
     //appId唯一的
     @{SKStoreProductParameterITunesItemIdentifier : appId} completionBlock:^(BOOL result, NSError *error) {
         //block回调
         if(error){
             HGBLog(@"error %@ with userInfo %@",error,[error userInfo]);
             reslut(NO,@{ReslutCode:@(error.code),ReslutMessage:error.localizedDescription});
         }else{
             reslut(YES,@{ReslutCode:@(1),ReslutMessage:@"ok"});
             //模态弹出appstore
             [[HGBVersionTool currentViewController] presentViewController:storeProductViewContorller animated:YES completion:nil];
         }
     }];
}
/**
 打开appstore应用界面

 @param appId appid
 */
+(BOOL)openAppInAppStoreWithAppID:(NSString *)appId{
    if(appId==nil){
        return NO;
    }
    NSString* appstoreUrlString =[NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/hun-lian-dui-xiang/id%@?mt=8",appId];//appstore中的地址，稍作修改

    NSURL* url = [NSURL URLWithString:appstoreUrlString];

    if([[UIApplication sharedApplication]canOpenURL:url]){

        return [[UIApplication sharedApplication]openURL:url];

    }else{

        return NO;
    }

}

/**
 打开appstore应用评价界面

 @param appId appid
 */
+(BOOL)openAppVerbInAppStoreWithAppID:(NSString *)appId{
    if(appId==nil){
        return NO;
    }
    NSString* appstoreUrlString =[NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",appId];//appstore中的地址，稍作修改

    NSURL* url = [NSURL URLWithString:appstoreUrlString];

    if([[UIApplication sharedApplication]canOpenURL:url]){

        return [[UIApplication sharedApplication]openURL:url];

    }else{

        return NO;
    }



}
//取消按钮监听
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [[HGBVersionTool currentViewController] dismissViewControllerAnimated:YES completion:^{

    }];
}
/**
 获取appstore应用信息

 @param appId appid
 @param reslut 结果
 */
+(void)getAppInfoFromAppStoreWithAppID:(NSString *)appId andWithReslut:(void(^)(BOOL status,NSDictionary *message))reslut{
    if(appId==nil){
        reslut(NO,@{ReslutCode:@(0),ReslutMessage:@"appleID不能为空"});
        return;
    }
    NSURL *nsurl = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@",appId]];



    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task=[session dataTaskWithURL:nsurl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) { //请求失败
            HGBLog(@"error %@ with userInfo %@",error,[error userInfo]);
            reslut(NO,@{ReslutCode:@(error.code),ReslutMessage:error.localizedDescription});
        } else {  //请求成功
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

            reslut(YES,@{ReslutCode:@(1),ReslutMessage:dic});
        }

    }];
    //启动任务
    [task resume];



}
#pragma mark bundleid
/**
 获取BundleID

 @return BundleID
 */
+(NSString*) getBundleID
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];

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
    if(![HGBVersionTool isURL:url]){
        return NO;
    }
     url=[HGBVersionTool urlAnalysis:url];
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
    if(![HGBVersionTool isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBVersionTool urlAnalysis:url];
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
    if(![HGBVersionTool isURL:url]){
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
    if([HGBVersionTool isURL:url]){
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
    return [HGBVersionTool findBestViewController:viewController];
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
        return [HGBVersionTool findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBVersionTool findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBVersionTool findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBVersionTool findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        return vc;
    }
}
@end
