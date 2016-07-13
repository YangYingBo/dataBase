//
//  ViewController.m
//  myDataBase
//
//  Created by Mac on 16/7/11.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "ViewController.h"
#import "YYDataBaseManager.h"
#import "User.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    for (NSInteger i = 0; i < 10; i ++) {
        User *u = [[User alloc] init];
        u.user_id = [NSString stringWithFormat:@"%ld",(long)i];
        u.name = @"xiaoming";
        u.sex = @"men";
        u.height = @"177";
        u.age = @"";
        [[YYDataBaseManager defauleDataBaseManager] insertAndUpdataModelToDataBase:u];
    }
    //查找所有
    NSArray *arr1 = [[YYDataBaseManager defauleDataBaseManager] selectAllModelFromeDataBase:[User class]];
    for (User *us in arr1) {
        NSLog(@"arr1 %@,%@,%@,%@,%@",us.user_id,us.name,us.age,us.sex,us.height);
    }
    // 查找指定
    NSArray *arr2 = [[YYDataBaseManager defauleDataBaseManager] selectModelFromDataBase:[User class] byProperty:@"user_id" withPropertyValues:@"2"];
    for (User *us in arr2) {
        NSLog(@"arr2 %@,%@,%@,%@,%@",us.user_id,us.name,us.age,us.sex,us.height);
    }
    
    // 删除指定
    BOOL isde = [[YYDataBaseManager defauleDataBaseManager] deletaModelFromDataBase:[User class] byProperty:@"user_id" andPropertyFromValues:@"1"];
    // 查找删除后所有
    NSArray *arr = [[YYDataBaseManager defauleDataBaseManager] selectAllModelFromeDataBase:[User class]];
    NSLog(@" %@ %@ %@   %d",arr2,arr1,arr,isde);
    
    for (User *us in arr) {
        NSLog(@"arr  %@,%@,%@,%@,%@",us.user_id,us.name,us.age,us.sex,us.height);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
