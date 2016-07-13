//
//  YYDataBaseManager.m
//  myDataBase
//
//  Created by Mac on 16/7/11.
//  Copyright © 2016年 Mac. All rights reserved.
//

// 通过实体获取属性数组
#define Get_Model_AllPropertys(Model)                     [self getModelAllProperty:Model]
// 通过实体获取属性数量
#define Get_Model_AllProperty_Count(Model)                [[self getModelAllProperty:Model] count]
// 通过实体获取类名
#define Get_ModelName(Model)                              [NSString stringWithUTF8String:object_getClassName(Model)]


#import "YYDataBaseManager.h"
#import "FMDB.h"
#import <objc/runtime.h>


@interface YYDataBaseManager ()
@property (nonatomic,strong) FMDatabase *db;
@end

@implementation YYDataBaseManager

+ (YYDataBaseManager *)defauleDataBaseManager
{
    static YYDataBaseManager *yyDBManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        yyDBManager = [[YYDataBaseManager alloc] init];
    });
    
    return yyDBManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createDataBase];
    }
    return self;
}

// 创建数据库
- (void)createDataBase
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    path = [path stringByAppendingPathComponent:@"AllTable.db"];
    self.db = [[FMDatabase alloc] initWithPath:path];
}

- (void)createTableWithModel:(id)model
{
    // 判断是否实例化
    if (!_db) {
        [self createDataBase];
    }
    
    // 判断数据库是否能打开
    if (![self.db open]) {
        NSLog(@"数据路打开失败");
        return;
    }
    
    // 创建表语句
    // @"create table if not exists %@ (%@ UNIQUE,%@ text,%@ text,%@ text)";
    // 根据类名判断是否找到表  没找到就创建一个
    if (![self.db tableExists:Get_ModelName(model)]) {
        //1. 根据类名作为表名
        //2. 根据属性作为表的字段 每个字段的类型都是TEXT
        NSString *tableSqlStrHeader = [NSString stringWithFormat:@"create table if not exists %@ (",Get_ModelName(model)];
        NSString *tableSqlStr = @"";
        NSLog(@"属性的个数  %ld  ",Get_Model_AllProperty_Count(model));
        for (NSInteger index = 0; index < Get_Model_AllProperty_Count(model); index ++) {
            // 用UNIQUE作为表的标示 用model的第一个属性作为标示
            //UNIQUE 独一无二的
            //                UNIQUE 约束唯一标识数据库表中的每条记录。
            //                UNIQUE 和 PRIMARY KEY 约束均为列或列集合提供了唯一性的保证。
            //                PRIMARY KEY 拥有自动定义的 UNIQUE 约束。
            //                请注意，每个表可以有多个 UNIQUE 约束，但是每个表只能有一个 PRIMARY KEY 约束
            if ([tableSqlStr isEqualToString:@""]) {
               tableSqlStr = [tableSqlStr stringByAppendingFormat:@"%@ UNIQUE,",[Get_Model_AllPropertys(model) objectAtIndex:index]];
            }
            else
            {
                if (index == Get_Model_AllProperty_Count(model) - 1) {
                    tableSqlStr = [tableSqlStr stringByAppendingFormat:@"%@ text)",[Get_Model_AllPropertys(model) objectAtIndex:index]];
                }
                else
                {
                    tableSqlStr = [tableSqlStr stringByAppendingFormat:@"%@ text,",[Get_Model_AllPropertys(model) objectAtIndex:index]];
                }
                
            }
            
           
        }
        
        NSString *lastSqlstr = [NSString stringWithFormat:@"%@%@",tableSqlStrHeader,tableSqlStr];
        NSLog(@"创建表的sql语句   ======    %@",lastSqlstr);
        [self.db executeUpdate:lastSqlstr];
        NSLog(@"创建表完成");
    }
    
    BOOL isHaveTable = [self.db tableExists:Get_ModelName(model)];
    
    NSLog(@"创建表完成%d",isHaveTable);
    // 关闭数据库
    [self.db close];
    
}

- (void)insertAndUpdataModelToDataBase:(id)model
{
    
    // 判断是否实例化
    if (!_db) {
        [self createDataBase];
    }
    
    // 判断数据库是否能打开
    if (![self.db open]) {
        NSLog(@"数据路打开失败");
        return;
    }
    // 判断用model类名命名的table是否存在
    if (![self.db tableExists:Get_ModelName(model)]) {
        [self createTableWithModel:model];
    }
    
    // 拼接插入语句的头部
    // insert or replace into 如果有数据  复盖  没有就插入
    //  @"INSERT OR REPLACE INTO %@(属性) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)",TABLE];
    
    NSString *sqlHeaderStr = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@",Get_ModelName(model)];
    // 把属性用","串联起来
    NSString *valuesLeftSqlStr = [Get_Model_AllPropertys(model) componentsJoinedByString:@","];
    
    NSMutableArray *modelValuesArray = [NSMutableArray array];
    NSMutableArray *valuesArray = [NSMutableArray array];
    for (NSInteger index = 0; index < Get_Model_AllProperty_Count(model); index ++) {
        NSString *str = [model valueForKey:[Get_Model_AllPropertys(model) objectAtIndex:index]];
        if (str == nil) {
            str = @"Nothing";
        }
        [valuesArray addObject:@"?"];
        [modelValuesArray addObject:str];
    }
    // 把属性对应的values用“,”串联起来
    NSString *valuesRightSqlStr = [valuesArray componentsJoinedByString:@","];
    
    NSString *lastSqlStr = [NSString stringWithFormat:@"%@ (%@) VALUES (%@)",sqlHeaderStr,valuesLeftSqlStr,valuesRightSqlStr];
    
    [self.db executeUpdate:lastSqlStr withArgumentsInArray:modelValuesArray];
    
    
    [self.db close];
    
}

