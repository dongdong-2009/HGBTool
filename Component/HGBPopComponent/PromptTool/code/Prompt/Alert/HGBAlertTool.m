//
//  HGBAlertTool.m
//  测试
//
//  Created by huangguangbao on 2017/8/9.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBAlertTool.h"


@interface HGBAlertTool()<UIAlertViewDelegate,UIActionSheetDelegate>
@property(strong,nonatomic)HGBAlertClickBlock clickBlock;

@end

@implementation HGBAlertTool
#pragma mark init
static HGBAlertTool *instance=nil;
+ (instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBAlertTool alloc]init];
    }
    return instance;
}
#pragma mark 设置
/**
 配置标题颜色

 @param titleColor 标题颜色
 */
-(void)setTitleColor:(UIColor *)titleColor{
    _titleColor=titleColor;
}
/**
 配置标题字体大小

 @param titleFontSize 标题字体大小
 */
-(void)setTitleFontSize:(CGFloat)titleFontSize{

    _titleFontSize=titleFontSize;

    if(titleFontSize!=0){
        _titleFontFlag=YES;
    }else{
        _titleFontFlag=NO;
    }
}

/**
 配置副标题颜色

 @param subTitleColor 副标题颜色
 */
-(void)setSubTitleColor:(UIColor *)subTitleColor{

    _subTitleColor=subTitleColor;
    
    

}
/**
 配置副标题字体大小

 @param subTitleFontSize 副标题字体大小
 */
-(void)setSubTitleFontSize:(CGFloat)subTitleFontSize{

    _subTitleFontSize=subTitleFontSize;
    if(subTitleFontSize!=0){
        _subTitleFontFlag=YES;
    }else{
        _subTitleFontFlag=NO;
    }
}
/**
 配置按钮标题颜色

 @param buttonTitleColor 按钮标题颜色
 */
-(void)setButtonTitleColor:(UIColor *)buttonTitleColor{
    _buttonTitleColor=buttonTitleColor;
}
/**
 配置按钮标题字体大小

 @param buttonTitleFontSize 按钮标题字体大小
 */
-(void)setButtonTitleFontSize:(CGFloat)buttonTitleFontSize{
    _buttonTitleFontSize=buttonTitleFontSize;
    if(buttonTitleFontSize!=0){
        _buttonTitleFontFlag=YES;
    }else{
        _buttonTitleFontFlag=NO;
    }
}
#pragma mark 统一配置

/**
 alertController统一配置

 @param alertController alertController
 */
-(void)setAlertControllerSettings:(UIAlertController *)alertController{
    if(!alertController){
        return;
    }
    if(self.titleColor||self.titleFontFlag){
        //改变title的大小和颜色
        NSMutableAttributedString *titleAtt = [[NSMutableAttributedString alloc] initWithString:alertController.title];

        if(self.titleFontFlag){
            [titleAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:self.titleFontSize] range:NSMakeRange(0,alertController.title.length)];
        }
        if(self.titleColor){
            [titleAtt addAttribute:NSForegroundColorAttributeName value:self.titleColor range:NSMakeRange(0, alertController.title.length)];

        }
        [alertController setValue:titleAtt forKey:@"attributedTitle"];
    }
    if(self.subTitleFontFlag||self.subTitleColor){
        NSMutableAttributedString *messageAtt = [[NSMutableAttributedString alloc] initWithString:alertController.message];
        //改变message的大小和颜色
        if(self.subTitleFontFlag){
            [messageAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:self.subTitleFontSize] range:NSMakeRange(0,alertController.message.length)];
        }
        if(self.subTitleColor){
            [messageAtt addAttribute:NSForegroundColorAttributeName value:self.subTitleColor range:NSMakeRange(0, alertController.message.length)];
        }
        [alertController setValue:messageAtt forKey:@"attributedMessage"];

    }
    if(self.buttonTitleColor){
        alertController.view.tintColor=self.buttonTitleColor;
    }

}
/**
 alertView统一配置

 @param alertView alertView
 */
