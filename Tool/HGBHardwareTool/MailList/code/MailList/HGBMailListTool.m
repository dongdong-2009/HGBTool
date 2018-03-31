//
//  HGBMailListTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/10/31.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBMailListTool.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <ContactsUI/ContactsUI.h>
#import <Contacts/Contacts.h>



#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"




#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif



#ifdef __IPHONE_9_0
@interface HGBMailListTool()<CNContactPickerDelegate>
#else
@interface HGBMailListTool()<ABPeoplePickerNavigationControllerDelegate>
#endif



@end
@implementation HGBMailListTool
static HGBMailListTool* instance=nil;
#pragma mark init
/**
 单例

 @return 实例
 */
+ (instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBMailListTool alloc]init];
    }
    return instance;
}
/**
 单例

 @param parent 父控制器
 @param delegate 代理
 */
+(void)shareInstanceMailListBookInParent:(UIViewController *)parent andWithDelegate:(id<HGBMailListToolDelegate>)delegate{
    [HGBMailListTool shareInstance];
    instance.parent=parent;
    instance.delegate=delegate;
    
}
/**
 获取权限问题

 @return 权限结果
 */
+(HGBMailListAuthStatus)getAuthStatus{
#ifdef __IPHONE_9_0
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];

    if (status == CNAuthorizationStatusNotDetermined) {
         HGBLog(@"还没问呢");
        return HGBMailListAuthStatusNotDetermined;

    }else if (status == CNAuthorizationStatusAuthorized){
        HGBLog(@"已经授权");
        return HGBMailListAuthStatusAuthorized;
    }else if (status == CNAuthorizationStatusDenied){
        HGBLog(@"没有授权");
        return HGBMailListAuthStatusDenied;
    }else{
        HGBLog(@"没有授权");
        return HGBMailListAuthStatusRestricted;
    }
#else
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusNotDetermined) {
        HGBLog(@"还没问呢");
        return HGBMailListAuthStatusDenied;
    }else if (status == kABAuthorizationStatusAuthorized){
        HGBLog(@"已经授权");
        return HGBMailListAuthStatusAuthorized;
    }else if (status == kABAuthorizationStatusRestricted){
        HGBLog(@"没有授权");
        return HGBMailListAuthStatusRestricted;
    }else{
        HGBLog(@"没有授权");
        return HGBMailListAuthStatusNotDetermined;
    }
#endif


}
/**
 初始化通讯录

 @param completeBlock 结果
 */
+(void)initMailListWithCompleteBlock:(void(^)(BOOL status,NSDictionary *info))completeBlock{
#ifdef __IPHONE_9_0
    [[[CNContactStore alloc]init] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if(granted){
            completeBlock(YES,@{});

        }else{
            if(error){
                completeBlock(NO,@{ReslutCode:@(HGBMailListErrorError).stringValue,ReslutMessage:error.localizedDescription});
            }else{
                completeBlock(NO,@{ReslutCode:@(HGBMailListErrorError).stringValue,ReslutMessage:@"未知错误"});
            }
        }
    }];
#else
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error){
        if(granted){
            completeBlock(YES,@{});
        }else{
            if(error){
                completeBlock(NO,@{ReslutCode:@(HGBMailListErrorError).stringValue,ReslutMessage:@"未知错误"});
            }else{
                completeBlock(NO,@{ReslutCode:@(HGBMailListErrorError).stringValue,ReslutMessage:@"未知错误"});
            }
        }
    });
#endif
}



/**
 打开通讯录选择联系人

 @param parent 父控制器
 @param delegate 代理
 */
-(void)openMailListBookInParent:(UIViewController *)parent andWithDelegate:(id<HGBMailListToolDelegate>)delegate{
    [HGBMailListTool shareInstanceMailListBookInParent:parent andWithDelegate:delegate];
    if(self.parent==nil){
        self.parent=[HGBMailListTool currentViewController];
    }
    HGBMailListAuthStatus status=[HGBMailListTool getAuthStatus];
    if(status==HGBMailListAuthStatusNotDetermined){
        [HGBMailListTool initMailListWithCompleteBlock:^(BOOL status, NSDictionary *info) {
            if(status==YES){
                [self openMailListBook];

            }else{

                if(self.delegate&&[self.delegate respondsToSelector:@selector(mailList:didFailedWithError:)]){
                    [self.delegate mailList:self didFailedWithError:info];
                }

            }
        }];

    }else if(status==HGBMailListAuthStatusAuthorized){
         [self openMailListBook];
    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mailList:didFailedWithError:)]){
            [self.delegate mailList:self didFailedWithError:@{ReslutCode:@(HGBMailListAuthStatusAuthorized).stringValue,ReslutMessage:@"权限不足"}];
        }
         [self jumpToSet];
    }


}
/**
 打开通讯簿
 */
