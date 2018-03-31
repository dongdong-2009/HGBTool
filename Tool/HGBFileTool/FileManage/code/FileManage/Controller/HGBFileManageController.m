//
//  HGBFileManageController.m
//  测试
//
//  Created by huangguangbao on 2017/8/14.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBFileManageController.h"

#import "HGBFileManageHeader.h"



#import "HGBFileTableCell.h"
#import "HGBFileFullCollectionCell.h"
#import "HGBFileSpaceCollectionCell.h"





#import "HGBFileManageTool.h"
#import "HGBFileQuickLookTool.h"
#import "HGBImageLookTool.h"
#import "HGBFileWebLook.h"
#import "HGBFileOutAppOpenFileTool.h"






#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif












#define identify_FileTableCell @"FileTableCellIdentify"


#define identify_FullCollectionCell @"FullCollectionCell"
#define identify_SpaceCollectionCell @"SpaceCollectionCell"



#define identify_footer @"CollectionReusableViewFooter"
#define identify_header @"CollectionReusableViewHeader"



@interface HGBFileManageController ()<UITableViewDelegate,UITableViewDataSource,HGBFileTableCellDelegate,UICollectionViewDelegate,UICollectionViewDataSource,HGBFileFullCollectionCellDelegate,HGBFileSpaceCollectionCellDelegate,UICollectionViewDelegateFlowLayout>//

/**
 顶部view
 */
@property(strong,nonatomic)UIView *headView;
/**
 顶部view
 */
@property(strong,nonatomic)UIView *footerView;

/**
 下一级
 */
@property(strong,nonatomic)UIButton *swithButton;

/**
 刷新
 */
@property(strong,nonatomic)UIButton *refreshButton;

/**
 上一级
 */
@property(strong,nonatomic)UIButton *beforeButton;






/**
 列表
 */
@property(strong,nonatomic)UITableView *tableView;
/**
 表格
 */
@property(strong,nonatomic)UICollectionView *collectionView;
/**
 选择切换界面样式
 */
@property(assign,nonatomic)HGBFileManageStyle switchStyle;






/**
 数据源
 */
@property(strong,nonatomic)NSMutableArray *dataSource;

/**
 工具集合
 */
@property(strong,nonatomic)NSMutableArray *toolsArr;



/**
 文件路径
 */
@property(strong,nonatomic)NSString *currentDirectoryPath;
/**
 黏贴版路径
 */
@property(strong,nonatomic)NSString *dataPastBordPath;
/**
 源文件路径
 */
@property(strong,nonatomic)NSString *sourceDataPath;
/**
 基础
 */
@property(strong,nonatomic)NSString *baseCopyPath;
@end

@implementation HGBFileManageController
#define PastBordPath [[HGBFileManageTool getHomeFilePath] stringByAppendingPathComponent:@"pastBord_huang"]
#pragma mark life
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self delocSet];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self initSet];//初始化设置
    [self createNavigationItem];//导航栏
    [self viewSetUp];//UI
    [self setBasedDirectorySource];//根数据


}
#pragma mark 导航栏
//导航栏
-(void)createNavigationItem
{
    //导航栏
    self.navigationController.navigationBar.barTintColor=[UIColor orangeColor];
    //标题
    UILabel *titleLab=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 136*wScale, 16)];
    titleLab.font=[UIFont boldSystemFontOfSize:16];
    titleLab.text=@"文件管理";
    titleLab.textAlignment=NSTextAlignmentCenter;
    titleLab.textColor=[UIColor whiteColor];
    self.navigationItem.titleView=titleLab;
    //左键
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(returnhandler)];
    [self.navigationItem.leftBarButtonItem setImageInsets:UIEdgeInsetsMake(0, -10, 0, 10)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];

