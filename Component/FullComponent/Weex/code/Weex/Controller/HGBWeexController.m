//
//  HGBWeexController.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/10/13.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBWeexController.h"
#import "HGBWeexPluginManager.h"
#import <WeexSDK/WeexSDK.h>
#import "WeexSDKManager.h"
#import <CoreTelephony/CTCellularData.h>


#define kWidth [[UIScreen mainScreen] bounds].size.width
#define kHeight [[UIScreen mainScreen] bounds].size.height
#define SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]//系统版本号
//屏幕比例
#define wScale kWidth / 750.0
#define hScale kHeight / 1334.0

#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@interface HGBWeexController ()<UIAlertViewDelegate>
@property(strong,nonatomic)WXSDKInstance *instance;
@property(strong,nonatomic)UIView *weexView;
/**
 功能按钮
 */
@property(strong,nonatomic)UIButton *actionButton;
/**
 基础url字符串
 */
@property(strong,nonatomic)NSString *baseUrlString;



@end

@implementation HGBWeexController
#pragma mark life
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self createBackButton];
    _instance = [[WXSDKInstance alloc] init];
    _instance.viewController = self;
    _instance.frame = self.view.frame;
    __weak HGBWeexController* weakSelf= self;
    _instance.onCreate = ^(UIView *view) {
        [weakSelf.weexView removeFromSuperview];
        weakSelf.weexView = view;
        [weakSelf.view addSubview:weakSelf.weexView];
    };
    _instance.onFailed = ^(NSError *error) {
        //process failure
    };
    _instance.renderFinish = ^ (UIView *view) {
        [weakSelf.view bringSubviewToFront:weakSelf.actionButton];
    };
    [self loadJSSource:@"project://WeexBundle/bundlejs/app.weex.js"];


}
#pragma mark 加载
/**
 加载html

 @param source 路径或url或js字符串
 */
-(BOOL)loadJSSource:(NSString *)source{
    if(source==nil||source.length==0){
        source=@"";
    }
    if([source hasPrefix:@"http://"]||[source hasPrefix:@"https://"]){
        CTCellularData *cellularData = [[CTCellularData alloc]init];
        cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state){

            switch (state) {
                case kCTCellularDataRestricted:
                    // app网络权限受限
                    [self jumpToSet];
                    break;
                case kCTCellularDataRestrictedStateUnknown:
                    // app网络权限不确定
                    // 各种操作
                    break;
                case kCTCellularDataNotRestricted:
                    break;
                default:
                    break;
            }
        };
    }

     if([self isURL:source]){
        source=[self urlAnalysis:source];
        source=[self urlFormatString:source];

       return [self loadWeexViewWithString:source andWithType:0];
    }else{
       return [self loadWeexViewWithString:source andWithType:1];

    }
}
/**
 加载js

 @param source 路径或url或js字符串
 @param baseUrl 基础路径或url或js字符串
 */
-(BOOL)loadJSSource:(NSString *)source andWithBaseUrl:(NSString *)baseUrl{
    self.baseUrlString=[self urlAnalysis:baseUrl];
    return  [self loadJSSource:source];

}
/**
 加载网页

 @param string url或内容
 @param type  0:网页 1.js字符串
 */