-(void)openMailListBook{
#ifdef __IPHONE_9_0
    CNContactPickerViewController *contactVc = [[CNContactPickerViewController alloc] init];
    //    这行代码false就是可以点进详通讯录情页，true就是点击列表页就返回
    if(self.isCanOpenMailDetails){
        contactVc.predicateForSelectionOfContact = [NSPredicate predicateWithValue:false];
    }else{
        contactVc.predicateForSelectionOfContact = [NSPredicate predicateWithValue:true];
    }
    contactVc.delegate = self;
    [self.parent presentViewController:contactVc animated:YES completion:nil];
#else
    ABPeoplePickerNavigationController *mailList = [[ABPeoplePickerNavigationController alloc] init];
    mailList.peoplePickerDelegate = self;
    [self.parent presentViewController:mailList animated:YES completion:nil];
#endif
}
/**
 获取全部联系人

 @param delegate 代理
 */
-(void)getMailListWithDelegate:(id<HGBMailListToolDelegate>)delegate{

    self.delegate=delegate;
    HGBMailListAuthStatus status=[HGBMailListTool getAuthStatus];
    if(status==HGBMailListAuthStatusNotDetermined){
        [HGBMailListTool initMailListWithCompleteBlock:^(BOOL status, NSDictionary *info) {
            if(status==YES){
                NSArray *mailList=[self getPersonInfoArray];
                if(self.delegate&&[self.delegate respondsToSelector:@selector(mailList:didSucessedWithMailArray:)]){
                    [self.delegate mailList:self didSucessedWithMailArray:mailList];
                }
            }else{
                if(self.delegate&&[self.delegate respondsToSelector:@selector(mailList:didFailedWithError:)]){
                    [self.delegate mailList:self didFailedWithError:info];
                }

            }
        }];

    }else if(status==HGBMailListAuthStatusAuthorized){
        NSArray *mailList=[self getPersonInfoArray];
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mailList:didSucessedWithMailArray:)]){
            [self.delegate mailList:self didSucessedWithMailArray:mailList];
        }
    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mailList:didFailedWithError:)]){
            [self.delegate mailList:self didFailedWithError:@{ReslutCode:@(HGBMailListErrorAuthorized).stringValue,ReslutMessage:@"权限不足"}];
        }
         [self jumpToSet];
    }

}

/**
 获取通讯录列表

 @return 通讯录列表
 */
- (NSArray *)getPersonInfoArray
{
#ifdef __IPHONE_9_0
    NSMutableArray *personArray = [NSMutableArray array];
    CNContactStore *contactStore = [[CNContactStore alloc] init];

    NSArray *keys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];

    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];

    [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        HGBMailModel *personEntity = [HGBMailListTool transeContactToModel:contact];
        [personArray addObject:personEntity];
    }];
    return personArray;
#else
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef peopleArray = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex peopleCount = CFArrayGetCount(peopleArray);

    NSMutableArray *personArray = [NSMutableArray array];
    for (int i = 0; i < peopleCount; i++) {

         ABRecordRef person = CFArrayGetValueAtIndex(peopleArray, i);
        HGBMailModel *personEntity =[HGBMailListTool transeABRecordToModel:person];
        [personArray addObject:personEntity];

    }
    CFRelease(addressBook);
    CFRelease(peopleArray);
    return personArray;
#endif

}

/**
 创建联系人

 @param name 联系人姓名
 @param phone 手机号
 @param delegate 代理
 */