//    if(self.isShowSelect){
//        //左键
//        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消选择" style:UIBarButtonItemStylePlain target:self action:@selector(setButtonHandle:)];
//        [self.navigationItem.rightBarButtonItem setImageInsets:UIEdgeInsetsMake(0, -10, 0, 10)];
//        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
//    }else{
//        self.navigationItem.rightBarButtonItem=nil;
//
//    }





}
//返回
-(void)returnhandler{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(fileManageDidCanced)]){
        [self.delegate fileManageDidCanced];
    }

    UIViewController *rootVC=self.navigationController.childViewControllers[0];
    if([self.parentViewController isKindOfClass:[UINavigationController class]]){
        if(self==rootVC){
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)setButtonHandle:(UIBarButtonItem *)_b{
    for (HGBFileModel *model in  self.dataSource) {
        model.isSelect=NO;
    }
    [self createNavigationItem];
    if([self.collectionView superview]){
        [self.collectionView reloadData];
    }
    if([self.tableView superview]){
        [self.tableView reloadData];
    }

}

#pragma mark data
/**
 设置基础数据源
 */
-(void)setBasedDirectorySource{
    self.baseCopyPath=[self.basePath copy];
    [self updateDataSourceWithDirectoryPath:self.basePath];

}
/**
 根据文件夹路径更新数据源

 @param directoryPath 文件夹路径
 */
-(void)updateDataSourceWithDirectoryPath:(NSString *)directoryPath{

    NSString *path=[HGBFileManageTool urlAnalysisToPath:directoryPath];
    self.dataSource=[NSMutableArray arrayWithArray:[HGBFileManageTool getFileModelsFromDirectoryPath:path]];
    self.currentDirectoryPath=path;
    if([self.currentDirectoryPath isEqualToString:[HGBFileManageTool urlAnalysisToPath:self.basePath]]){
        [self.beforeButton setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
        self.beforeButton.enabled=NO;
    }else{
        [self.beforeButton setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
        self.beforeButton.enabled=YES;
    }
    if([self.tableView superview]){
         [self.tableView reloadData];
    }
    if([self.collectionView superview]){
        [self.collectionView reloadData];
    }

}
#pragma mark 初始化
-(void)initSet{
    [HGBFileManageTool createDirectoryPath:PastBordPath];
}
#pragma mark 销毁
-(void)delocSet{
    [HGBFileManageTool clearStrorageAtFilePath:PastBordPath];
}
#pragma mark view
-(void)viewSetUp{
    self.view.backgroundColor=[UIColor whiteColor];
    //headerview
    self.headView=[[UIView alloc]initWithFrame:CGRectMake(0, 64, kWidth, 42)];
    self.headView.backgroundColor=[UIColor colorWithRed:246.0/256 green:246.0/256 blue:246.0/256 alpha:1];
    [self.view addSubview:self.headView];


    self.beforeButton=[UIButton buttonWithType:(UIButtonTypeSystem)];
    self.beforeButton.frame=CGRectMake(10,6,(kWidth-40)/3, 30);
    self.beforeButton.layer.masksToBounds=YES;
    self.beforeButton.layer.cornerRadius=10;
    [self.beforeButton setTitle:@"上一级" forState:(UIControlStateNormal)];
    [self.beforeButton setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    self.beforeButton.backgroundColor=[UIColor whiteColor];
    [self.beforeButton addTarget:self action:@selector(beforeButtonHandle:) forControlEvents:(UIControlEventTouchUpInside)];
    if([self.currentDirectoryPath isEqualToString:[HGBFileManageTool urlAnalysisToPath:self.basePath]]){
        [self.beforeButton setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
        self.beforeButton.enabled=NO;
    }else{
        [self.beforeButton setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
        self.beforeButton.enabled=YES;
    }
    [self.headView addSubview:self.beforeButton];


    self.refreshButton=[UIButton buttonWithType:(UIButtonTypeSystem)];
    self.refreshButton.frame=CGRectMake(20+(kWidth-30)/3,6,(kWidth-30)*0.333333, 30);
    self.refreshButton.layer.masksToBounds=YES;
    self.refreshButton.layer.cornerRadius=10;
    [self.refreshButton setTitle:@"刷新" forState:(UIControlStateNormal)];
    [self.refreshButton setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    self.refreshButton.backgroundColor=[UIColor whiteColor];
    [self.refreshButton addTarget:self action:@selector(refreshButtonHandle:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.headView addSubview:self.refreshButton];



    self.swithButton=[UIButton buttonWithType:(UIButtonTypeSystem)];
    self.swithButton.frame=CGRectMake(30+(kWidth-30)*2/3,6,(kWidth-30)/3, 30);
    self.swithButton.layer.masksToBounds=YES;
    self.swithButton.layer.cornerRadius=10;
    if(_style==HGBFileManageStyleSwitch){
        [self.headView addSubview:self.swithButton];
    }
     [self.swithButton setTitle:@"间隙表格" forState:(UIControlStateNormal)];
    [self.swithButton setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    self.swithButton.backgroundColor=[UIColor whiteColor];
    [self.swithButton addTarget:self action:@selector(swithButtonHandle:) forControlEvents:(UIControlEventTouchUpInside)];
    [self createTable];

}
-(void)createTable{
    if(self.switchStyle==HGBFileManageStyleTable){
        if([self.collectionView superview]){
            [self.collectionView removeFromSuperview];
        }
        if([self.tableView superview]){
            return;
        }
        //tableview
        self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,106, kWidth, kHeight-106) style:(UITableViewStylePlain)];

        self.tableView.alpha=1;
        self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        self.tableView.separatorColor=[UIColor clearColor];
        self.tableView.backgroundColor=[UIColor whiteColor];
        self.tableView.delegate=self;
        self.tableView.dataSource=self;
        [self.view addSubview:self.tableView];

        [self.tableView registerClass:[HGBFileTableCell class] forCellReuseIdentifier:identify_FileTableCell];

        UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressHandler:)];
        //要求点击保持最短时间
        longPress.minimumPressDuration=1;
        [self.tableView addGestureRecognizer:longPress];

    }else if (self.switchStyle==HGBFileManageStyleSpaceCollection||self.switchStyle==HGBFileManageStyleFullCollection){

        if([self.tableView superview]){
            [self.tableView removeFromSuperview];
        }

        CGFloat itemHeight=self.view.frame.size.width*0.25;
        CGFloat itemWidth=self.view.frame.size.width*0.25;
        if(self.switchStyle==HGBFileManageStyleSpaceCollection){
            itemHeight=self.view.frame.size.width*0.3;
            itemWidth=self.view.frame.size.width*0.25;
        }else if (self.switchStyle==HGBFileManageStyleFullCollection){
            itemHeight=self.view.frame.size.width*0.25;
            itemWidth=self.view.frame.size.width*0.25;
        }

        //创建流式布局
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];

        //指定每一个cell的大小
        flowLayout.itemSize=CGSizeMake(itemWidth, itemHeight);

        flowLayout.minimumInteritemSpacing=0;
        flowLayout.minimumLineSpacing=1;
        //设置滑动方向
        //         flowLayout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
        //指定边距
        flowLayout.sectionInset=UIEdgeInsetsMake(0, 0,0, 0);
        //创建集合视图



        self.collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0,106, kWidth, kHeight-106) collectionViewLayout:flowLayout];

        self.collectionView.backgroundColor=[UIColor whiteColor];

        self.collectionView.delegate=self;
        self.collectionView.dataSource=self;

        //    self.collectionView.
        [self.view addSubview:self.collectionView];
        [self.collectionView registerClass:[HGBFileFullCollectionCell class] forCellWithReuseIdentifier:identify_FullCollectionCell];
        [self.collectionView registerClass:[HGBFileSpaceCollectionCell class] forCellWithReuseIdentifier:identify_SpaceCollectionCell];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:identify_header];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:identify_footer];
        //        self.collectionView.allowsMultipleSelection=YES;
    }
}
#pragma mark action
/**
 长按

 @param _p 长按
 */
