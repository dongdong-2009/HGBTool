
//
//  HGBAirPrintTool.m
//  测试
//
//  Created by huangguangbao on 2018/1/3.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBAirPrintTool.h"
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"




@interface HGBAirPrintTool()<UIPrintInteractionControllerDelegate>


@end


@implementation HGBAirPrintTool
#pragma mark init
static HGBAirPrintTool *instance=nil;
+ (instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBAirPrintTool alloc]init];
        instance.isShowPage=YES;
        instance.isShowPages=YES;
        instance.duplex=UIPrintInfoDuplexLongEdge;
        instance.outType=UIPrintInfoOutputGeneral;
    }
    return instance;
}

#pragma mark 功能
/**
 打印文件

 @param source 数据源  NSString（url或path）NSData, NSURL, UIImage,   Array(array of NSString（url或path） NSData, NSURL, UIImage, )
 */
-(void)printWithSource:(id)source{
    if(source==nil){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(print:didFailedWithError:)]){
            [self.delegate print:self didFailedWithError:@{ReslutCode:@(HGBAirPrintToolErrorParams).stringValue,ReslutMessage:@"数据源不能为空"}];
        }
        return;
    }
    if(!([source isKindOfClass:[NSString class]]||[source isKindOfClass:[NSData class]]||[source isKindOfClass:[UIImage class]]||[source isKindOfClass:[NSURL class]]||[source isKindOfClass:[NSArray class]]||[source isKindOfClass:[UIView class]])){
        HGBLog(@"数据格式不正确");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(print:didFailedWithError:)]){
            [self.delegate print:self didFailedWithError:@{ReslutCode:@(HGBAirPrintToolErrorParams).stringValue,ReslutMessage:@"数据格式不正确"}];
        }
        return;
    }



    UIPrintInteractionController *print=[UIPrintInteractionController sharedPrintController];



    if([source isKindOfClass:[NSData class]]||[source isKindOfClass:[UIImage class]]||[source isKindOfClass:[NSURL class]]){
         [self setPrintInteractionWithObject:source inPrintInteractionController:print];

    }else if([source isKindOfClass:[NSString class]]){
        if([source hasPrefix:@"project://"]||[source hasPrefix:@"home://"]||[source hasPrefix:@"document://"]||[source hasPrefix:@"caches://"]||[source hasPrefix:@"tmp://"]||[source hasPrefix:@"http://"]||[source hasPrefix:@"https://"]||[source hasPrefix:@"file://"]||[source hasPrefix:@"tcp://"]||[source hasPrefix:@"/var"]||[source hasPrefix:@"/User"]){
            [self setPrintInteractionWithObject:source inPrintInteractionController:print];
        }else{
            [self setPrintInteractionWithHtmlString:source inPrintInteractionController:print];
        }
    } else if ([source isKindOfClass:[NSArray class]]){
        [self setPrintInteractionWithArray:source inPrintInteractionController:print];
    }else if ([source isKindOfClass:[UIView class]]){
        [self setPrintInteractionWithView:source inPrintInteractionController:print];
    }
    print.delegate = self;
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = self.outType;
    if(self.title){
        printInfo.jobName =self.title;
    }
    printInfo.duplex = self.duplex;
    if(self.printID){
        printInfo.printerID=self.printID;
    }
    print.printInfo = printInfo;
    print.showsPageRange = self.isShowPage;
    print.showsNumberOfCopies=self.isShowPages;


    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
        if (!completed && error){
            HGBLog(@"打印失败");
            HGBLog(@"FAILED! due to error in domain %@ with error code %ld",
                   error.domain, (long)error.code);
            if(self.delegate&&[self.delegate respondsToSelector:@selector(print:didFailedWithError:)]){
                [self.delegate print:self didFailedWithError:@{ReslutCode:@(HGBAirPrintToolErrorPrint).stringValue,ReslutMessage:@"打印失败"}];
            }
        }else{
            if(self.delegate&&[self.delegate respondsToSelector:@selector(printDidSucessed:)]){
                [self.delegate printDidSucessed:self];
            }
        }

    };

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if(self.printButtonItem==nil){
            HGBLog(@"请设置打印按钮");
            if(self.delegate&&[self.delegate respondsToSelector:@selector(print:didFailedWithError:)]){
                [self.delegate print:self didFailedWithError:@{ReslutCode:@(HGBAirPrintToolErrorParams).stringValue,ReslutMessage:@"请设置打印按钮"}];
            }
            return;
        }
        [print presentFromBarButtonItem:self.printButtonItem animated:YES
                      completionHandler:completionHandler];
    } else {
        [print presentAnimated:YES completionHandler:completionHandler];
    }

}