- (NSArray *)selectAllModelFromeDataBase:(id)model
{
    
    // 判断是否实例化
    if (!_db) {
        [self createDataBase];
    }
    
    // 判断数据库是否能打开
    if (![self.db open]) {
        NSLog(@"数据路打开失败");
        return nil;
    }
    // 判断用model类名命名的table是否存在
    if (![self.db tableExists:Get_ModelName(model)]) {
        [self createTableWithModel:model];
    }
    
    NSMutableArray *allData = [NSMutableArray array];
    
    NSString *lastSqlStr = [NSString stringWithFormat:@"select * from %@",Get_ModelName(model)];
    
    FMResultSet *set = [self.db executeQuery:lastSqlStr];
    while ([set next]) {
        // 用id类型变量的类去创建对象
        id modelResult = [[[model class]alloc] init];
        for (NSInteger index = 0; index < Get_Model_AllProperty_Count(model); index ++) {
            [modelResult setValue:[set stringForColumn:[Get_Model_AllPropertys(model) objectAtIndex:index]] forKey:[Get_Model_AllPropertys(model) objectAtIndex:index]];
        }
        [allData addObject:modelResult];
    }
    
    return allData;
}

- (BOOL)deletaModelFromDataBase:(id)model byProperty:(NSString *)property andPropertyFromValues:(NSString *)values
{
    // 判断是否实例化
    if (!_db) {
        [self createDataBase];
    }
    
    // 判断数据库是否能打开
    if (![self.db open]) {
        NSLog(@"数据路打开失败");
        return NO;
    }
    // 判断用model类名命名的table是否存在
    if (![self.db tableExists:Get_ModelName(model)]) {
        [self createTableWithModel:model];
    }
    
    // 便利表内所有数据 找到要删除的数据
//    NSString *lastSqlStr = [NSString stringWithFormat:@"select * from %@",Get_ModelName(model)];
//    
//    FMResultSet *set = [self.db executeQuery:lastSqlStr];
//    while ([set next]) {
//        // 根据数据库里面的每个对象  找到对应的值
//        for (NSInteger index = 0; index < Get_Model_AllProperty_Count(model); index ++) {
//            // 对比一下是否有删除数据对应的属性
//            if ([property isEqualToString:[Get_Model_AllPropertys(model) objectAtIndex:index]]) {
//                NSString *searchStr = [set stringForColumn:property];
//                // 如果找到相同的就删除该条数据
//                if ([values isEqualToString:searchStr]) {
//                    NSString *deletaSqlStr = [NSString stringWithFormat:@"delete from %@ where %@ = ?",Get_ModelName(model),property];
//                    BOOL isDeleta = [self.db executeUpdate:deletaSqlStr,searchStr];
//                    [self.db close];
//                    return isDeleta;
//                }
//            }
//            
//           
//        }
//        
//    }
//    [self.db close];
//    
//    return NO;
    
    NSString *deletaSqlStr = [NSString stringWithFormat:@"delete from %@ where %@ = ?",Get_ModelName(model),property];
    BOOL isDeleta = [self.db executeUpdate:deletaSqlStr,values];
    [self.db close];
    return isDeleta;
}


- (NSArray *)selectModelFromDataBase:(id)model byProperty:(NSString *)property withPropertyValues:(NSString *)values
{
    NSMutableArray *searchArray = [NSMutableArray array];
    
    // 判断是否实例化
    if (!_db) {
        [self createDataBase];
    }
    
    // 判断数据库是否能打开
    if (![self.db open]) {
        NSLog(@"数据路打开失败");
        return nil;
    }
    // 判断用model类名命名的table是否存在
    if (![self.db tableExists:Get_ModelName(model)]) {
        [self createTableWithModel:model];
    }
    
    //筛选表内数据
    NSString *lastSqlStr = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'",Get_ModelName(model),property,values];
    
    FMResultSet *set = [self.db executeQuery:lastSqlStr];
    while ([set next]) {
            
        // 用id类型变量的类去创建对象
        id modelResult = [[[model class]alloc] init];
        for (NSInteger index = 0; index < Get_Model_AllProperty_Count(model); index ++) {
            [modelResult setValue:[set stringForColumn:[Get_Model_AllPropertys(model) objectAtIndex:index]] forKey:[Get_Model_AllPropertys(model) objectAtIndex:index]];
        }
        [searchArray addObject:modelResult];
    }
    [self.db close];
    
    return searchArray;
}

- (NSArray *)getModelAllProperty:(id)model
{
    u_int count;
    
    // 获取某个类下面的全部属性
    objc_property_t *property = class_copyPropertyList([model class], &count);
    
    NSMutableArray *propertys = [NSMutableArray array];
    for (NSInteger insex = 0; insex < count; insex ++) {
        // 获取对应属性的名字
        const char *propertyName = property_getName(property[insex]);
        [propertys addObject:[NSString stringWithUTF8String:propertyName]];
        
    }
    
    free(property);
    return propertys;
}

@end