-(void)creatItemWithName:(NSString *)name phone:(NSString *)phone andWithDelegate:(id<HGBMailListToolDelegate>)delegate
{
    self.delegate=delegate;
        HGBMailListAuthStatus status=[HGBMailListTool getAuthStatus];
    if(status==HGBMailListAuthStatusNotDetermined){
        [HGBMailListTool initMailListWithCompleteBlock:^(BOOL status, NSDictionary *info) {
            if(status==YES){
                BOOL flag=[self creatPeopleWithName:name phone:phone];
                if(flag){
                    if(self.delegate&&[self.delegate respondsToSelector:@selector(mailListDidCreateItemSucessed:)]){
                        [self.delegate mailListDidCreateItemSucessed:self];
                    }
                }else{
                    if(self.delegate&&[self.delegate respondsToSelector:@selector(mailList:didFailedWithError:)]){
                        [self.delegate mailList:self didFailedWithError:@{ReslutCode:@(HGBMailListErrorFailed).stringValue,ReslutMessage:@"创建联系人失败"}];
                    }
                }
            }else{
                if(self.delegate&&[self.delegate respondsToSelector:@selector(mailList:didFailedWithError:)]){
                    [self.delegate mailList:self didFailedWithError:info];
                }

            }
        }];

    }else if(status==HGBMailListAuthStatusAuthorized){
        BOOL flag=[self creatPeopleWithName:name phone:phone];
        if(flag){
            if(self.delegate&&[self.delegate respondsToSelector:@selector(mailListDidCreateItemSucessed:)]){
                [self.delegate mailListDidCreateItemSucessed:self];
            }
        }else{
            if(self.delegate&&[self.delegate respondsToSelector:@selector(mailList:didFailedWithError:)]){
                [self.delegate mailList:self didFailedWithError:@{ReslutCode:@(HGBMailListErrorFailed).stringValue,ReslutMessage:@"创建联系人失败"}];
            }
        }
    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(mailList:didFailedWithError:)]){
            [self.delegate mailList:self didFailedWithError:@{ReslutCode:@(HGBMailListErrorAuthorized).stringValue,ReslutMessage:@"权限不足"}];
        }
         [self jumpToSet];
    }



}
/**
 创建联系人

 @param name 联系人姓名
 @param phone 手机号
 */
-(BOOL)creatPeopleWithName:(NSString *)name phone:(NSString *)phone{
    if(name==nil||phone==nil||(name.length < 1)||(phone.length < 1)){
        return NO;
    }

#ifdef __IPHONE_9_0
    // 创建对象
    // 这个里面可以添加多个电话，email，地址等等。 感觉使用率不高，只提供了最常用的属性：姓名+电话，需要时可以自行扩展。
    CNMutableContact * contact = [[CNMutableContact alloc]init];
    contact.givenName = name?:@"defaultname";
    CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:phone?:@"10086"]];
    contact.phoneNumbers = @[phoneNumber];

    // 把对象加到请求中
    CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
    [saveRequest addContact:contact toContainerWithIdentifier:nil];

    // 执行请求
    CNContactStore * store = [[CNContactStore alloc]init];
    [store executeSaveRequest:saveRequest error:nil];
    return YES;

#else


    CFErrorRef error = NULL;

    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    ABRecordRef newRecord = ABPersonCreate();
    ABRecordSetValue(newRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)name, &error);

    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)name, kABPersonPhoneMobileLabel, NULL);

    ABRecordSetValue(newRecord, kABPersonPhoneProperty, multi, &error);
    CFRelease(multi);

    ABAddressBookAddRecord(addressBook, newRecord, &error);

    ABAddressBookSave(addressBook, &error);
    CFRelease(newRecord);
    CFRelease(addressBook);
    return YES;
#endif
}
#pragma mark  数据转换
/**
 将ABRecord转化为模型

 @param person ABRecord
 @return model 模型
 */
+(HGBMailModel *)transeABRecordToModel:(ABRecordRef )person{
     HGBMailModel *personEntity = [HGBMailModel new];
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    personEntity.lastname = lastName;
    personEntity.firstname = firstName;

    NSMutableString *fullname = [[NSString stringWithFormat:@"%@%@",lastName,firstName] mutableCopy];
    [fullname replaceOccurrencesOfString:@"(null)" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, fullname.length)];
    personEntity.fullname = fullname;

    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex phoneCount = ABMultiValueGetCount(phones);

     NSMutableArray *phoneNums=[NSMutableArray array];
    NSString *fullPhoneStr = [NSString string];
    for (int i = 0; i < phoneCount; i++) {
        NSString *phoneValue = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);
        phoneValue=[HGBMailListTool getNumberStringFromString:phoneValue];



        if (phoneValue.length > 0) {
            fullPhoneStr = [fullPhoneStr stringByAppendingString:phoneValue];
            fullPhoneStr = [fullPhoneStr stringByAppendingString:@","];
            [phoneNums addObject:phoneValue];
        }

    }
    if (fullPhoneStr.length > 1) {
        personEntity.phoneNumber = [fullPhoneStr substringToIndex:fullPhoneStr.length - 1];
    }
    CFRelease(phones);
    return personEntity;
}
/**
 将contact转化为模型

 @param contact contact
 @return model
 */
