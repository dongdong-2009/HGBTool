//
//  HGBNotificationDataBaseTool.m
//  CordovaWork
//
//  Created by huangguangbao on 2018/4/21.
//

#import "HGBNotificationDataBaseTool.h"



#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <sqlite3.h>

#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@interface HGBNotificationDataBaseTool()
/**
 数据库
 */
@property(assign,nonatomic)sqlite3 *db;

/**
 数据库打开标志
 */
@property(assign,nonatomic)BOOL openFlag;

/**
 数据库地址
 */
@property(strong,nonatomic)NSString *dbPath;


/**
 数据库加密标志
 */
@property(assign,nonatomic)BOOL dataBaseEncrptFlag;
/**
 数据库加密密钥
 */
@property(strong,nonatomic)NSString *dataBaseEncrptKey;

/**
 数据库加密(表格-表格加密字典)key-表名 value 加密字段
 */
@property(strong,nonatomic)NSMutableDictionary *encryptDataDic;

/**
 数据库加密密钥(表格-表格加密密钥)
 */
@property(strong,nonatomic)NSMutableDictionary *encryptKeyDic;

@end

@implementation HGBNotificationDataBaseTool
@synthesize dbPath,db;
static HGBNotificationDataBaseTool *instance=nil;
#pragma mark 单例
/**
 数据库单例

 @return 数据库类
 */
+(instancetype)shareInstance{
    if(instance==nil){
        instance=[[HGBNotificationDataBaseTool alloc]init];



        NSString *bundleId=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];

        NSString *dataBasePath=[NSString stringWithFormat:@"document://%@Notification.db",bundleId];

        [instance openDataBaseWithSource:dataBasePath];
    }
    return instance;
}
#pragma mark 重启数据库
/**
 重启数据库

 @return 结果
 */
-(BOOL)reset{
    NSString *bundleId=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *dataBasePath=[NSString stringWithFormat:@"document://%@database.db",bundleId];
    return [self openDataBaseWithSource:dataBasePath];
}
#pragma mark 打开数据库
/**
 打开数据库-数据库仅能打开一个,该数据打开时上一数据库关闭,上一数据库关闭失败，该数据打开失败

 @param source 数据库地址或url
 @return 打开数据库结果
 */
-(BOOL)openDataBaseWithSource:(NSString *)source{
    if (source==nil||source.length==0) {
        return NO;
    }

    BOOL closeFlag=YES;
    if(self.openFlag){
        closeFlag=[self closeDataBase];
    }
    NSString *url=[HGBNotificationDataBaseTool urlAnalysis:source];

    NSString* dataBasePath=[[NSURL URLWithString:url]path];

    NSString* directoryPath=[dataBasePath stringByDeletingLastPathComponent];
    if(![HGBNotificationDataBaseTool isExitAtFilePath:directoryPath]){
        [HGBNotificationDataBaseTool createDirectoryPath:directoryPath];
    }
    if(closeFlag){
        if(sqlite3_open([dataBasePath UTF8String], &db)!=SQLITE_OK){
            //            HGBLog(@"打开数据库失败-关闭上个数据库成功");
            self.openFlag=NO;
            return NO;
        }else{
            //            HGBLog(@"打开数据库成功");
            self.openFlag=YES;
            self.dbPath=[NSString stringWithFormat:@"%@",dataBasePath];

            return YES;
        }
    }else{
        HGBLog(@"打开数据库失败-关闭上个数据库失败");
        self.openFlag=NO;
        return NO;
    }

}
#pragma mark 关闭数据库


/**
 关闭数据库

 @return 关闭结果
 */
-(BOOL)closeDataBase{
    if(self.openFlag){
        if(sqlite3_close(db)!=SQLITE_OK){
            HGBLog(@"关闭数据库失败");
            self.openFlag=YES;
            return NO;
        }else{

            //            HGBLog(@"关闭数据库成功");
            self.openFlag=NO;
            self.dataBaseEncrptFlag=NO;
            self.encryptDataDic=[NSMutableDictionary dictionary];

            return YES;
        }
    }else{
        //        HGBLog(@"关闭数据库成功");
        self.openFlag=NO;


        return YES;
    }
}
#pragma mark 数据库设置-加密

/**
 设置数据库加密标志-打开数据库需重新设置

 @param key 加密密钥
 */
-(BOOL)encryptDataBaseWithKey:(NSString *)key
{
    self.dataBaseEncrptFlag=YES;
    self.dataBaseEncrptKey=key;
    return YES;
}

#pragma mark 表格字段加密
/**
 设置数据库表中数据加密标志-打开数据库需重新设置

 @param valueKeys  加密字段
 @param key 加密密钥
 @param tableName 表明

 @return 设置结果
 */
