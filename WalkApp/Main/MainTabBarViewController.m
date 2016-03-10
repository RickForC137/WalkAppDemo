//
//  MainTabBarViewController.m
//  WalkApp
//
//  Created by ZDwork on 16/2/18.
//  Copyright © 2016年 ZDwork. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "MapViewController.h"
#import "ViewController.h"
#import "TrajectoryViewController.h"
#import "PersonalViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadData];
}

#pragma mark - tabBar的子控制器以及属性设置
- (void)loadData
{
    UINavigationController *mapVC = [[UINavigationController alloc]initWithRootViewController:[[ViewController alloc]init]];
    UINavigationController *traVC = [[UINavigationController alloc]initWithRootViewController:[[TrajectoryViewController alloc]init]];
    UINavigationController *perVC = [[UINavigationController alloc]initWithRootViewController:[[PersonalViewController alloc]init]];
    self.viewControllers = @[mapVC,traVC,perVC];
    
    NSArray *titleArr = @[@"当前位置", @"行走轨迹", @"个人设置"];
    NSArray *normalImgArr = @[@"iconfont-dingwei",@"iconfont-dituguiji",@"iconfont-shezhi"];
    NSArray *selectedImgArr = @[@"iconfont-dingwei",@"iconfont-dituguiji",@"iconfont-shezhi"];
    
    // 循环设置tabbarItem的文字，图片
    for (int i = 0 ; i < 3; i ++) {
        UIViewController *vc = self.viewControllers[i];
        vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:titleArr[i] image:[UIImage imageNamed:normalImgArr[i]] selectedImage:[[UIImage imageNamed:selectedImgArr[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:27/255.0 green:154/255.0 blue:220/255.0 alpha:1]} forState:UIControlStateSelected];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:10]} forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
