//
//  HGBDownLoadController.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/3/15.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBDownLoadController.h"

#import "HGBDownLoadHeader.h"

#import "HGBDownLoadTableCell.h"
#define Identify_Cell @"download"


#import "HGBDownLoadTool.h"



@interface HGBDownLoadController ()<UITableViewDelegate,UITableViewDataSource,HGBDownLoadTableCellDelegate>
/**
 表格
 */
@property(strong,nonatomic)UITableView *tableView;
/**
 数据源
 */
@property(strong,nonatomic)NSMutableDictionary *dataDictionary;
/**
 关键字
 */
@property(strong,nonatomic)NSArray *keys;
@end

@implementation HGBDownLoadController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavigationItem];//导航栏
    [self viewSetUp];//UI



}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self monitorDataChange];

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
    titleLab.text=@"下载管理";
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
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0, kWidth, kHeight) style:(UITableViewStylePlain)];
    self.tableView.backgroundColor = [UIColor colorWithRed:220.0/256 green:220.0/256 blue:220.0/256 alpha:1];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];

    [self.tableView registerClass:[HGBDownLoadTableCell class] forCellReuseIdentifier:Identify_Cell];
    [self.tableView reloadData];
}
-(void)monitorDataChange{
    NSArray *tasks=[[HGBDownLoadTool shareInstance]getDownLoadTasks];
    for (HGBDownLoadTask *task in tasks) {
        [self.dataDictionary setObject:task forKey:task.id];
        if(task.status==HGBDownloadStateCancel){
            [[HGBDownLoadTool shareInstance] startDownLoadWithDownLoadTask:task];
        }else if (task.status==HGBDownloadStateUnExpectedCancel){
             [[HGBDownLoadTool shareInstance] startDownLoadWithDownLoadTask:task];
             [[HGBDownLoadTool shareInstance] suspendDownLoadWithDownLoadTask:task];
        }
    }
     self.keys=[self.dataDictionary allKeys];
    [self.tableView reloadData];
    [HGBDownLoadTool shareInstance].resultBlock = ^(BOOL status, HGBDownLoadTask *task, NSDictionary *returnMessage) {
        NSLog(@"%@-%f",task.id,task.progress);
        [self.dataDictionary setObject:task forKey:task.id];
         self.keys=[self.dataDictionary allKeys];
        [self.tableView reloadData];

    };
}
#pragma mark table view delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 72* hScale;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, 72 * hScale)];
    headView.backgroundColor = [UIColor colorWithRed:220.0/256 green:220.0/256 blue:220.0/256 alpha:1];
    //信息提示栏
    UILabel *tipMessageLabel = [[UILabel alloc]initWithFrame:CGRectMake(32 * wScale, 0, kWidth - 32 * wScale, CGRectGetHeight(headView.frame))];
    tipMessageLabel.backgroundColor = [UIColor clearColor];
    tipMessageLabel.text =@"下载管理";
    tipMessageLabel.textColor = [UIColor grayColor];
    tipMessageLabel.textAlignment = NSTextAlignmentLeft;
    tipMessageLabel.font = [UIFont systemFontOfSize:12.0];
    tipMessageLabel.numberOfLines = 0;
    [headView addSubview:tipMessageLabel];
    return headView;

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.keys.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 120*kHeight;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HGBDownLoadTableCell *cell=[tableView dequeueReusableCellWithIdentifier:Identify_Cell forIndexPath:indexPath];
    NSString *taskid=self.keys[indexPath.row];
    HGBDownLoadTask *task=[self.dataDictionary objectForKey:taskid];
    cell.task=task;
    cell.delegate=self;
    if (indexPath.row==0) {
        cell.title.backgroundColor=[UIColor redColor];
    }else{
         cell.title.backgroundColor=[UIColor blueColor];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}
#pragma mark  cell delegate
-(void)downLoadCell:(HGBDownLoadTableCell *)cell didClickDeleteButtonWithTask:(HGBDownLoadTask *)task{
    if (task) {
        [self.dataDictionary removeObjectForKey:task.id];
        [[HGBDownLoadTool shareInstance]deleteDownLoadTaskWithId:task.id];
        [self.tableView reloadData];
    }
}
-(void)downLoadCell:(HGBDownLoadTableCell *)cell didClickDownLoadButtonWithTask:(HGBDownLoadTask *)task{
    if (task.status==HGBDownloadStateRuning) {
        [[HGBDownLoadTool shareInstance] suspendDownLoadWithDownLoadTask:task];
    }else if (task.status==HGBDownloadStateSuspended){
         [[HGBDownLoadTool shareInstance] resumeDownLoadWithDownLoadTask:task];
    }
    [self.dataDictionary setObject:[[HGBDownLoadTool shareInstance]getDownLoadTaskWithId:task.id] forKey:task.id];
    [self.tableView reloadData];
}
#pragma mark get
-(NSMutableDictionary *)dataDictionary{
    if(_dataDictionary==nil){
        _dataDictionary=[NSMutableDictionary dictionary];
    }
    return _dataDictionary;
}
-(NSArray *)keys{
    if(_keys==nil){
        _keys=[NSArray array];
    }
    return _keys;
}

@end