-(BOOL)encryptTableWithValueKeys:(NSArray *)valueKeys andWithEncryptSecretKey:(NSString *)key inTableName:(NSString *)tableName{
    if(tableName==nil||tableName.length==0){
        HGBLog(@"设置表格及其加密字段失败");
        return NO;
    }
    if(valueKeys==nil){
        HGBLog(@"设置表格及其加密字段失败");
        return NO;
    }
    if(key==nil||key.length==0){
        HGBLog(@"设置表格及其加密字段失败");
        return NO;
    }

    [self.encryptDataDic setObject:valueKeys forKey:tableName];
    [self.encryptKeyDic setObject:key forKey:tableName];
    //    HGBLog(@"设置表格及其加密字段成功");
    return YES;
}


#pragma mark 创建表格-text



/**
 创建表格-默认text类型

 @param tableName 表名
 @param keys 字段名集合，可以包含主键名-默认为文本类型-不可为空
 @param primarykey 主键字段名
 */
-(BOOL)createTableWithTableName:(NSString *)tableName andWithKeys:(NSArray *)keys andWithPrimaryKey:(NSString *)primarykey{
    if(tableName==nil||tableName.length==0){
        HGBLog(@"创建表格失败");
        return NO;
    }
    if(keys==nil){
        HGBLog(@"创建表格失败");
        return NO;
    }
    if(primarykey==nil||primarykey.length==0){
        HGBLog(@"创建表格失败");
        return NO;
    }

    //sql
    NSString *sqlStr=[NSString stringWithFormat:@"create table if not exists %@(%@ integer primary key autoincrement",tableName,primarykey];
    for(NSString *key in keys){
        if(![key isEqualToString:primarykey]){
            sqlStr=[NSString stringWithFormat:@"%@,%@ text",sqlStr,key];
        }
    }
    sqlStr=[NSString stringWithFormat:@"%@)",sqlStr];

    char *error;
    const char *sql=[sqlStr UTF8String];
    //    HGBLog(@"sql:%s",sql);
    //执行
    if(sqlite3_exec(db, sql, NULL, NULL, &error)==SQLITE_OK){
        //        HGBLog(@"创建表格成功");
        return YES;
    }else{
        HGBLog(@"创建表格失败");
        HGBLog(@"error:%s",error);
        return NO;
    }
}
#pragma mark 创建表格-自定类型

/**
 创建表格-字段类型自定

 @param tableName 表名
 @param primarykey 主键字段名
 @param keyDic 数据字典 name-value 字段名值-数据类型-主键名要包含在其中
 */
-(BOOL)createTableWithTableName:(NSString *)tableName andWithKeyDic:(NSDictionary *)keyDic andWithPrimarykeyKey:(NSString *)primarykey{
    if(tableName==nil||tableName.length==0){
        HGBLog(@"创建表格失败");
        return NO;
    }
    if(keyDic==nil){
        //        HGBLog(@"创建表格失败");
        return NO;
    }
    if(primarykey==nil||primarykey.length==0){
        HGBLog(@"创建表格失败");
        return NO;
    }

    //sql
    NSString *sqlStr;
    NSString *keyType=[keyDic objectForKey:primarykey];
    if(keyType&&keyType.length!=0){
        sqlStr=[NSString stringWithFormat:@"create table if not exists %@(%@ %@ not null primary key",tableName,primarykey,[keyDic objectForKey:primarykey]];
    }else{
        sqlStr=[NSString stringWithFormat:@"create table if not exists %@(%@ integer primary key autoincrement",tableName,primarykey];
    }
    NSArray *keys=[keyDic allKeys];
    for(NSString *key in keys){
        if(![key isEqualToString:primarykey]){
            NSString *type=[keyDic objectForKey:key];
            if(type&&type.length!=0){
                sqlStr=[NSString stringWithFormat:@"%@,%@ %@",sqlStr,key,[keyDic objectForKey:key]];
            }else{
                sqlStr=[NSString stringWithFormat:@"%@,%@ text",sqlStr,key];
            }
        }
    }
    sqlStr=[NSString stringWithFormat:@"%@)",sqlStr];

    char *error;
    const char *sql=[sqlStr UTF8String];
    //    HGBLog(@"sql:%s",sql);
    //执行
    if(sqlite3_exec(db, sql, NULL, NULL, &error)==SQLITE_OK){
        //        HGBLog(@"创建表格成功");
        return YES;
    }else{
        HGBLog(@"创建表格失败");
        HGBLog(@"error:%s",error);
        return NO;
    }
}
#pragma mark 查询数据库表名集合

/**
 查询数据库表名集合

 @return 数据库表名集合
 */