-(void)longPressHandler:(UILongPressGestureRecognizer *)_p{
    [self alertToolSelectViewWithIndexPath:nil];
}
/**
 上一级

 @param _b 按钮
 */
-(void)beforeButtonHandle:(UIButton *)_b{
    NSString *path=[self.currentDirectoryPath stringByDeletingLastPathComponent];
    if([self.currentDirectoryPath isEqualToString:[HGBFileManageTool urlAnalysisToPath:self.basePath]]){
        path=self.currentDirectoryPath;
    }
    [self updateDataSourceWithDirectoryPath:path];
}
/**
 下一级

 @param _b 按钮
 */
-(void)swithButtonHandle:(UIButton *)_b{

    if([_b.titleLabel.text isEqualToString:@"列表"]){
         [self.swithButton setTitle:@"间隙表格" forState:(UIControlStateNormal)];
        self.switchStyle=_switchStyle=HGBFileManageStyleTable;;
    }else if([_b.titleLabel.text isEqualToString:@"间隙表格"]){
        [self.swithButton setTitle:@"饱满表格" forState:(UIControlStateNormal)];
        self.switchStyle=HGBFileManageStyleSpaceCollection;
    }else if([_b.titleLabel.text isEqualToString:@"饱满表格"]){
       self.switchStyle=HGBFileManageStyleFullCollection;
        [self.swithButton setTitle:@"列表" forState:(UIControlStateNormal)];
    }
    [self createTable];
}
/**
 刷新

 @param _b 按钮
 */