-(void)setAlertViewSettings:(UIAlertView *)alertView{

    if(!alertView){
        return;
    }
    if(self.titleColor||self.titleFontFlag){
        //改变title的大小和颜色
        NSMutableAttributedString *titleAtt = [[NSMutableAttributedString alloc] initWithString:alertView.title];
        UILabel *titleLabel = [alertView valueForKey:@"_titleLabel"];


        if(self.titleFontFlag){
            titleLabel.font = [UIFont fontWithName:@"Arial" size:self.titleFontSize];
            [titleAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:self.titleFontSize] range:NSMakeRange(0,alertView.title.length)];
        }
        if(self.titleColor){
            [titleAtt addAttribute:NSForegroundColorAttributeName value:self.titleColor range:NSMakeRange(0, alertView.title.length)];
            [titleLabel setTextColor:self.titleColor];

        }
        @try {
            [alertView setValue:titleAtt forKey:@"attributedTitle"];
        } @catch (NSException *exception) {

        } @finally {
        }



    }
    if(self.subTitleFontFlag||self.subTitleColor){
        NSMutableAttributedString *messageAtt = [[NSMutableAttributedString alloc] initWithString:alertView.message];
        UILabel *body = [alertView valueForKey:@"_bodyTextLabel"];

        //改变message的大小和颜色
        if(self.subTitleFontFlag){
            body.font = [UIFont fontWithName:@"Arial" size:self.subTitleFontSize];

            [messageAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:self.subTitleFontSize] range:NSMakeRange(0,alertView.message.length)];
        }
        if(self.subTitleColor){
            [messageAtt addAttribute:NSForegroundColorAttributeName value:self.subTitleColor range:NSMakeRange(0, alertView.message.length)];
            [body setTextColor:self.subTitleColor];
        }
        @try {
           [alertView setValue:messageAtt forKey:@"attributedMessage"];
        } @catch (NSException *exception) {

        } @finally {
        }


    }




    if(self.buttonTitleColor){
        [[UIView appearanceWhenContainedIn:[UIAlertView class], nil] setTintColor:[UIColor redColor]];
    }

}
/**
 actionSheet统一配置

 @param actionSheet actionSheet
 */
-(void)setActionSheetSettings:(UIActionSheet *)actionSheet{
    if(!actionSheet){
        return;
    }
    if(self.titleColor||self.titleFontFlag){
        //改变title的大小和颜色
        NSMutableAttributedString *titleAtt = [[NSMutableAttributedString alloc] initWithString:actionSheet.title];
        UILabel *titleLabel = [actionSheet valueForKey:@"_titleLabel"];
       
        if(self.titleFontFlag){
            [titleAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:self.titleFontSize] range:NSMakeRange(0,actionSheet.title.length)];
            titleLabel.font = [UIFont fontWithName:@"Arial" size:self.titleFontSize];

        }
        if(self.titleColor){
            [titleAtt addAttribute:NSForegroundColorAttributeName value:self.titleColor range:NSMakeRange(0, actionSheet.title.length)];
            [titleLabel setTextColor:self.titleColor];

        }
        @try {
            [actionSheet setValue:titleAtt forKey:@"attributedTitle"];
        } @catch (NSException *exception) {

        } @finally {
        }
    }
    if(self.buttonTitleColor){
        actionSheet.tintColor=self.buttonTitleColor;
    }

}
#pragma mark alert单键
/**
 *  单键-提示
 *
 *  @param prompt     提示详情
 *
 *  @param parent 父控件
 */

-(void)alertWithPrompt:(NSString *)prompt InParent:(UIViewController *)parent{
#ifdef __IPHONE_8_0
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"温馨提示" message:prompt preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action=[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action];
    [self setAlertControllerSettings:alert];
    [parent presentViewController:alert animated:YES completion:nil];
#else
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:prompt delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [self setAlertViewSettings:alertview];
    [alertview show];

#endif
}


/**
 *  单键－带标题提示
 *
 *  @param title    提示标题
 *  @param prompt     提示详情
 *
 *  @param parent 父控件
 */
-(void)alertPromptWithTitle:(NSString *)title andWithPrompt:(NSString *)prompt  InParent:(UIViewController *)parent
{
#ifdef __IPHONE_8_0
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:prompt preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {

        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:action1];
    [self setAlertControllerSettings:alert];
    [parent presentViewController:alert animated:YES completion:nil];

#else
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title message:prompt delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [self setAlertViewSettings:alertview];
    [alertview show];
#endif
}
/**
 *  单键－带标题提示-点击事件
 *
 *  @param title    提示标题
 *  @param prompt     提示详情
 *
 *  @param clickBlock 点击事件
 *  @param parent 父控件
 */