-(BOOL)loadWeexViewWithString:(NSString *)string andWithType:(NSInteger)type
{

    _instance = [[WXSDKInstance alloc] init];
    _instance.viewController = self;
    _instance.frame = self.view.frame;
    __weak HGBWeexController* weakSelf= self;
    _instance.onCreate = ^(UIView *view) {
        [weakSelf.weexView removeFromSuperview];
        weakSelf.weexView = view;
        [weakSelf.view addSubview:weakSelf.weexView];
    };
    _instance.onFailed = ^(NSError *error) {
        //process failure
    };
    __weak HGBWeexController *weakSelf2=self;
    _instance.renderFinish = ^ (UIView *view) {
        [weakSelf2.view bringSubviewToFront:weakSelf2.actionButton];

    };
    [HGBWeexPluginManager registerWeexPlugin];
    [WeexSDKManager initWeexSDK];

    if(type==0){

         NSURL *url=[NSURL URLWithString:string];
        
        [_instance renderWithURL:url];
    }else{

        NSURL *baseUrl;
        if(self.baseUrlString){
            baseUrl=[NSURL URLWithString:self.baseUrlString];
        }
        if (baseUrl==nil) {
            baseUrl=[NSURL URLWithString:@""];
        }

        [_instance renderView:string options:@{@"bundleUrl":[[baseUrl absoluteString] stringByDeletingLastPathComponent]} data:[string dataUsingEncoding:NSUTF8StringEncoding]];

    }
     [self.view bringSubviewToFront:self.actionButton];

    if(type==0){

        if(![self urlExistCheck:string]){
            return NO;
        }
    }

    return YES;
}
- (void)dealloc
{
    [_instance destroyInstance];
}
#pragma mark 功能按钮
-(void)createBackButton{
    [self creatFunctionButton];
}
-(void)creatFunctionButton{
    self.actionButton=[UIButton buttonWithType:(UIButtonTypeSystem)];
    self.actionButton.frame=CGRectMake(kWidth-100, kHeight-64-100,128*hScale,128*wScale);

    if(self.returnButtonPositionType==HGBWeexCloseButtonPositionTypeTopLeft){
        self.actionButton.frame=CGRectMake(5,5,128*hScale,128*wScale);
    }else if (self.returnButtonPositionType==HGBWeexCloseButtonPositionTypeTopRight){
        self.actionButton.frame=CGRectMake(kWidth-5-128*wScale,5,128*hScale,128*wScale);
    }else if (self.returnButtonPositionType==HGBWeexCloseButtonPositionTypeBottomRight){
        self.actionButton.frame=CGRectMake(kWidth-5-128*wScale,kHeight-5-128*hScale,128*hScale,128*wScale);
    }else if (self.returnButtonPositionType==HGBWeexCloseButtonPositionTypeBottomLeft){
        self.actionButton.frame=CGRectMake(5,kHeight-5-128*hScale,128*hScale,128*wScale);
    }
    [self.actionButton setImage:[[UIImage imageNamed:@"HGBWeexBundle.bundle/webview_close.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:(UIControlStateNormal)];
    [self.actionButton addTarget:self action:@selector(actionButtonHandle:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:self.actionButton];
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandler:)];
    [self.actionButton addGestureRecognizer:pan];

    if(self.isShowReturnButton){
        self.actionButton.hidden=NO;
    }else{
        self.actionButton.hidden=YES;
    }
}
-(void)actionButtonHandle:(UIButton *)_b{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)panHandler:(UIPanGestureRecognizer *)_p
{
    if(self.returnButtonDragType==HGBWeexCloseButtonDragTypeNO){

    }else if(self.returnButtonDragType==HGBWeexCloseButtonDragTypeNOLimit){
        CGPoint point= [_p locationInView:self.view];
        self.actionButton.center=point;
    }else if(self.returnButtonDragType==HGBWeexCloseButtonDragTypeBorder){
        CGPoint point= [_p locationInView:self.view];
        self.actionButton.center=point;

        if(_p.state==UIGestureRecognizerStateEnded){
            CGFloat l=0.0,t=0.0,b=0.0,r=0.0;

            l=point.x;
            t=point.y;
            r=kWidth-point.x;
            b=kHeight-point.y;
            CGFloat position=[self getMinFromArray:@[[NSString stringWithFormat:@"%f",t],[NSString stringWithFormat:@"%f",b],[NSString stringWithFormat:@"%f",r],[NSString stringWithFormat:@"%f",l]]];

            if(position==l){
                self.actionButton.frame=CGRectMake(5,self.actionButton.frame.origin.y , self.actionButton.frame.size.width, self.actionButton.frame.size.height);
            }else if (position==r){
                self.actionButton.frame=CGRectMake(kWidth-5-self.actionButton.frame.size.width,self.actionButton.frame.origin.y , self.actionButton.frame.size.width, self.actionButton.frame.size.height);
            }else if (position==t){
                self.actionButton.frame=CGRectMake(self.actionButton.frame.origin.x,5 , self.actionButton.frame.size.width, self.actionButton.frame.size.height);
            }else if (position==b){
                self.actionButton.frame=CGRectMake(self.actionButton.frame.origin.x,kHeight-5-self.actionButton.frame.size.height, self.actionButton.frame.size.width, self.actionButton.frame.size.height);
            }


        }

    }

}
-(CGFloat )getMinFromArray:(NSArray *)array{
    if(array.count>0){
        NSString* postion=array[0];
        for(NSString *i in array){
            if(i.floatValue<postion.floatValue){
                postion=i;
            }
        }
        return postion.floatValue;
    }else{
        return 0;
    }
}
#pragma mark --set
-(void)jumpToSet{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"网络访问权限受限" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self actionButtonHandle:nil];
    }];
    [alert addAction:action1];
    UIAlertAction *action2=[UIAlertAction actionWithTitle:@"去设置" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

        if([[UIApplication sharedApplication] canOpenURL:url]) {

            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];

        }
         [self actionButtonHandle:nil];
    }];
    [alert addAction:action2];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark url
/**
 *  url字符处理
 *
 *  @param urlString 原url
 *
 *  @return 新url
 */
-(NSString *)urlFormatString:(NSString *)urlString{
    return [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}
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
#pragma mark setter
-(void)setIsShowReturnButton:(BOOL)isShowReturnButton{
    _isShowReturnButton=isShowReturnButton;
    if(_isShowReturnButton){
        self.actionButton.hidden=NO;
    }else{
        self.actionButton.hidden=YES;
    }
}
@end