-(void)refreshButtonHandle:(UIButton *)_b{
    [self updateDataSourceWithDirectoryPath:self.currentDirectoryPath];
}

#pragma mark tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120*hScale;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     HGBFileTableCell *cell=[tableView dequeueReusableCellWithIdentifier:identify_FileTableCell forIndexPath:indexPath];
    cell.delegate=self;
    cell.indexPath=indexPath;
     HGBFileModel *fileModel=self.dataSource[indexPath.row];
    UIImage *iconImage=[UIImage imageNamed:fileModel.fileIcon];
    if(iconImage){
        cell.iconImageView.image=iconImage;
    }else{
        cell.iconImageView.image=[UIImage imageNamed:@"HGBFileManageToolBundle.bundle/undefine.png"];
    }
    
    cell.imageView.backgroundColor=[UIColor redColor];

    if(fileModel.fileType==HGBFileTypeDirectory){
        cell.tapImageView.hidden=NO;
    }else{
        cell.tapImageView.hidden=YES;
    }
    if(fileModel.fileName){
        cell.fileNameLabel.text=fileModel.fileName;
    }
    if(fileModel.fileAbout){
        cell.fileInfoLable.text=fileModel.fileAbout;
    }
    return cell;


}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self clickFileAtIndexPath:indexPath];


}
-(void)fileTableCell:(HGBFileTableCell *)cell didClickImageWithIndexPath:(NSIndexPath *)indexPath{
    [self clickFileAtIndexPath:indexPath];
}
-(void)fileTableCell:(HGBFileTableCell *)cell didLongPressImageWithIndexPath:(NSIndexPath *)indexPath{

    [self alertToolSelectViewWithIndexPath:indexPath];
}
#pragma mark collectiondelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
     return self.dataSource.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

     HGBFileModel *fileModel=self.dataSource[indexPath.row];
    if(self.switchStyle==HGBFileManageStyleSpaceCollection){
        HGBFileSpaceCollectionCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identify_SpaceCollectionCell forIndexPath:indexPath];
        cell.delegate=self;

        cell.indexPath=indexPath;

        if(fileModel.fileType==HGBFileTypeImage){
            cell.imageView.image=[UIImage imageWithContentsOfFile:[HGBFileManageTool urlAnalysisToPath:fileModel.filePath]];
        }else{
            UIImage *iconImage=[UIImage imageNamed:fileModel.fileIcon];
            if(iconImage){
                cell.imageView.image=iconImage;
            }else{
                cell.imageView.image=[UIImage imageNamed:@"HGBFileManageToolBundle.bundle/undefine.png"];
            }

        }

        if(fileModel.fileName){
            cell.titleLabel.text=fileModel.fileName;
        }

        return cell;
    }else if (self.switchStyle==HGBFileManageStyleFullCollection){
        HGBFileFullCollectionCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identify_FullCollectionCell forIndexPath:indexPath];


        cell.delegate=self;
        cell.indexPath=indexPath;


        if(fileModel.fileType==HGBFileTypeImage){
            cell.imageView.image=[UIImage imageWithContentsOfFile:[HGBFileManageTool urlAnalysisToPath:fileModel.filePath]];
        }else{
            UIImage *iconImage=[UIImage imageNamed:fileModel.fileIcon];
            if(iconImage){
                cell.imageView.image=iconImage;
            }else{
                cell.imageView.image=[UIImage imageNamed:@"HGBFileManageToolBundle.bundle/undefine.png"];
            }

        }

        if(fileModel.fileName){
            cell.titleLabel.text=fileModel.fileName;
        }
        return cell;
    }
    return nil;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self clickFileAtIndexPath:indexPath];
}
-(void)fileSpaceCollectionCell:(HGBFileSpaceCollectionCell *)cell didClickImageWithIndexPath:(NSIndexPath *)indexPath{
     [self clickFileAtIndexPath:indexPath];

}
-(void)fileSpaceCollectionCell:(HGBFileSpaceCollectionCell *)cell didLongPressImageWithIndexPath:(NSIndexPath *)indexPath{
     [self alertToolSelectViewWithIndexPath:indexPath];
}
-(void)fileFullCollectionCell:(HGBFileFullCollectionCell *)cell didClickImageWithIndexPath:(NSIndexPath *)indexPath{
  [self clickFileAtIndexPath:indexPath];

}
-(void)fileFullCollectionCell:(HGBFileFullCollectionCell *)cell didLongPressImageWithIndexPath:(NSIndexPath *)indexPath{
   [self alertToolSelectViewWithIndexPath:indexPath];

}
#pragma mark 功能
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

}