-(void)alertWithTitle:(NSString *)title andWithPrompt:(NSString *)prompt andWithClickBlock:(HGBAlertClickBlock)clickBlock InParent:(UIViewController *)parent
{
#ifdef __IPHONE_8_0
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:prompt preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        clickBlock(0);
    }];
    [alert addAction:action1];
    [self setAlertControllerSettings:alert];
    [parent presentViewController:alert animated:YES completion:nil];

#else
    self.clickBlock=clickBlock;
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title message:prompt delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [self setAlertViewSettings:alertview];
    [alertview show];

#endif




}
/**
 *  单键-带标题提示-点击按钮功能及标题
 *
 *  @param title    提示标题
 *  @param prompt     提示详情
 *  @param confirmButtonTitle  按钮标题
 *  @param clickBlock 点击事件
 *  @param parent 父控件
 */
-(void)alertWithTitle:(NSString *)title andWithPrompt:(NSString *)prompt  andWithConfirmButtonTitle:(NSString *)confirmButtonTitle andWithClickBlock:(HGBAlertClickBlock)clickBlock InParent:(UIViewController *)parent{
    if(confirmButtonTitle==nil&&confirmButtonTitle.length==0){
        confirmButtonTitle=@"确定";
    }
#ifdef __IPHONE_8_0
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:prompt preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:confirmButtonTitle style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        clickBlock(0);
    }];
    [alert addAction:action1];
    [self setAlertControllerSettings:alert];
    [parent presentViewController:alert animated:YES completion:nil];
#else
    self.clickBlock=clickBlock;
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title message:prompt delegate:self cancelButtonTitle:confirmButtonTitle otherButtonTitles:nil];
    [self setAlertViewSettings:alertview];
    [alertview show];

#endif
}
#pragma mark alert双键
/**
 *  双键-功能－标题提示
 *
 *  @param title    提示标题
 *  @param prompt     提示详情
 *  @param confirmButtonTitle  确认按钮名称
 *  @param cancelButtonTitle   取消按钮名称
 *
 *  @param clickBlock 点击事件
 *  @param parent 父控件
 */
-(void)alertWithTitle:(NSString *)title andWithPrompt:(NSString *)prompt andWithConfirmButtonTitle:(NSString *)confirmButtonTitle andWithCancelButtonTitle:(NSString *)cancelButtonTitle  andWithClickBlock:(HGBAlertClickBlock)clickBlock InParent:(UIViewController *)parent
{
    if(confirmButtonTitle==nil&&confirmButtonTitle.length==0){
        confirmButtonTitle=@"确定";
    }
    if(cancelButtonTitle==nil&&cancelButtonTitle.length==0){
         cancelButtonTitle=@"取消";
    }
#ifdef __IPHONE_8_0
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:prompt preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:confirmButtonTitle style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        clickBlock(0);
    }];
    [alert addAction:action1];
    UIAlertAction *action2=[UIAlertAction actionWithTitle:cancelButtonTitle style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        clickBlock(1);
    }];
    [alert addAction:action2];
    [self setAlertControllerSettings:alert];
    [parent presentViewController:alert animated:YES completion:nil];
#else

    self.clickBlock =clickBlock;
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title message:prompt delegate:self cancelButtonTitle:confirmButtonTitle otherButtonTitles:cancelButtonTitle,nil];
    [self setAlertViewSettings:alertview];
    [alertview show];

#endif

}
#pragma mark alert多键
/**
 *   多键-功能－标题提示
 *
 *  @param title    提示标题
 *  @param prompt     提示详情
 *  @param buttonTitles  按钮名称集合
 *
 *  @param clickBlock 点击事件
 *  @param parent 父控件
 */
-(void)alertWithTitle:(NSString *)title andWithPrompt:(NSString *)prompt andWithButtonTitles:(NSArray<NSString *>*)buttonTitles andWithClickBlock:(HGBAlertClickBlock)clickBlock InParent:(UIViewController *)parent{
    if(buttonTitles==nil&&buttonTitles.count==0){
        buttonTitles=@[@"确定"];
    }


#ifdef __IPHONE_8_0
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:prompt preferredStyle:(UIAlertControllerStyleAlert)];

    for(int i=0;i<buttonTitles.count;i++){
        NSString *buttonTitle=buttonTitles[i];
        UIAlertAction *action=[UIAlertAction actionWithTitle:buttonTitle style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            clickBlock(i);
        }];
        [alert addAction:action];
    }
    [self setAlertControllerSettings:alert];
    [parent presentViewController:alert animated:YES completion:nil];