/**
 打印对象

 @param object 数据源
 */
-(void)printWithObject:(id)object{
    [self printWithSource:object];
}
/**
 打印URL

 @param url url数据源
 */
-(void)printWithURL:(NSURL *)url{
    [self printWithSource:url];
}
/**
 打印数组

 @param array 数组数据源
 */
-(void)printWithArray:(NSArray *)array{

    [self printWithSource:array];
}
/**
 打印数据

 @param data 数据
 */
-(void)printWithData:(NSData *)data{
    [self printWithSource:data];
}/**
  打印view页面

  @param view view
  */
-(void)printWithView:(UIView *)view{
    [self printWithSource:view];
}
#pragma mark 打印机设置
/**
 设置打印机

 @param object 数据源对象
 @param print 打印控制器
 */
-(BOOL)setPrintInteractionWithObject:(id)object inPrintInteractionController:(UIPrintInteractionController *)print{
    if(!([object isKindOfClass:[NSString class]]||[object isKindOfClass:[NSData class]]||[object isKindOfClass:[UIImage class]]||[object isKindOfClass:[NSURL class]])){
        HGBLog(@"数据格式不正确");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(print:didFailedWithError:)]){
            [self.delegate print:self didFailedWithError:@{ReslutCode:@(HGBAirPrintToolErrorParams).stringValue,ReslutMessage:@"数据格式不正确"}];
        }
        return NO;
    }
    id data;
    if([object isKindOfClass:[NSString class]]){
        NSString *url=(NSString *)object;
        if([url hasPrefix:@"project://"]||[url hasPrefix:@"home://"]||[url hasPrefix:@"document://"]||[url hasPrefix:@"caches://"]||[url hasPrefix:@"tmp://"]||[url hasPrefix:@"http://"]||[url hasPrefix:@"https://"]||[url hasPrefix:@"file://"]||[url hasPrefix:@"tcp://"]){
            url=[HGBAirPrintTool urlAnalysis:url];
        }else{
            url=[[NSURL fileURLWithPath:url]absoluteString];
        }
        if(![HGBAirPrintTool urlExistCheck:url]){
            HGBLog(@"文件不存在");
            if(self.delegate&&[self.delegate respondsToSelector:@selector(print:didFailedWithError:)]){
                [self.delegate print:self didFailedWithError:@{ReslutCode:@(HGBAirPrintToolErrorParams).stringValue,ReslutMessage:@"文件不存在"}];
            }
            return NO;

        }
        data=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
        if(data==nil){
            HGBLog(@"URL对应数据不能为空");
            if(self.delegate&&[self.delegate respondsToSelector:@selector(print:didFailedWithError:)]){
                [self.delegate print:self didFailedWithError:@{ReslutCode:@(HGBAirPrintToolErrorParams).stringValue,ReslutMessage:@"URL对应数据不能为空"}];
            }
            return NO;
        }

    }else if ([object isKindOfClass:[NSData class]]){
        data=object;
        if  (!(print && [UIPrintInteractionController canPrintData: data]) ) {
            HGBLog(@"该格式数据不支持打印");
            if(self.delegate&&[self.delegate respondsToSelector:@selector(print:didFailedWithError:)]){
                [self.delegate print:self didFailedWithError:@{ReslutCode:@(HGBAirPrintToolErrorParams).stringValue,ReslutMessage:@"该格式数据不支持打印"}];
            }
            return NO;

        }
    }else if ([object isKindOfClass:[UIImage class]]){
        data=object;
    }else if ([object isKindOfClass:[NSURL class]]){
        data=object;
        if  (!(print && [UIPrintInteractionController canPrintURL: data]) ) {
            HGBLog(@"该URL数据不支持打印");
            if(self.delegate&&[self.delegate respondsToSelector:@selector(print:didFailedWithError:)]){
                [self.delegate print:self didFailedWithError:@{ReslutCode:@(HGBAirPrintToolErrorParams).stringValue,ReslutMessage:@"该URL数据不支持打印"}];
            }
            return NO;

        }
    }

    print.printingItem = data;
    return YES;

}
/**
 设置打印机

 @param array 数据源数组
 @param print 打印控制器
 */