/**
 点击事件

 @param indexPath 地址
 */
-(void)clickFileAtIndexPath:(NSIndexPath *)indexPath{
     HGBFileModel *fileModel=self.dataSource[indexPath.row];
    if(self.clickStyle==HGBFileManageClickStyleOpen||fileModel.fileType==HGBFileTypeDirectory||fileModel.fileType==HGBFileTypeBundle){
        [self openFileAtIndexPath:indexPath];
    }else if (self.clickStyle==HGBFileManageClickStyleSelect){

        NSString *path=[HGBFileManageTool urlAnalysisToPath:fileModel.filePath];
        if(self.delegate&&[self.delegate respondsToSelector:@selector(fileManageDidReturnFilePath:)]){
            [self.delegate fileManageDidReturnFilePath:path];
        }
        if(self.delegate&&[self.delegate respondsToSelector:@selector(fileManageDidReturnFileUrl:)]){
            [self.delegate fileManageDidReturnFileUrl:[HGBFileManageTool urlEncapsulation:path]];
        }
        [self returnhandler];
    }
}
/**
 打开文件

 @param indexPath 文件位置
 */
-(void)openFileAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row>=self.dataSource.count){
        return;
    }
    HGBFileModel *fileModel=self.dataSource[indexPath.row];

    NSString *path=[HGBFileManageTool urlAnalysisToPath:fileModel.filePath];
    if(fileModel.fileType==HGBFileTypeDirectory||fileModel.fileType==HGBFileTypeBundle){
        [self updateDataSourceWithDirectoryPath:path];

    }else if(fileModel.fileType==HGBFileTypeImage){
        [[HGBImageLookTool shareInstance] lookFileAtSource:path inParent:self];

    }else{

       [[HGBFileQuickLookTool shareInstance] lookFileAtSource:path inParent:self];
    }
}
#pragma mark 工具栏
-(void)alertToolSelectViewWithIndexPath:(NSIndexPath *)indexPath{
    static BOOL isShow=NO;
    HGBFileModel *fileModel;
    NSString *path;
    if(indexPath){
         fileModel=self.dataSource[indexPath.row];
          path=[HGBFileManageTool urlAnalysisToPath:fileModel.filePath];
        if(fileModel.fileType==HGBFileTypeDirectory||fileModel.fileType==HGBFileTypeBundle){
             self.toolsArr=[NSMutableArray arrayWithArray:@[@{@"id":@"0",@"title":@"打开"},@{@"id":@"98",@"title":@"选择"}]];

        }else{
             self.toolsArr=[NSMutableArray arrayWithArray:@[@{@"id":@"0",@"title":@"打开"},@{@"id":@"98",@"title":@"选择"},@{@"id":@"3",@"title":@"使用浏览器打开"},@{@"id":@"4",@"title":@"其他方式打开"}]];
        }

        if(fileModel.isEdit){
            [self.toolsArr addObject: @{@"id":@"5",@"title":@"重命名"}];
            [self.toolsArr addObject:@{@"id":@"6",@"title":@"复制"}];
            [self.toolsArr addObject:@{@"id":@"7",@"title":@"剪切"}];
            [self.toolsArr addObject:@{@"id":@"8",@"title":@"删除"}];
        }
        if(self.dataPastBordPath){
            [self.toolsArr addObject:@{@"id":@"9",@"title":@"粘贴"}];
        }

         [self.toolsArr addObject:@{@"id":@"99",@"title":@"取消"}];

    }else{
        self.toolsArr=[NSMutableArray array];
         self.toolsArr=[NSMutableArray arrayWithArray:@[@{@"id":@"1",@"title":@"新建文件夹"},@{@"id":@"2",@"title":@"新建文件"}]];
        if(self.dataPastBordPath){
            [self.toolsArr addObject:@{@"id":@"9",@"title":@"粘贴"}];
        }
         [self.toolsArr addObject:@{@"id":@"99",@"title":@"取消"}];
    }

    UIAlertController *alert=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    for(NSDictionary *dic in self.toolsArr){
        UIAlertAction *action=[UIAlertAction actionWithTitle:dic[@"title"] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            NSString *idString=dic[@"id"];
            if (idString.integerValue==0) {
                [self openFileAtIndexPath:indexPath];
            }else if(idString.integerValue==1){
                __block UITextField *inputText;
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"创建文件夹" message:@"请输入文件夹名称" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    inputText=textField;
                }];

                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    NSString *directoryName=[inputText text];
                    if(directoryName==nil||directoryName.length==0){
                        [self alertWithPrompt:@"文件夹名不能为空"];
                        return ;
                    }
                    NSString *directoryPath=[self.currentDirectoryPath stringByAppendingPathComponent:directoryName];
                    [HGBFileManageTool createDirectoryPath:directoryPath];
                    [self updateDataSourceWithDirectoryPath:self.currentDirectoryPath];


                }];

                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

                }];
                
                [alertController addAction:cancelAction];
                [alertController addAction:confirmAction];
                [self presentViewController:alertController animated:YES completion:nil];

            }else if(idString.integerValue==2){
                __block UITextField *inputText;
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"创建文件" message:@"请输入文件名称" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    inputText=textField;
                }];

                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    NSString *fileName=[inputText text];
                    if(fileName==nil||fileName.length==0){
                        [self alertWithPrompt:@"文件名不能为空"];
                        return ;
                    }
                    NSString *filePath=[self.currentDirectoryPath stringByAppendingPathComponent:fileName];
                    [HGBFileManageTool createFileAtPath:filePath];
                    [self updateDataSourceWithDirectoryPath:self.currentDirectoryPath];


                }];

                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

                }];

                [alertController addAction:cancelAction];
                [alertController addAction:confirmAction];
                [self presentViewController:alertController animated:YES completion:nil];

            }else if(idString.integerValue==3){
                [[HGBFileWebLook shareInstance] lookFileAtSource:path inParent:self];

            }else if(idString.integerValue==4){
                 [[HGBFileOutAppOpenFileTool shareInstance] lookFileAtSource:path inParent:self];
            }else if(idString.integerValue==5){
                __block UITextField *inputText;
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"文件重命名" message:@"请输入文件新名称" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    inputText=textField;
                }];

                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"重命名" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    NSString *fileName=[inputText text];
                    if(fileName==nil||fileName.length==0){
                        [self alertWithPrompt:@"文件名不能为空"];
                        return ;
                    }
                    NSString *curentPath=path;
                    NSString *filePath=[[curentPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileName];
                    [HGBFileManageTool copyFilePath:curentPath ToPath:filePath];
                    [HGBFileManageTool removeFilePath:curentPath];
                    [self updateDataSourceWithDirectoryPath:self.currentDirectoryPath];
                }];

                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

                }];

                [alertController addAction:cancelAction];
                [alertController addAction:confirmAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }else if(idString.integerValue==6){
                self.sourceDataPath=path;
                self.dataPastBordPath=[PastBordPath stringByAppendingPathComponent:[self.sourceDataPath lastPathComponent]];
               [HGBFileManageTool copyFilePath:self.sourceDataPath ToPath:self.dataPastBordPath];

                self.sourceDataPath=nil;


            }else if(idString.integerValue==7){
                self.sourceDataPath=path;
                self.dataPastBordPath=[PastBordPath stringByAppendingPathComponent:[self.sourceDataPath lastPathComponent]];
                BOOL flag=[HGBFileManageTool copyFilePath:self.sourceDataPath ToPath:self.dataPastBordPath];
                if(flag==NO){
                    self.dataPastBordPath=nil;
                }
            }else if(idString.integerValue==8){

                [HGBFileManageTool removeFilePath:path];
                [self updateDataSourceWithDirectoryPath:self.currentDirectoryPath];

            }else if(idString.integerValue==9){
                NSString *filePath=[self.currentDirectoryPath stringByAppendingPathComponent:[self.dataPastBordPath lastPathComponent]];
                int i=0;
                NSString *fileCopyPath=[filePath copy];
                while([HGBFileManageTool isExitAtFilePath:fileCopyPath]){
                fileCopyPath=[filePath stringByAppendingString:[NSString stringWithFormat:@"%d",i]];
                    i++;
                }
                [HGBFileManageTool copyFilePath:self.dataPastBordPath ToPath:filePath];
                if(self.sourceDataPath){
                    [HGBFileManageTool removeFilePath:self.sourceDataPath];
                    self.sourceDataPath=nil;
                }
                [self updateDataSourceWithDirectoryPath:self.currentDirectoryPath];

            }else if(idString.integerValue==98){
                if(self.delegate&&[self.delegate respondsToSelector:@selector(fileManageDidReturnFilePath:)]){
                    [self.delegate fileManageDidReturnFilePath:path];
                }
                if(self.delegate&&[self.delegate respondsToSelector:@selector(fileManageDidReturnFileUrl:)]){
                    [self.delegate fileManageDidReturnFileUrl:[HGBFileManageTool urlEncapsulation:path]];
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            isShow=NO;


        }];
        [alert addAction:action];
    }
    if(isShow==NO){
        [[self currentViewController] presentViewController:alert animated:YES completion:nil];
        isShow=YES;
    }
}
#pragma mark 提示
/**
 展示内容

 @param prompt 提示
 */
