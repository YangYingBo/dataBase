//
//  YYDataBaseManager.h
//  myDataBase
//
//  Created by Mac on 16/7/11.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYDataBaseManager : NSObject
/**
 *  创建单例
 *
 */
+ (YYDataBaseManager *)defauleDataBaseManager;
/**
 *  更新或者添加数据
 *
 *  @param model model
 */
- (void)insertAndUpdataModelToDataBase:(id)model;
/**
 *  获取表中所有数据
 *
 *  @param model model
 *
 *  @return array
 */
- (NSArray *)selectAllModelFromeDataBase:(id)model;
/**
 *  根据指定属性  指定的数值  获取数据库中的数据
 *
 *  @param model    model
 *  @param property 指定属性
 *  @param values   指定数值
 *
 *  @return array
 */
- (NSArray *)selectModelFromDataBase:(id)model byProperty:(NSString *)property withPropertyValues:(NSString *)values;
/**
 *  删除指定属性指定内容的数据
 *
 *  @param model    model
 *  @param property 指定属性
 *  @param values   指定内容
 *
 *  @return 是否删除成功
 */
- (BOOL)deletaModelFromDataBase:(id)model byProperty:(NSString *)property andPropertyFromValues:(NSString *)values;
@end
