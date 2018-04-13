//
//  HGBAudioPlayer.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/30.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBAudioPlayer.h"
#import "HGBAudioTool.h"

#define kWidth [[UIScreen mainScreen] bounds].size.width
#define kHeight [[UIScreen mainScreen] bounds].size.height
//屏幕比例
#define wScale kWidth / 750.0
#define hScale kHeight / 1334.0


@interface HGBAudioPlayer ()<HGBAudioToolDelegate>
/**
 歌名
 */
@property(strong,nonatomic)UILabel *nameLabel;
/**
 作者
 */
@property(strong,nonatomic)UILabel *authorLabel;
/**
 歌集
 */
@property(strong,nonatomic)UILabel * albumLabel;
/**
 图片
 */
@property(strong,nonatomic)UIImageView * imageView;
/**
 歌词
 */
@property(strong,nonatomic)UILabel * lyricsLabel;
/**
 开始
 */
@property(strong,nonatomic)UIButton * startButton;
/**
 暂停
 */
@property(strong,nonatomic)UIButton * purseButton;
/**
 停止
 */
@property(strong,nonatomic)UIButton * stopButton;
/**
 进度
 */
@property(strong,nonatomic) UISlider *progressslider;
/**
 声音
 */
@property(strong,nonatomic) UISlider *soundslider;
/**
 信息
 */
@property(strong,nonatomic) NSArray *infos;
@end

