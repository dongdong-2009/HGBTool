//
//  HGBCompassViewController.m
//  测试
//
//  Created by huangguangbao on 2018/1/16.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBCompassViewController.h"
#import "HGBCompassTool.h"
#import "HGBCompassView.h"
#import "HGBCompassHeader.h"



#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif



#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"


@interface HGBCompassViewController ()<HGBCompassToolDelegate,UIAlertViewDelegate>{
    HGBCompassView * _scaView;
    UILabel * _directionLabel;
    UILabel * _angleLabel;
    UILabel * _positionLabel;
    UILabel * _latitudlongitudeLabel;
}
@property(nonatomic, strong)  HGBCompassTool *compass;




@end

@implementation HGBCompassViewController


- (void)viewDidLoad {

    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self createNavigationItem];
    [self setupUI];
    [self createCompass];


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
    titleLab.text=@"指南针";
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
#pragma mark view

- (void)setupUI{

    _scaView = [[HGBCompassView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 30, self.view.frame.size.width - 30)];
    _scaView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    _scaView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_scaView];

    _angleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100, _scaView.frame.size.height + _scaView.frame.origin.y, 100, 100)];
    _angleLabel.font = [UIFont systemFontOfSize:30];
    _angleLabel.textAlignment = NSTextAlignmentCenter;
    _angleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_angleLabel];

    _directionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, _angleLabel.frame.origin.y, 50, 50)];
    _directionLabel.font = [UIFont systemFontOfSize:15];
    _directionLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_directionLabel];

    _positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, _angleLabel.frame.origin.y + _directionLabel.frame.size.height, self.view.frame.size.width/2, 70)];
    _positionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _positionLabel.numberOfLines = 3;
    _positionLabel.font = [UIFont systemFontOfSize:15];
    _positionLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_positionLabel];

    _latitudlongitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _positionLabel.frame.origin.y + _positionLabel.frame.size.height, self.view.frame.size.width, 30)];
    _latitudlongitudeLabel.font = [UIFont systemFontOfSize:16];
    _latitudlongitudeLabel.textAlignment = NSTextAlignmentCenter;
    _latitudlongitudeLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_latitudlongitudeLabel];

}

//创建初始化定位装置
- (void)createCompass{
    self.compass.compassView=_scaView;
    self.compass=[HGBCompassTool shareInstance];
    self.compass.angleLabel=_angleLabel;
    self.compass.directionLabel=_directionLabel;
    self.compass.latitudlongitudeLabel=_latitudlongitudeLabel;
    self.compass.positionLabel=_positionLabel;
    [self.compass startLocate];

}
-(void)compass:(HGBCompassTool *)compass didFailedWithError:(NSDictionary *)errorInfo{

    NSString *typeNum=[errorInfo objectForKey:ReslutCode];
    HGBCompassToolErrorType type=(HGBCompassToolErrorType)typeNum.integerValue;
    if(type==HGBCompassToolErrorTypeAuthority){

        [self jumpSet];
    }


}
-(void)jumpSet{
#ifdef __IPHONE_8_0
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"请在iPhone的“设置”-“隐私”-“相机”功能中，找到“某某应用”打开定位权限" preferredStyle:(UIAlertControllerStyleAlert)];
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
    [self presentViewController:alert animated:YES completion:nil];
#else
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在iPhone的“设置”-“隐私”-“相机”功能中，找到“某某应用”打开定位权限" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置",nil];
    [alert show];

#endif
}
#pragma mark --alertdelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

        if([[UIApplication sharedApplication] canOpenURL:url]) {

            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];

        }
    }else{

    }
}
-(void)compass:(HGBCompassTool *)compass didSucessWithHeaderInfo:(NSDictionary *)headerInfo{

}
-(void)compass:(HGBCompassTool *)compass didSucessWithLocationInfo:(NSDictionary *)locationInfo{

}


- (void)dealloc{

    [self.compass stopLocate];//停止获得航向数据，省电

}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

    [self.compass stopLocate];//停止获得航向数据，省电


}

@end