-(BOOL)setPrintInteractionWithArray:(NSArray *)array inPrintInteractionController:(UIPrintInteractionController *)print{
    if (![array isKindOfClass:[NSArray class]]){
        HGBLog(@"数据格式不正确");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(print:didFailedWithError:)]){
            [self.delegate print:self didFailedWithError:@{ReslutCode:@(HGBAirPrintToolErrorParams).stringValue,ReslutMessage:@"数据格式不正确"}];
        }
        return NO;
    }
    NSMutableArray *arrayItem=[NSMutableArray array];
    for(id item in array){
        if([item isKindOfClass:[NSData class]]){
            NSData *dataItem=item;
            [arrayItem addObject:dataItem];
        }else if ([item isKindOfClass:[NSURL class]]){
            NSURL *urlItem=item;
            [arrayItem addObject:urlItem];
        }else if ([item isKindOfClass:[UIImage class]]){
            UIImage *imageItem=item;
            [arrayItem addObject:imageItem];
        }else if ([item isKindOfClass:[NSString class]]){
            NSData *dataItem;
            NSString *url=(NSString *)item;
            if([url hasPrefix:@"project://"]||[url hasPrefix:@"home://"]||[url hasPrefix:@"document://"]||[url hasPrefix:@"caches://"]||[url hasPrefix:@"tmp://"]||[url hasPrefix:@"http://"]||[url hasPrefix:@"https://"]||[url hasPrefix:@"file://"]||[url hasPrefix:@"tcp://"]){
                url=[HGBAirPrintTool urlAnalysis:url];
            }else{
                url=[[NSURL fileURLWithPath:url]absoluteString];
            }
            if(![HGBAirPrintTool urlExistCheck:url]){
                HGBLog(@"文件不存在");
                if(self.delegate&&[self.delegate respondsToSelector:@selector(print:didFailedWithError:)]){
                    [self.delegate print:self didFailedWithError:@{ReslutCode:@(HGBAirPrintToolErrorParams).stringValue,ReslutMessage:@"文件不存在"}];
                }
                return NO;

            }
            dataItem=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
            if(dataItem){
                HGBLog(@"URL对应数据不能为空");
                if(self.delegate&&[self.delegate respondsToSelector:@selector(print:didFailedWithError:)]){
                    [self.delegate print:self didFailedWithError:@{ReslutCode:@(HGBAirPrintToolErrorParams).stringValue,ReslutMessage:@"URL对应数据不能为空"}];
                }
                return NO;
            }
            [arrayItem addObject:dataItem];
        }else{
            HGBLog(@"数据格式不正确");
            if(self.delegate&&[self.delegate respondsToSelector:@selector(print:didFailedWithError:)]){
                [self.delegate print:self didFailedWithError:@{ReslutCode:@(HGBAirPrintToolErrorParams).stringValue,ReslutMessage:@"数据格式不正确"}];
            }
            return NO;
        }
    }
    print.printingItems=arrayItem;
    return YES;

}
/**
 设置打印机

 @param view 界面数据源
 @param print 打印控制器
 */