-(NSArray *)queryTableNames{
    sqlite3_stmt *stmt;
    const char *sql = "select * from sqlite_master where type='table' order by name";
    NSMutableArray *namesArr=[NSMutableArray array];
    if(sqlite3_prepare_v2(db, sql, -1, &stmt, NULL)==SQLITE_OK){
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            char *nameData = (char *)sqlite3_column_text(stmt, 1);
            NSString *tableName = [[NSString alloc] initWithUTF8String:nameData];
            [namesArr addObject:tableName];
        }
    }
    return namesArr;
}
#pragma mark 表格字段名查询

/**
 表格查询字段名

 @param tableName 表格名称
 @return 查询结果-array[dic] key 字段名 value 字段类型
 */
-(NSArray *)queryNodeKeysWithTableName:(NSString *)tableName{
    if(tableName==nil||tableName.length==0){
        HGBLog(@"获取失败");
        return [NSArray array];
    }
    //sql
    sqlite3_stmt *stmt;
    NSString *sqlStr=[NSString stringWithFormat:@"PRAGMA table_info(%@)",tableName];

    //执行
    const char *sql = [sqlStr UTF8String];
    NSMutableArray *names=[NSMutableArray array];
    if(sqlite3_prepare_v2(db, sql, -1, &stmt, NULL)==SQLITE_OK){

        while (sqlite3_step(stmt) == SQLITE_ROW) {
            char *nameData = (char *)sqlite3_column_text(stmt, 1);
            int nType = sqlite3_column_type(stmt, 1);
            NSString *columnName = [[NSString alloc] initWithUTF8String:nameData];
            NSString *nameType=@"text";
            switch (nType)
            {
                case 1:
                    //SQLITE_INTEGER
                    nameType=@"integer";
                    break;
                case 2:
                    //SQLITE_FLOAT
                    nameType=@"float";
                    break;
                case 3:
                    //SQLITE_TEXT
                    nameType=@"text";
                    break;
                case 4:
                    //SQLITE_BLOB
                    nameType=@"blob";
                    break;
                case 5:
                    //SQLITE_NULL
                    nameType=@"null";
                    break;
            }

            [names addObject:@{@"name":columnName,@"type":nameType}];
        }
    }
    sqlite3_finalize(stmt);
    return names;
}
#pragma mark 删除表格

/**
 删除表格

 @param tableName 表格名称
 @return 删除结果
 */
-(BOOL)dropTableWithTableName:(NSString *)tableName{
    if(tableName==nil||tableName.length==0){
        HGBLog(@"删除表格失败");
        return NO;
    }
    char *error;

    //sql
    NSString *sqlStr=[NSString stringWithFormat:@"drop table if exists %@",tableName];

    const char *sql=[sqlStr UTF8String];

    //    HGBLog(@"sql:%s",sql);
    //执行
    if(sqlite3_exec(db, sql, NULL, NULL, &error)==SQLITE_OK){
        //        HGBLog(@"删除表格成功");
        return  YES;
    }else{
        HGBLog(@"删除表格失败");
        HGBLog(@"error:%s",error);
        return  NO;
    }
}
#pragma mark 表格改名
/**
 表格改名

 @param tableName 原表名
 @param newTableName 新表名
 @return 表格改名结果
 */
-(BOOL)renameTableWithTableName:(NSString *)tableName andWithNewTableName:(NSString *)newTableName{
    if(tableName==nil||tableName.length==0){
        HGBLog(@"表格改名失败");
        return NO;
    }
    if(newTableName==nil&&newTableName.length==0){
        HGBLog(@"表格改名失败");
        return NO;
    }
    char *error;
    //sql
    NSString *sqlStr=[NSString stringWithFormat:@"alter table %@ rename to %@",tableName,newTableName];
    const char *sql=[sqlStr UTF8String];
    //    HGBLog(@"sql:%s",sql);
    //执行
    if(sqlite3_exec(db, sql, NULL, NULL, &error)==SQLITE_OK){
        //        HGBLog(@"表格改名成功");
        return YES;
    }else{
        HGBLog(@"表格改名失败");
        HGBLog(@"error:%s",error);
        return NO;
    }
}

#pragma mark 数据库表增加记录
/**
 数据库表增加记录

 @param nodes 记录数据
 @param tableName 表名
 @return 增加记录结果
 */