-(void)alertWithPrompt:(NSString *)prompt{
#ifdef __IPHONE_8_0
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action=[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
#else
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:prompt delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertview show];
#endif
}
#pragma mark 获取当前控制器

/**
 获取当前控制器

 @return 当前控制器
 */
-(UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self findBestViewController:viewController];
}

/**
 寻找上层控制器

 @param vc 控制器
 @return 上层控制器
 */
- (UIViewController *)findBestViewController:(UIViewController *)vc
{
    if (vc.presentedViewController) {
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [self findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [self findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [self findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        return vc;
    }
}
#pragma mark set
-(void)setStyle:(HGBFileManageStyle)style{
    _style=style;
    if(_style==HGBFileManageStyleSwitch){
        _switchStyle=HGBFileManageStyleTable;
        if(![self.swithButton superview]){
            [self.headView addSubview:self.swithButton];
        }
    }else{
        _switchStyle=_style;
        if([self.swithButton superview]){
            [self.swithButton removeFromSuperview];
        }
    }
}
#pragma mark get
-(NSString *)basePath{
    if(_basePath==nil){
        _basePath=[HGBFileManageTool getHomeFilePath];
    }
    return _basePath;
}
-(NSMutableArray *)toolsArr{
    if(_toolsArr==nil){
        _toolsArr=[NSMutableArray array];
    }
    return _toolsArr;
}
@end
