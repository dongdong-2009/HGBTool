//
//  HGBCordovaController.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/10/13.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBCordovaController.h"


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

@interface HGBCordovaController ()
/**
 状态栏view
 */
@property(strong,nonatomic)UIView *statusBarView;
/**
 功能按钮
 */
@property(strong,nonatomic)UIButton *actionButton;
/**
 基础url字符串
 */
@property(strong,nonatomic)NSString *baseUrlString;



@end

@implementation HGBCordovaController
#pragma mark init
- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        NSString *docmentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//     
//        NSFileManager *fileMgr = [NSFileManager defaultManager];
//        NSString *wwwPath = [docmentPath stringByAppendingPathComponent:@"www/"];
//        if ([fileMgr fileExistsAtPath:wwwPath]) {
//            self.wwwFolderName = [NSString stringWithFormat:@"file:///%@",wwwPath];
//        }else{
//            self.wwwFolderName = @"www/";
//        }
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // View defaults to full size.  If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.

    [super viewWillAppear:animated];
#ifdef __IPHONE_10_0
        self.webView.frame=CGRectMake(self.webView.frame.origin.x,-20, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height+20);
#else
        self.webView.frame=CGRectMake(self.webView.frame.origin.x,0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
#endif

//    self.webView.frame=CGRectMake(self.webView.frame.origin.x,20, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-20);
    if(![self.statusBarView superview]){
//        self.statusBarView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 20)];
//        self.statusBarView.backgroundColor=[UIColor whiteColor];
//
//        [self.view addSubview:self.statusBarView];

    }
     [self.view bringSubviewToFront:self.actionButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createBackButton];
}
#pragma mark 加载

/**
 加载html

 @param source 路径或url或html字符串
 */
-(BOOL)loadHtmlSource:(NSString *)source{
    if(source==nil||source.length==0){
        source=@"";
    }
     if([self isURL:source]){
        source=[self urlAnalysis:source];
         source=[self urlFormatString:source];
       return [self loadWebViewWithString:source andWithType:0];
    }else{
       return [self loadWebViewWithString:source andWithType:1];

    }


}
/**
 加载html

 @param source 路径或url或html字符串
 @param baseUrl 基础路径或url或html字符串
 */
-(BOOL)loadHtmlSource:(NSString *)source andWithBaseUrl:(NSString *)baseUrl{
    self.baseUrlString=[self urlAnalysis:baseUrl];
    return  [self loadHtmlSource:source];

}


/**
 加载网页

 @param string url或内容
 @param type  0:网页 1.html字符串
 */
-(BOOL)loadWebViewWithString:(NSString *)string andWithType:(NSInteger)type{

    NSURL *loadurl;

    if(type==1){
        self.startPage=string;
        NSURL *baseUrl;
        if(self.baseUrlString){
            baseUrl=[NSURL URLWithString:self.baseUrlString];
        }
        [self.webView loadHTMLString:string baseURL:baseUrl];
        return YES;
    }else{

        string=[self urlAnalysis:string];
        loadurl=[NSURL URLWithString:string];
    }
    self.startPage=string;

    NSURLRequest *request = [NSURLRequest requestWithURL:loadurl];
    [self.webView loadRequest:request];
    [self.view bringSubviewToFront:self.actionButton];

    if(![self urlExistCheck:string]){
        return NO;
    }
    return YES;
}

#pragma mark 功能按钮
-(void)createBackButton{
    [self creatFunctionButton];
}
-(void)creatFunctionButton{
    self.actionButton=[UIButton buttonWithType:(UIButtonTypeSystem)];
    self.actionButton.frame=CGRectMake(kWidth-100, kHeight-64-100,128*hScale,128*wScale);

    if(self.returnButtonPositionType==HGBCordovaCloseButtonPositionTypeTopLeft){
        self.actionButton.frame=CGRectMake(5,5,128*hScale,128*wScale);
    }else if (self.returnButtonPositionType==HGBCordovaCloseButtonPositionTypeTopRight){
        self.actionButton.frame=CGRectMake(kWidth-5-128*wScale,5,128*hScale,128*wScale);
    }else if (self.returnButtonPositionType==HGBCordovaCloseButtonPositionTypeBottomRight){
        self.actionButton.frame=CGRectMake(kWidth-5-128*wScale,kHeight-5-128*hScale,128*hScale,128*wScale);
    }else if (self.returnButtonPositionType==HGBCordovaCloseButtonPositionTypeBottomLeft){
        self.actionButton.frame=CGRectMake(5,kHeight-5-128*hScale,128*hScale,128*wScale);
    }
    [self.actionButton setImage:[[UIImage imageNamed:@"HGBCordovaBundle.bundle/webview_close.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:(UIControlStateNormal)];
    [self.actionButton addTarget:self action:@selector(actionButtonHandle:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:self.actionButton];
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandler:)];
    [self.actionButton addGestureRecognizer:pan];
    if(_isShowReturnButton){
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
    if(self.returnButtonDragType==HGBCordovaCloseButtonDragTypeNO){

    }else if(self.returnButtonDragType==HGBCordovaCloseButtonDragTypeNOLimit){
        CGPoint point= [_p locationInView:self.view];
        self.actionButton.center=point;
    }else if(self.returnButtonDragType==HGBCordovaCloseButtonDragTypeBorder){
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
/* Comment out the block below to over-ride */

/*
 - (UIWebView*) newCordovaViewWithFrame:(CGRect)bounds
 {
 return[super newCordovaViewWithFrame:bounds];
 }

 - (NSUInteger)supportedInterfaceOrientations
 {
 return [super supportedInterfaceOrientations];
 }

 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
 {
 return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
 }

 - (BOOL)shouldAutorotate
 {
 return [super shouldAutorotate];
 }
 */
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

#pragma mark 状态栏
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end

@implementation HGBCordovaCommandDelegate

/* To override the methods, uncomment the line in the init function(s)
 in MainViewController.m
 */

#pragma mark CDVCommandDelegate implementation

- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

- (NSString*)pathForResource:(NSString*)resourcepath
{
    return [super pathForResource:resourcepath];
}

@end

@implementation HGBCordovaCommandQueue

/* To override, uncomment the line in the init function(s)
 in MainViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}

@end