-(BOOL)addNode:(NSDictionary *)nodes  withTableName:(NSString *)tableName{
    if(tableName==nil||tableName.length==0){
        HGBLog(@"表格增加记录失败");
        return NO;
    }
    if(nodes==nil||[nodes count]==0){
        HGBLog(@"表格增加记录失败");
        return NO;
    }

    //加密数据
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:nodes];


    NSMutableArray *encryptTableDataArr=[self.encryptDataDic objectForKey:tableName];
    NSString *key=[self.encryptKeyDic objectForKey:tableName];
    if(key&&key.length==0){
        key=tableName;
    }


    NSArray *names=[nodes allKeys];
    for(NSString *name in names){
        id value=[nodes objectForKey:name];
        NSString *string=[HGBNotificationDataBaseTool objectEncapsulation:value];
        if([encryptTableDataArr containsObject:name]){
            [dic setObject:[HGBNotificationDataBaseTool encryptStringWithAES256:string andWithKey:key] forKey:name];
        }else{
            [dic setObject:string forKey:name];

        }
    }


    //sql
    NSString *sqlStrKey=[NSString stringWithFormat:@"insert into %@(",tableName];

    NSString *sqlStrValue=[NSString stringWithFormat:@"values("];
    int i=0;
    for(NSString *name in names){
        if(i==0){
            sqlStrKey=[NSString stringWithFormat:@"%@%@",sqlStrKey,name];
            sqlStrValue=[NSString stringWithFormat:@"%@'%@'",sqlStrValue,[dic objectForKey:name]];

        }else{
            sqlStrKey=[NSString stringWithFormat:@"%@,%@",sqlStrKey,name];
            sqlStrValue=[NSString stringWithFormat:@"%@,'%@'",sqlStrValue,[dic objectForKey:name]];
        }
        i++;
    }

    NSString *sqlStr=[NSString stringWithFormat:@"%@) %@)",sqlStrKey,sqlStrValue];
    char *error;
    const char *sql=[sqlStr UTF8String];
    //    HGBLog(@"sql:%s",sql);
    //执行
    if(sqlite3_exec(db, sql, NULL, NULL, &error)==SQLITE_OK){
        //        HGBLog(@"表格增加记录成功");
        return YES;
    }else{
        HGBLog(@"表格增加记录失败");
        HGBLog(@"error:%s",error);

        return NO;
    }
}
#pragma mark 表格删除记录
/**
 数据库表删除记录

 @param conditionDic 记录条件-为空则删除全部记录
 @param tableName 表名
 @return 删除记录结果
 */
-(BOOL)removeNodesWithCondition:(NSDictionary *)conditionDic inTableWithTableName:(NSString *)tableName{
    if(tableName==nil||tableName.length==0){
        HGBLog(@"表格删除记录失败");
        return NO;
    }

    //加密
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:conditionDic];

    NSMutableArray *encryptTableDataArr=[self.encryptDataDic objectForKey:tableName];
    NSString *key=[self.encryptKeyDic objectForKey:tableName];
    if(key&&key.length==0){
        key=tableName;
    }

    NSArray *names=[conditionDic allKeys];
    for(NSString *name in names){
        id value=[conditionDic objectForKey:name];
        NSString *string=[HGBNotificationDataBaseTool objectEncapsulation:value];
        if([encryptTableDataArr containsObject:name]){
            [dic setObject:[HGBNotificationDataBaseTool encryptStringWithAES256:string andWithKey:key] forKey:name];
        }else{
            [dic setObject:string forKey:name];

        }
    }

    //sql
    NSString *sqlStr=[NSString stringWithFormat:@"delete from %@ where",tableName];

    if(dic==nil||[dic count]==0){
        sqlStr=[NSString stringWithFormat:@"delete from %@",tableName];
    }
    int i=0;
    for(NSString *name in names){
        if(i==0){
            sqlStr=[NSString stringWithFormat:@"%@ %@='%@'",sqlStr,name,[dic objectForKey:name]];
        }else{
            sqlStr=[NSString stringWithFormat:@"%@ and %@='%@'",sqlStr,name,[dic objectForKey:name]];
        }
        i++;
    }
    char *error;

    const char *sql=[sqlStr UTF8String];
    //    HGBLog(@"sql:%s",sql);
    //执行
    if(sqlite3_exec(db, sql, NULL, NULL, &error)==SQLITE_OK){
        //        HGBLog(@"表格删除记录成功");
        return YES;
    }else{
        HGBLog(@"表格删除记录失败");
        HGBLog(@"error:%s",error);
        return NO;
    }
}
#pragma mark 表格修改记录

/**
 数据库表修改记录

 @param conditionDic 条件-条件为空查询所有数据
 @param changeDic   修改内容
 @param tableName 表名
 @return 修改记录结果
 */