+(HGBMailModel *)transeContactToModel:(CNContact *)contact{
    HGBMailModel *personEntity = [HGBMailModel new];
    NSString *lastname = contact.familyName;
    NSString *firstname = contact.givenName;
    personEntity.lastname = lastname;
    personEntity.firstname = firstname;

    NSMutableString *fullname = [[NSString stringWithFormat:@"%@%@",lastname,firstname] mutableCopy];
    [fullname replaceOccurrencesOfString:@"(null)" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, fullname.length)];
    personEntity.fullname = fullname;

    NSArray *phoneNums = contact.phoneNumbers;
    NSMutableArray *phones=[NSMutableArray array];

    NSString *fullPhoneStr = [NSString string];
    for (CNLabeledValue *labeledValue in phoneNums) {
        CNPhoneNumber *phoneNumer = labeledValue.value;
        NSString *phoneValue = phoneNumer.stringValue;
        phoneValue=[HGBMailListTool getNumberStringFromString:phoneValue];
        if (phoneValue.length > 0) {
            fullPhoneStr = [fullPhoneStr stringByAppendingString:phoneValue];
            fullPhoneStr = [fullPhoneStr stringByAppendingString:@","];
            [phones addObject:phoneValue];
        }

    }
    if (fullPhoneStr.length > 1) {
        personEntity.phoneNumber = [fullPhoneStr substringToIndex:fullPhoneStr.length - 1];
    }
    return personEntity;
}
#ifdef __IPHONE_9_0
#pragma mark contactDelegate
/**
 *  这个方法是点击列表缩回就回调的方法，现在不会调用了
 */
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact
{
    HGBMailModel *personEntity = [HGBMailListTool transeContactToModel:contact];
    if(self.delegate&&[self.delegate respondsToSelector:@selector(mailList:didSucessedWithMail:)]){
        [self.delegate mailList:self didSucessedWithMail:personEntity];
    }
}

/**
 *  这个是点击详情页里面的一个字段才回调的方法
 */
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty
{

    [contactProperty.contact.phoneNumbers indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        CNLabeledValue *phoneObj = (CNLabeledValue *)obj;
        if([contactProperty.identifier isEqualToString:phoneObj.identifier]){

            CNPhoneNumber *phoneNumer = phoneObj.value;
            NSString *phoneValue = phoneNumer.stringValue;

            HGBMailModel *personEntity = [HGBMailModel new];
            personEntity.lastname = contactProperty.contact.familyName;
            personEntity.firstname = contactProperty.contact.givenName;
            NSMutableString *fullname = [[NSString stringWithFormat:@"%@ %@",personEntity.firstname,personEntity.lastname] mutableCopy];
            [fullname replaceOccurrencesOfString:@"(null)" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, fullname.length)];
            personEntity.fullname = fullname;
            personEntity.phoneNumber = phoneValue;
            if(self.delegate&&[self.delegate respondsToSelector:@selector(mailList:didSucessedWithMail:)]){
                [self.delegate mailList:self didSucessedWithMail:personEntity];
            }
            return true;
        }else{
            return false;
        }
    }];
}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker
{
    if(self.delegate &&[self.delegate respondsToSelector:@selector(mailListDidCanceled:)]){
        [self.delegate mailListDidCanceled:self];
    }
    HGBLog(@"点击取消后的代码");
}

#else
#pragma mark AddressBookDelegate
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(mailListDidCanceled:)]){
        [self.delegate mailListDidCanceled:self];
    }
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    HGBMailModel *personEntity= [HGBMailListTool transeABRecordToModel:person];
    if(self.delegate&&[self.delegate respondsToSelector:@selector(mailList:didSucessedWithMail:)]){
        [self.delegate mailList:self didSucessedWithMail:personEntity];
    }
   [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    return YES;
}
#endif



#pragma mark --set
-(void)jumpToSet{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"通讯录访问权限受限" preferredStyle:(UIAlertControllerStyleAlert)];
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
    [[HGBMailListTool currentViewController] presentViewController:alert animated:YES completion:nil];
}
#pragma mark 工具
/**
 *  获取数字字符串
 *
 *  @param string 原str
 *
 *  @return 字符串中的数字字符串
 */
+(NSString *)getNumberStringFromString:(NSString *)string{
    if(string==nil){
        HGBLog(@"字符串不能为空");
        return nil;
    }
    NSString *numStr=string;
    NSArray *numArr=@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    NSRange r;
    for(int i=0;i<string.length;i++){
        r.length=1;
        r.location=i;
        NSString *sub=[string substringWithRange:r];
        if(![numArr containsObject:sub]){
            numStr=[numStr stringByReplacingCharactersInRange:r withString:@"-"];
        }
    }
    while ([numStr containsString:@"-"]) {
        numStr=[numStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }

    return numStr;
}
#pragma mark 获取当前控制器

/**
 获取当前控制器

 @return 当前控制器
 */
+ (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [HGBMailListTool findBestViewController:viewController];
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
        return [HGBMailListTool findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBMailListTool findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBMailListTool findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBMailListTool findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        return vc;
    }
}
@end