#else

    self.clickBlock =clickBlock;
    NSMutableArray *btnTitles=[NSMutableArray array];
    if(buttonTitles.count>1){
        btnTitles=[NSMutableArray arrayWithArray:buttonTitles];
        [btnTitles removeObjectAtIndex:0];
    }
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title message:prompt delegate:self cancelButtonTitle:buttonTitles[0] otherButtonTitles:nil];
    [btnTitles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [alertview addButtonWithTitle:obj];
    }];
    [self setAlertViewSettings:alertview];
    [alertview show];

#endif
}
#pragma mark sheet
/**
 *  sheet-功能
 *
 *  @param buttonTitles  按钮名称集合
 *
 *  @param clickBlock 点击事件
 *  @param parent 父控件
 */
-(void)sheetWithButtonTitles:(NSArray<NSString *>*)buttonTitles andWithClickBlock:(HGBAlertClickBlock)clickBlock InParent:(UIViewController *)parent{
    if(buttonTitles==nil&&buttonTitles.count==0){
        buttonTitles=@[@"取消"];
    }


#ifdef __IPHONE_8_0
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];

    for(int i=0;i<buttonTitles.count;i++){
        NSString *buttonTitle=buttonTitles[i];
        UIAlertAction *action=[UIAlertAction actionWithTitle:buttonTitle style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            clickBlock(i);
        }];
        [alert addAction:action];
    }
    [self setAlertControllerSettings:alert];
    [parent presentViewController:alert animated:YES completion:nil];
#else
    self.clickBlock =clickBlock;
    NSMutableArray *btnTitles=[NSMutableArray array];
    if(buttonTitles.count>1){
        btnTitles=[NSMutableArray arrayWithArray:buttonTitles];
        [btnTitles removeObjectAtIndex:0];
    }

    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:buttonTitles[0] destructiveButtonTitle:nil otherButtonTitles:nil];
    [btnTitles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [actionSheet addButtonWithTitle:obj];
    }];
    [self setActionSheetSettings:actionSheet];
    [actionSheet showInView:parent.view];

#endif
}
/**
 *  sheet-功能－标题提示
 *
 *  @param title    提示标题
 *  @param prompt     提示详情
 *  @param buttonTitles  按钮名称集合
 *
 *  @param clickBlock 点击事件
 *  @param parent 父控件
 */
-(void)sheetWithTitle:(NSString *)title andWithPrompt:(NSString *)prompt andWithButtonTitles:(NSArray<NSString *>*)buttonTitles andWithClickBlock:(HGBAlertClickBlock)clickBlock InParent:(UIViewController *)parent{
    if(buttonTitles==nil&&buttonTitles.count==0){
        buttonTitles=@[@"取消"];
    }


#ifdef __IPHONE_8_0
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:prompt preferredStyle:(UIAlertControllerStyleActionSheet)];

    for(int i=0;i<buttonTitles.count;i++){
        NSString *buttonTitle=buttonTitles[i];
        UIAlertAction *action=[UIAlertAction actionWithTitle:buttonTitle style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            clickBlock(i);
        }];
        [alert addAction:action];
    }
    [self setAlertControllerSettings:alert];
    [parent presentViewController:alert animated:YES completion:nil];
#else

    self.clickBlock =clickBlock;
    NSMutableArray *btnTitles=[NSMutableArray array];
    if(buttonTitles.count>1){
        btnTitles=[NSMutableArray arrayWithArray:buttonTitles];
        [btnTitles removeObjectAtIndex:0];
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:buttonTitles[0] destructiveButtonTitle:nil otherButtonTitles:nil];
    [btnTitles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [actionSheet addButtonWithTitle:obj];
    }];
    [self setActionSheetSettings:actionSheet];
    [actionSheet showInView:parent.view];

#endif
}
#pragma mark delegate
#ifdef __IPHONE_8_0

#else
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if(self.clickBlock){
        self.clickBlock(buttonIndex);
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(self.clickBlock){
        self.clickBlock(buttonIndex);
    }
}
#endif

@end