-(BOOL)updateNodeWithCondition:(NSDictionary *)conditionDic  andWithChangeDic:(NSDictionary *)changeDic inTableWithTableName:(NSString *)tableName{
    if(tableName==nil||tableName.length==0){
        HGBLog(@"表格修改记录失败");
        return NO;
    }
    //加密
    NSMutableDictionary *dic_condition=[NSMutableDictionary dictionaryWithDictionary:conditionDic];


    NSMutableArray *encryptTableDataArr=[self.encryptDataDic objectForKey:tableName];
    NSString *key=[self.encryptKeyDic objectForKey:tableName];
    if(key&&key.length==0){
        key=tableName;
    }

    //加密条件
    NSArray *names_condition=[conditionDic allKeys];
    for(NSString *name in names_condition){
        id value=[conditionDic objectForKey:name];
        NSString *string=[HGBNotificationDataBaseTool objectEncapsulation:value];
        if([encryptTableDataArr containsObject:name]){
            [dic_condition setObject:[HGBNotificationDataBaseTool encryptStringWithAES256:string andWithKey:key] forKey:name];
        }else{
            [dic_condition setObject:string forKey:name];

        }
    }
    //加密修改内容
    NSMutableDictionary *dic_change=[NSMutableDictionary dictionaryWithDictionary:changeDic];

    NSArray *names_change=[changeDic allKeys];
    for(NSString *name in names_change){

        id value=[changeDic objectForKey:name];
        NSString *string=[HGBNotificationDataBaseTool objectEncapsulation:value];
        if([encryptTableDataArr containsObject:name]){
            [dic_change setObject:[HGBNotificationDataBaseTool encryptStringWithAES256:string andWithKey:key] forKey:name];
        }else{
            [dic_change setObject:string forKey:name];

        }
    }
    //sql
    NSString *sqlChange=[NSString stringWithFormat:@"update %@ set",tableName];
    NSString *sqlCondition=@"";
    if(sqlCondition&&names_condition.count!=0){
        sqlCondition=[NSString stringWithFormat:@"where"];
    }

    int i=0;
    for(NSString *name in names_change){
        if(i==0){
            sqlChange=[NSString stringWithFormat:@"%@ %@='%@'",sqlChange,name,[dic_change objectForKey:name]];
        }else{
            sqlChange=[NSString stringWithFormat:@"%@,%@='%@'",sqlChange,name,[dic_change objectForKey:name]];
        }
        i++;
    }

    i=0;
    for(NSString *name in names_condition){
        if(i==0){
            sqlCondition=[NSString stringWithFormat:@"%@ %@='%@'",sqlCondition,name,[dic_condition objectForKey:name]];
        }else{
            sqlCondition=[NSString stringWithFormat:@"%@ and %@='%@'",sqlCondition,name,[dic_condition objectForKey:name]];
        }
        i++;
    }

    NSString *sqlStr=[NSString stringWithFormat:@"%@ %@",sqlChange,sqlCondition];
    char *error;
    const char *sql=[sqlStr UTF8String];

    //    HGBLog(@"sql:%s",sql);

    //执行
    if(sqlite3_exec(db, sql, NULL, NULL, &error)==SQLITE_OK){
        //        HGBLog(@"表格修改记录成功");

        return YES;
    }else{
        HGBLog(@"表格修改记录失败");
        HGBLog(@"error:%s",error);
        return NO;
    }
}

#pragma mark 表格记录查询
/**
 表格查询

 @param conditionDic 查询条件
 @param tableName 表格名称
 @return 查询结果
 */
-(NSArray *)queryNodesWithCondition:(NSDictionary *)conditionDic inTableWithTableName:(NSString *)tableName{
    if(tableName==nil||tableName.length==0){
        HGBLog(@"查询表格记录失败");
        return [NSArray array];
    }


    //加密
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:conditionDic];

    NSMutableArray *encryptTableDataArr=[self.encryptDataDic objectForKey:tableName];
    NSString *key=[self.encryptKeyDic objectForKey:tableName];
    if(key&&key.length==0){
        key=tableName;
    }

    NSArray *names=[conditionDic allKeys];
    for(NSString *name in names){
        id value=[conditionDic objectForKey:name];
        NSString *string=[HGBNotificationDataBaseTool objectEncapsulation:value];
        if([encryptTableDataArr containsObject:name]){
            [dic setObject:[HGBNotificationDataBaseTool encryptStringWithAES256:string andWithKey:key] forKey:name];
        }else{
            [dic setObject:string forKey:name];

        }
    }

    //sql
    NSString *sqlStr=[NSString stringWithFormat:@"select * from %@ where",tableName];
    if(dic==nil||[dic count]==0){
        sqlStr=[NSString stringWithFormat:@"select * from %@",tableName];
    }

    int i=0;
    for(NSString *name in names){
        if(i==0){
            sqlStr=[NSString stringWithFormat:@"%@ %@='%@'",sqlStr,name,[dic objectForKey:name]];
        }else{
            sqlStr=[NSString stringWithFormat:@"%@ and %@='%@'",sqlStr,name,[dic objectForKey:name]];
        }
        i++;
    }

    const char *sql=[sqlStr UTF8String];
    sqlite3_stmt *stmt;
    NSMutableArray *searchArr=[NSMutableArray array];
    if(sqlite3_prepare_v2(db, sql, -1, &stmt, NULL)==SQLITE_OK){
        NSArray *searchNames=[self queryNodeKeysWithTableName:tableName];
        //遍历
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            for(int i=0;i<searchNames.count;i++){
                NSDictionary *nameDic=[searchNames objectAtIndex:i];
                NSArray *subnames=[nameDic allKeys];
                if(subnames.count!=0){
                    NSString *subname=[nameDic objectForKey:@"name"];
                    const unsigned char *value=sqlite3_column_text(stmt, i);
                    NSString *valueStr=[NSString stringWithFormat:@"%s",value];
                    NSString *string;
                    if([encryptTableDataArr containsObject:subname]){
                        string=[HGBNotificationDataBaseTool decryptStringWithAES256:valueStr andWithKey:key];
                    }else{
                        string=valueStr;
                    }
                    id lastvalue=[HGBNotificationDataBaseTool stringAnalysis:string];
                    [dic setObject:lastvalue forKey:subname];

                }

            }
            [searchArr addObject:dic];

        }

    }
    sqlite3_finalize(stmt);
    return searchArr;
}
#pragma mark 执行sql语句-返回执行状态