-(BOOL)setPrintInteractionWithView:(UIView *)view inPrintInteractionController:(UIPrintInteractionController *)print{
    if (![view isKindOfClass:[UIView class]]){
        HGBLog(@"数据格式不正确");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(print:didFailedWithError:)]){
            [self.delegate print:self didFailedWithError:@{ReslutCode:@(HGBAirPrintToolErrorParams).stringValue,ReslutMessage:@"数据格式不正确"}];
        }
        return NO;
    }

    UIViewPrintFormatter *viewFormatter = [[[UIView alloc]init] viewPrintFormatter];
    viewFormatter.startPage = 0;
    print.printFormatter = viewFormatter;
    return YES;

}
/**
 设置打印机

 @param string 字符串数据源
 @param print 打印控制器
 */
-(BOOL)setPrintInteractionWithHtmlString:(NSString *)string inPrintInteractionController:(UIPrintInteractionController *)print{
    if (![string isKindOfClass:[NSString class]]){
        HGBLog(@"数据格式不正确");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(print:didFailedWithError:)]){
            [self.delegate print:self didFailedWithError:@{ReslutCode:@(HGBAirPrintToolErrorParams).stringValue,ReslutMessage:@"数据格式不正确"}];
        }
        return NO;
    }

    UIMarkupTextPrintFormatter *htmlFormatter = [[UIMarkupTextPrintFormatter alloc]initWithMarkupText:string];
    htmlFormatter.startPage = 0;
    htmlFormatter.contentInsets = UIEdgeInsetsMake(72.0, 72.0, 72.0, 72.0); // 1 inch margins
    print.printFormatter = htmlFormatter;
    return YES;

}


#pragma mark delegate

- ( UIViewController * _Nullable )printInteractionControllerParentViewController:(UIPrintInteractionController *)printInteractionController{
    return [HGBAirPrintTool currentViewController];
}
//
//- (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)printInteractionController choosePaper:(NSArray<UIPrintPaper *> *)paperList{
//
//}

- (void)printInteractionControllerWillPresentPrinterOptions:(UIPrintInteractionController *)printInteractionController{

}
- (void)printInteractionControllerDidPresentPrinterOptions:(UIPrintInteractionController *)printInteractionController{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(printDidOpenPrintSet:)]){
        [self.delegate printDidOpenPrintSet:self];
    }
}
- (void)printInteractionControllerWillDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController{

}
- (void)printInteractionControllerDidDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(printDidClosePrintSet:)]){
        [self.delegate printDidClosePrintSet:self];
    }
}

- (void)printInteractionControllerWillStartJob:(UIPrintInteractionController *)printInteractionController{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(printDidStart:)]){
        [self.delegate printDidStart:self];
    }
}
- (void)printInteractionControllerDidFinishJob:(UIPrintInteractionController *)printInteractionController{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(printDidFinished:)]){
        [self.delegate printDidFinished:self];
    }
}

- (CGFloat)printInteractionController:(UIPrintInteractionController *)printInteractionController cutLengthForPaper:(UIPrintPaper *)paper NS_AVAILABLE_IOS(7_0){
    return 0;
}
//- (UIPrinterCutterBehavior) printInteractionController:(UIPrintInteractionController *)printInteractionController chooseCutterBehavior:(NSArray *)availableBehaviors NS_AVAILABLE_IOS(9_0){
//
//}



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
    if(![HGBAirPrintTool isURL:url]){
        return NO;
    }
     url=[HGBAirPrintTool urlAnalysis:url];
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
    if(![HGBAirPrintTool isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBAirPrintTool urlAnalysis:url];
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
    if(![HGBAirPrintTool isURL:url]){
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
    if(![HGBAirPrintTool isURL:url]){
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
#pragma mark 获取当前控制器
/**
 获取当前控制器

 @return 当前控制器
 */
+ (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [HGBAirPrintTool findBestViewController:viewController];
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
        return [HGBAirPrintTool findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBAirPrintTool findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBAirPrintTool findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBAirPrintTool findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

@end