@implementation HGBAudioPlayer
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
    titleLab.text=@"音频播放器";
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
    self.authorLabel=[[UILabel alloc]initWithFrame:CGRectMake(30*wScale, 100, (kWidth-90*wScale)*0.5, 30)];
    self.authorLabel.text=@"艺术家";
    self.authorLabel.textColor=[UIColor blueColor];
    self.authorLabel.textAlignment=NSTextAlignmentCenter;
    self.authorLabel.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:self.authorLabel];


    self.albumLabel=[[UILabel alloc]initWithFrame:CGRectMake( (kWidth-90*wScale)*0.5+60*wScale, 100, (kWidth-90*wScale)*0.5, 30)];
    self.albumLabel.text=@"专辑名";
    self.albumLabel.textColor=[UIColor blueColor];
    self.albumLabel.textAlignment=NSTextAlignmentCenter;
    self.albumLabel.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:self.albumLabel];


    self.imageView=[[UIImageView alloc]initWithFrame:CGRectMake( (kWidth-200*wScale)*0.5, 150, 200*wScale, 200*hScale)];
    [self.view addSubview:self.imageView];

    self.nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(30*wScale, 170+200*hScale,kWidth-60*wScale, 30)];
    self.nameLabel.text=@"歌名";
    self.nameLabel.textColor=[UIColor redColor];
    self.nameLabel.textAlignment=NSTextAlignmentCenter;
    self.nameLabel.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:self.nameLabel];




    self.lyricsLabel=[[UILabel alloc]initWithFrame:CGRectMake(30*wScale, 210+200*hScale,kWidth-60*wScale, 30)];
    self.lyricsLabel.text=@"歌词";
    self.lyricsLabel.textColor=[UIColor grayColor];
    self.lyricsLabel.textAlignment=NSTextAlignmentCenter;
    self.lyricsLabel.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:self.lyricsLabel];


    self.startButton=[UIButton buttonWithType:(UIButtonTypeSystem)];
    self.startButton.frame=CGRectMake(30*wScale,  250+200*hScale,(kWidth-120*wScale)*0.3, 30);
    [self.startButton addTarget:self action:@selector(buttonHandle:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.startButton setTitle:@"开始" forState:(UIControlStateNormal)];
    self.startButton.tag=0;
    [self.startButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    self.startButton.backgroundColor=[UIColor blueColor];
    [self.view addSubview:self.startButton];


    self.purseButton=[UIButton buttonWithType:(UIButtonTypeSystem)];
    self.purseButton.frame=CGRectMake(60*wScale+(kWidth-120*wScale)*0.3,  250+200*hScale,(kWidth-120*wScale)*0.3, 30);
    [self.purseButton addTarget:self action:@selector(buttonHandle:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.purseButton setTitle:@"暂停" forState:(UIControlStateNormal)];
    self.purseButton.tag=1;
    [self.purseButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    self.purseButton.backgroundColor=[UIColor blueColor];
    [self.view addSubview:self.purseButton];
    



    self.stopButton=[UIButton buttonWithType:(UIButtonTypeSystem)];
    self.stopButton.frame=CGRectMake(90*wScale+(kWidth-120*wScale)*0.3*2,  250+200*hScale,(kWidth-120*wScale)*0.3, 30);
    [self.stopButton addTarget:self action:@selector(buttonHandle:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.stopButton setTitle:@"结束" forState:(UIControlStateNormal)];
    self.stopButton.tag=2;
    [self.stopButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    self.stopButton.backgroundColor=[UIColor blueColor];
    [self.view addSubview:self.stopButton];


    self.progressslider=[[UISlider alloc]initWithFrame:CGRectMake(30*wScale,  300+200*hScale,(kWidth-60*wScale), 30)];
    [self.progressslider addTarget:self action:@selector(progressHandler:) forControlEvents:(UIControlEventValueChanged)];

    self.progressslider.minimumValue=0;
    self.progressslider.value=0;
    [self.view addSubview:self.progressslider];

    self.soundslider=[[UISlider alloc]initWithFrame:CGRectMake(30*wScale,  350+200*hScale,(kWidth-60*wScale), 30)];
    self.soundslider.maximumValue=100;
    self.soundslider.minimumValue=0;
    self.soundslider.value=20;
    [self.soundslider addTarget:self action:@selector(soundHandler:) forControlEvents:(UIControlEventValueChanged)];
    [self.view addSubview:self.soundslider];

    if(self.infos&&self.infos.count>0){
        NSDictionary *dic=self.infos[0];
        self.authorLabel.text=[dic objectForKey:@"artist"];
        self.albumLabel.text=[dic objectForKey:@"albumName"];
        self.nameLabel.text=[dic objectForKey:@"title"];
        NSData *data=[dic objectForKey:@"artwork"];
        UIImage *image=[UIImage imageWithData:data];
        self.imageView.image=image;
    }

}
-(void)setUrl:(NSString *)url{
    _url=url;
    _url=[self urlAnalysis:_url];
   
    [[HGBAudioTool shareInstance] initPlayerWithSource:_url];
    self.infos=[[HGBAudioTool shareInstance] getPlayerInfo];
    if(self.infos&&self.infos.count>0){
        NSDictionary *dic=self.infos[0];
        self.authorLabel.text=[dic objectForKey:@"artist"];
        self.albumLabel.text=[dic objectForKey:@"albumName"];
        self.nameLabel.text=[dic objectForKey:@"title"];
        NSData *data=[dic objectForKey:@"artwork"];
        UIImage *image=[UIImage imageWithData:data];
        self.imageView.image=image;
    }

   

}
#pragma mark action
-(void)buttonHandle:(UIButton *)_b{

    if(_b.tag==0){
        [[HGBAudioTool shareInstance] startPlayer];
            self.progressslider.maximumValue=[[HGBAudioTool shareInstance] getDuration];


        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
    }else if (_b.tag==1){
        [[HGBAudioTool shareInstance] parsePlayer];
    }else if (_b.tag==2){
        [[HGBAudioTool shareInstance] stopPlayer];
    }
}
#pragma mark timer
-(void)timer:(NSTimer *)_t
{
    self.progressslider.value=[[HGBAudioTool shareInstance] getCurrentTime];
}
-(void)progressHandler:(UISlider *)sender{
    [[HGBAudioTool shareInstance] setCurrentTime:self.soundslider.value];
}
-(void)soundHandler:(UISlider *)sender{
    [[HGBAudioTool shareInstance] setVolume: self.soundslider.value];

}
#pragma mark delegate
-(void)audioToolDidCanceled:(HGBAudioTool *)audio{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(audioPlayerDidCanceled:)]){
        [self.delegate audioPlayerDidCanceled:self];
    }
}
-(void)audioTool:(HGBAudioTool *)audio didFailedWithError:(NSDictionary *)errorInfo{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(audioPlayer:didFailedWithError:)]){
        [self.delegate audioPlayer:self didFailedWithError:errorInfo];
    }
}
-(void)audioToolDidSucessed:(HGBAudioTool *)audio{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(audioPlayerDidSucessed:)]){
        [self.delegate audioPlayerDidSucessed:self];
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