/**
 执行sql语句

 @param sqlString sql语句
 @return 执行结果
 */
-(BOOL)alterDataBySqlString:(NSString *)sqlString{
    char *error;

    if(sqlString&&sqlString.length==0){
        HGBLog(@"执行失败");
        return NO;
    }
    const char *sql=[sqlString UTF8String];

    //    HGBLog(@"sql:%s",sql);
    //执行
    if(sqlite3_exec(db, sql, NULL, NULL, &error)==SQLITE_OK){
        //        HGBLog(@"执行成功");
        return  YES;
    }else{
        HGBLog(@"执行失败");
        HGBLog(@"error:%s",error);
        return  NO;
    }
}
#pragma mark 执行sql语句-返回数据结果
/**
 执行sql语句并返回数据结果-目前仅支持text结果

 @param sqlString sql语句
 @param tableName 表格
 @return 返回结果
 */
-(NSArray *)queryDataBySqlString:(NSString *)sqlString  andWithNodeAttributeCount:(NSString *)count andWithTableName:(NSString *)tableName
{
    if(sqlString&&sqlString.length==0){
        HGBLog(@"执行失败");
        return [NSArray array];
    }
    if(tableName==nil||tableName.length==0){
        HGBLog(@"查询表格记录失败");
        return [NSArray array];
    }

    NSMutableArray *encryptTableDataArr=[self.encryptDataDic objectForKey:tableName];
    NSString *key=[self.encryptKeyDic objectForKey:tableName];
    if(key&&key.length==0){
        key=tableName;
    }
    const char *sql=[sqlString UTF8String];
    sqlite3_stmt *stmt;
    NSMutableArray *searchArr=[NSMutableArray array];
    if(sqlite3_prepare_v2(db, sql, -1, &stmt, NULL)==SQLITE_OK){
        //遍历
        NSArray *searchNames=[self queryNodeKeysWithTableName:tableName];
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            for(int i=0;i<searchNames.count;i++){
                NSDictionary *nameDic=[searchNames objectAtIndex:i];
                NSArray *subnames=[nameDic allKeys];
                if(subnames.count!=0){
                    NSString *subname=[nameDic objectForKey:@"name"];
                    NSString *type=[nameDic objectForKey:@"type"];
                    if([type isEqualToString:@"text"]){



                    }else{

                    }
                    const unsigned char *value=sqlite3_column_text(stmt, i);
                    NSString *valueStr=[NSString stringWithFormat:@"%s",value];
                    if([encryptTableDataArr containsObject:subname]){
                        [dic setObject:[HGBNotificationDataBaseTool decryptStringWithAES256:valueStr andWithKey:key] forKey:subname];
                    }else{
                        [dic setObject:valueStr forKey:subname];
                    }

                }

            }
            [searchArr addObject:dic];
        }
    }
    sqlite3_finalize(stmt);
    return searchArr;
}
#pragma mark get
-(NSMutableDictionary *)encryptDataDic{
    if(_encryptDataDic==nil){
        _encryptDataDic=[NSMutableDictionary dictionary];
    }
    return _encryptDataDic;
}
-(NSMutableDictionary *)encryptKeyDic{
    if(_encryptKeyDic==nil){
        _encryptKeyDic=[NSMutableDictionary dictionary];
    }
    return _encryptKeyDic;
}
#pragma mark AES256-string
/**
 AES256加密

 @param string 字符串
 @param key  加密密钥
 @return 加密后字符串
 */
