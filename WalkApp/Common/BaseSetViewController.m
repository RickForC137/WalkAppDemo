//
//  BaseSetViewController.m
//  WalkApp
//
//  Created by ZDwork on 16/2/25.
//  Copyright © 2016年 ZDwork. All rights reserved.
//

#import "BaseSetViewController.h"

@interface BaseSetViewController ()

@property (nonatomic,strong) UILabel *leastLabel;
@property (nonatomic,strong) UILabel *mostLabel;
@property (nonatomic,strong) UISlider *leastSlider;
@property (nonatomic,strong) UISlider *mostSlider;

@property (nonatomic,strong) NSString *leastStr;
@property (nonatomic,strong) NSString *mostStr;
@property (nonatomic,assign) float lVaue1;
@property (nonatomic,assign) float lValue2;
@property (nonatomic,assign) float mValue1;
@property (nonatomic,assign) float mValue2;

@property (nonatomic,assign) NSInteger row;

@end

@implementation BaseSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self loadData];
}

- (void)loadData
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    float leastMeter = 0;
    float mostMeter = 0;
    float leastMin = 0;
    if (self.row == 1)
    {
        leastMeter = [[userDefault objectForKey:@"leastMeter"] floatValue];
        mostMeter = [[userDefault objectForKey:@"mostMeter"] floatValue];
    }
    else{
        leastMin = [[userDefault objectForKey:@"leastMin"] floatValue];
    }
    
    UIBarButtonItem *okBtn = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(okBtnClicked)];
    self.navigationItem.rightBarButtonItem = okBtn;
    
    self.leastLabel = [[UILabel alloc]init];
    self.leastLabel.text = self.leastStr;
    self.leastLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.leastLabel];
    
    self.leastSlider = [[UISlider alloc] init];
    self.leastSlider.minimumValue = self.lVaue1;
    self.leastSlider.maximumValue = self.lValue2;
    [self.leastSlider addTarget:self action:@selector(leastSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.leastSlider];

    self.mostSlider = [[UISlider alloc] init];
    if (self.row == 2) {
        self.mostSlider.alpha = 0;
    }
    self.mostSlider.minimumValue = self.mValue1;
    self.mostSlider.maximumValue = self.mValue2;
    [self.mostSlider addTarget:self action:@selector(mostSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.mostSlider];
    
    self.mostLabel = [[UILabel alloc]init];
    if (self.row == 2) {
        self.mostLabel.alpha = 0;
    }
    self.mostLabel.text = self.mostStr;
    self.mostLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.mostLabel];
    
    [self.leastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).with.offset(85);
        make.width.equalTo(@(LFScreenWidth));
        make.height.equalTo(@40);
    }];
    
    [self.leastSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.leastLabel.mas_bottom).with.offset(30);
        make.width.equalTo(@200);
        make.height.equalTo(@50);
    }];
    
    [self.mostLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.leastSlider.mas_bottom).with.offset(50);
        make.width.equalTo(@(LFScreenWidth));
        make.height.equalTo(@40);
    }];
    
    [self.mostSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.mostLabel.mas_bottom).with.offset(30);
        make.width.equalTo(@200);
        make.height.equalTo(@50);
    }];
    
    if (self.row == 1) {
        self.leastSlider.value = leastMeter;
        self.mostSlider.value = mostMeter;
        self.leastLabel.text = [NSString stringWithFormat:@"%@:%.0f米",self.leastStr,self.leastSlider.value];
        self.mostLabel.text = [NSString stringWithFormat:@"%@:%.0f米",self.mostStr,self.mostSlider.value];
    }
    else
    {
        self.leastSlider.value = leastMin;
        self.leastLabel.text = [NSString stringWithFormat:@"%@:%.0f分",self.leastStr,self.leastSlider.value];
    }
}

- (void)setLeastStr:(NSString *)leastStr andMostStr:(NSString *)mostStr andLeastValue1:(float)Lvalue1 value2:(float)Lvalue2 andMostValue1:(float)Mvalue1 value2:(float)Mvalue2 indexRow:(NSInteger)row
{
    self.leastStr = leastStr;
    self.mostStr = mostStr;
    self.lVaue1 =Lvalue1;
    self.lValue2 = Lvalue2;
    self.mValue1 = Mvalue1;
    self.mValue2 = Mvalue2;
    self.row = row;
}

- (void)leastSliderValueChanged:(UISlider *)slider
{
    if (self.row == 1)
    {
        self.leastLabel.text = [NSString stringWithFormat:@"%@:%.0f米",self.leastStr,slider.value];
    }
    else
    {
        self.leastLabel.text = [NSString stringWithFormat:@"%@:%.0f分",self.leastStr,slider.value];
    }
    
}

- (void)mostSliderValueChanged:(UISlider *)slider
{
    if (self.row == 1)
    {
        self.mostLabel.text = [NSString stringWithFormat:@"%@:%.0f米",self.mostStr,slider.value];
    }
}

- (void)okBtnClicked
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.row == 1)
    {
        [userDefaults setObject:[NSNumber numberWithFloat:self.leastSlider.value] forKey:@"leastMeter"];
        [userDefaults setObject:[NSNumber numberWithFloat:self.mostSlider.value] forKey:@"mostMeter"];
    }
    else
    {
        [userDefaults setObject:[NSNumber numberWithFloat:self.leastSlider.value] forKey:@"leastMin"];
    }
    [userDefaults synchronize];
    [self.navigationController popViewControllerAnimated:YES];
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
