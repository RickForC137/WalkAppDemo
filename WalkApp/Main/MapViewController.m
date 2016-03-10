//
//  MapViewController.m
//  WalkApp
//
//  Created by ZDwork on 16/2/18.
//  Copyright © 2016年 ZDwork. All rights reserved.
//

#import "MapViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>

#define NavHeight 64
#define TabBarHeight 49

@interface MapViewController ()

@property (nonatomic,strong) UIButton *changeBtn;
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,assign) int times;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //配置用户Key
    [MAMapServices sharedServices].apiKey = @"db9408a8996f7e1644c9ae266ff21779";
    [AMapSearchServices sharedServices].apiKey = @"db9408a8996f7e1644c9ae266ff21779";
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, NavHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-NavHeight-TabBarHeight)];
    [self.view addSubview:_mapView];
    
    // Do any additional setup after loading the view, typically from a nib.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