+(NSString *)encryptStringWithAES256:(NSString *)string andWithKey:(NSString *)key{
    if(key==nil||key.length==0){
        return nil;
    }
    if(string==nil){
        return nil;
    }
    NSString *encryptString= [HGBNotificationDataBaseTool AES256StringEncrypt:string WithKey:key];
    return encryptString;
}
/**
 AES256解密

 @param string 字符串
 @param key  解密密钥
 @return 解密后字符串
 */
+(NSString *)decryptStringWithAES256:(NSString *)string
                          andWithKey:(NSString *)key{
    if(key==nil||key.length==0){
        return nil;
    }
    if(string==nil){
        return nil;
    }
    NSString *decryptString= [HGBNotificationDataBaseTool AES256StringDecrypt:string WithKey:key];
    return decryptString;
}

#pragma mark AES256-string
+ (NSString *)AES256StringEncrypt:(NSString *)string  WithKey:(NSString *)keyString
{

    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [keyString getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    NSData *sourceData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [sourceData length];
    size_t buffersize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(buffersize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCBlockSizeAES128, NULL, [sourceData bytes], dataLength, buffer, buffersize, &numBytesEncrypted);

    if (cryptStatus == kCCSuccess) {
        NSData *encryptData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        //对加密后的二进制数据进行base64转码
        return [encryptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    else
    {
        free(buffer);
        return nil;
    }

}

+ (NSString *)AES256StringDecrypt:(NSString *)string WithKey:(NSString *)keyString
{
    //先对加密的字符串进行base64解码
    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];

    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [keyString getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    NSUInteger dataLength = [decodeData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCBlockSizeAES128, NULL, [decodeData bytes], dataLength, buffer, bufferSize, &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return result;
    }
    else
    {
        free(buffer);
        return nil;
    }

}
#pragma mark 首选项
/**
 *  Defaults保存
 *
 *  @param value   要保存的数据
 *  @param key   关键字
 *  @return 保存结果
 */
+(BOOL)saveDefaultsValue:(id)value WithKey:(NSString *)key{
    if((!value)||(!key)||key.length==0){
        return NO;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
    return YES;
}
/**
 *  Defaults取出
 *
 *  @param key     关键字
 *  return  返回已保存的数据
 */
+(id)getDefaultsWithKey:(NSString *)key{
    if(key==nil||key.length==0){
        return nil;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id  value=[defaults objectForKey:key];
    [defaults synchronize];
    return value;
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
#pragma mark object-string
/**
 object编码

 @param object 对象
 @return 编码字符串
 */
+(NSString *)objectEncapsulation:(id)object{
    NSString *string;
    if([object isKindOfClass:[NSString class]]){
        string=[NSString stringWithFormat:@"%@",object];
    }else if([object isKindOfClass:[NSArray class]]){
        object=[HGBNotificationDataBaseTool ObjectToJSONString:object];
        string=[@"array://" stringByAppendingString:object];
    }else if([object isKindOfClass:[NSDictionary class]]){
        object=[HGBNotificationDataBaseTool ObjectToJSONString:object];
        string=[@"dictionary://" stringByAppendingString:object];
    }else if([object isKindOfClass:[NSNumber class]]){
        string=[NSString stringWithFormat:@"number://%@",object];
    }else if([object isKindOfClass:[NSData class]]){
        NSData *encodeData =object;
        NSString *base64String = [encodeData base64EncodedStringWithOptions:0];
        string=[NSString stringWithFormat:@"data://%@",base64String];
    }else{
        string=object;
    }




    return string;
}
/**
 字符串解码

 @param string 字符串
 @return 对象
 */
+(id)stringAnalysis:(NSString *)string{
    id object;
    if([string hasPrefix:@"string://"]){
        string=[string stringByReplacingOccurrencesOfString:@"string://" withString:@""];
        object=string;
    }else if([string hasPrefix:@"array://"]){
        string=[string stringByReplacingOccurrencesOfString:@"array://" withString:@""];
        object=[HGBNotificationDataBaseTool JSONStringToObject:string];
    }else if ([string hasPrefix:@"dictionary://"]){
        string=[string stringByReplacingOccurrencesOfString:@"dictionary://" withString:@""];
        object=[HGBNotificationDataBaseTool JSONStringToObject:string];
    }else if ([string hasPrefix:@"number://"]){
        string=[string stringByReplacingOccurrencesOfString:@"number://" withString:@""];
        object=[[NSNumber alloc]initWithFloat:string.floatValue];
    }else if ([string hasPrefix:@"number://"]){
        string=[string stringByReplacingOccurrencesOfString:@"data://" withString:@""];
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
        object=decodedData;
    }else{
        object=string;
    }
    return object;

}
#pragma mark json
/**
 把Json对象转化成json字符串

 @param object json对象
 @return json字符串
 */
+ (NSString *)ObjectToJSONString:(id)object
{

    if(!([object isKindOfClass:[NSDictionary class]]||[object isKindOfClass:[NSArray class]]||[object isKindOfClass:[NSString class]])){
        return nil;
    }
    if([object isKindOfClass:[NSString class]]){
        return object;
    }
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return myString;
}
/**
 把Json字符串转化成json对象

 @param jsonString json字符串
 @return json字符串
 */
+ (id)JSONStringToObject:(NSString *)jsonString{
    if(![jsonString isKindOfClass:[NSString class]]){
        return nil;
    }
    jsonString=[HGBNotificationDataBaseTool jsonStringHandle:jsonString];
    //    NSLog(@"%@",jsonString);
    NSError *error = nil;
    NSData  *data=[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if(jsonString.length>0&&[[jsonString substringToIndex:1] isEqualToString:@"{"]){
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if(error){
            NSLog(@"%@",error);
            return jsonString;
        }else{
            return dic;
        }
    }else if(jsonString.length>0&&[[jsonString substringToIndex:1] isEqualToString:@"["]){
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if(error){
            NSLog(@"%@",error);
            return jsonString;
        }else{
            return array;
        }
    }else{
        return jsonString;
    }


}
/**
 json字符串处理

 @param jsonString 字符串处理
 @return 处理后字符串
 */
+(NSString *)jsonStringHandle:(NSString *)jsonString{
    NSString *string=jsonString;
    //大括号

    //中括号
    while ([string containsString:@"【"]) {
        string=[string stringByReplacingOccurrencesOfString:@"【" withString:@"]"];
    }
    while ([string containsString:@"】"]) {
        string=[string stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
    }

    //小括弧
    while ([string containsString:@"（"]) {
        string=[string stringByReplacingOccurrencesOfString:@"（" withString:@"("];
    }

    while ([string containsString:@"）"]) {
        string=[string stringByReplacingOccurrencesOfString:@"）" withString:@")"];
    }


    while ([string containsString:@"("]) {
        string=[string stringByReplacingOccurrencesOfString:@"(" withString:@"["];
    }

    while ([string containsString:@")"]) {
        string=[string stringByReplacingOccurrencesOfString:@")" withString:@"]"];
    }


    //逗号
    while ([string containsString:@"，"]) {
        string=[string stringByReplacingOccurrencesOfString:@"，" withString:@","];
    }
    while ([string containsString:@";"]) {
        string=[string stringByReplacingOccurrencesOfString:@";" withString:@","];
    }
    while ([string containsString:@"；"]) {
        string=[string stringByReplacingOccurrencesOfString:@"；" withString:@","];
    }
    //引号
    while ([string containsString:@"“"]) {
        string=[string stringByReplacingOccurrencesOfString:@"“" withString:@"\""];
    }
    while ([string containsString:@"”"]) {
        string=[string stringByReplacingOccurrencesOfString:@"”" withString:@"\""];
    }
    while ([string containsString:@"‘"]) {
        string=[string stringByReplacingOccurrencesOfString:@"‘" withString:@"\""];
    }
    while ([string containsString:@"'"]) {
        string=[string stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    }
    //冒号
    while ([string containsString:@"："]) {
        string=[string stringByReplacingOccurrencesOfString:@"：" withString:@":"];
    }
    //等号
    while ([string containsString:@"="]) {
        string=[string stringByReplacingOccurrencesOfString:@"=" withString:@":"];
    }
    while ([string containsString:@"="]) {
        string=[string stringByReplacingOccurrencesOfString:@"=" withString:@":"];
    }
    return string;

}
#pragma mark 文件
/**
 文档是否存在

 @param filePath 文件路径
 @return 结果
 */
+(BOOL)isExitAtFilePath:(NSString *)filePath{
    if(filePath==nil||filePath.length==0){
        return NO;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL isExit=[filemanage fileExistsAtPath:filePath];
    return isExit;
}
/**
 创建文件夹

 @param directoryPath 路径
 @return 结果
 */
+(BOOL)createDirectoryPath:(NSString *)directoryPath{
    if([HGBNotificationDataBaseTool isExitAtFilePath:directoryPath]){
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
    if(![HGBNotificationDataBaseTool isURL:url]){
        return NO;
    }
    url=[HGBNotificationDataBaseTool urlAnalysis:url];
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
    if(![HGBNotificationDataBaseTool isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBNotificationDataBaseTool urlAnalysis:url];
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
    if(![HGBNotificationDataBaseTool isURL:url]){
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
    if(![HGBNotificationDataBaseTool isURL:url]){
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
