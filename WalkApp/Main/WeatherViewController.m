
//
//  WeatherViewController.m
//  WalkApp
//
//  Created by ZDwork on 16/2/27.
//  Copyright © 2016年 ZDwork. All rights reserved.
//

#import "WeatherViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>

@interface WeatherViewController ()<AMapSearchDelegate>
{
    AMapSearchAPI *_search;
}

@property (nonatomic,strong) UILabel *cityLabel;
@property (nonatomic,strong) UILabel *weatLabel;
@property (nonatomic,strong) UILabel *temLabel;
@property (nonatomic,strong) UILabel *otherLabel;

@property (nonatomic,strong) UILabel *tomorrowW;
@property (nonatomic,strong) NSMutableArray *weatherArr;

@end

@implementation WeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.weatherArr = [[NSMutableArray alloc]init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"实时天气";
    [self loadData];
}

- (void)loadData
{
    UIImageView *imag = [[UIImageView alloc] initWithFrame:CGRectMake(0, NavHeight, LFScreenWidth, LFScreenHeight - NavHeight)];
    imag.image = [UIImage imageNamed:@"weather"];
    [self.view addSubview:imag];
    // Do any additional setup after loading the view.
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    
    //构造AMapWeatherSearchRequest对象，配置查询参数
    AMapWeatherSearchRequest *request = [[AMapWeatherSearchRequest alloc] init];
    request.city = self.cityName;
    request.type = AMapWeatherTypeLive; //AMapWeatherTypeLive为实时天气；AMapWeatherTypeForecase为预报天气
    //发起行政区划查询
    [_search AMapWeatherSearch:request];
    
    //预报
    AMapWeatherSearchRequest *request1 = [[AMapWeatherSearchRequest alloc] init];
    request1.city = self.cityName;
    request1.type = AMapWeatherTypeForecast;
    [_search AMapWeatherSearch:request1];
    
    self.cityLabel = [[UILabel alloc]init];
    self.cityLabel.font = [UIFont boldSystemFontOfSize:30];
    self.cityLabel.textColor = [UIColor whiteColor];
    [self.cityLabel sizeToFit];
    [self.view addSubview:self.cityLabel];
    
    self.weatLabel = [[UILabel alloc]init];
    self.weatLabel.font = [UIFont systemFontOfSize:18];
    self.weatLabel.textColor = [UIColor whiteColor];
    [self.weatLabel sizeToFit];
    [self.view addSubview:self.weatLabel];
    
    self.temLabel = [[UILabel alloc]init];
    self.temLabel.font = [UIFont systemFontOfSize:50];
    self.temLabel.textColor = [UIColor whiteColor];
    [self.temLabel sizeToFit];
    [self.view addSubview:self.temLabel];
    
    self.otherLabel = [[UILabel alloc]init];
    self.otherLabel.font = [UIFont systemFontOfSize:20];
    self.otherLabel.textColor = [UIColor whiteColor];
    [self.otherLabel sizeToFit];
    [self.view addSubview:self.otherLabel];
    
    self.tomorrowW = [[UILabel alloc]init];
    self.tomorrowW.textAlignment = NSTextAlignmentCenter;
    self.tomorrowW.textColor = [UIColor grayColor];
    [self.tomorrowW sizeToFit];
    [self.view addSubview:self.tomorrowW];
    
    [self.cityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(100);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.weatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cityLabel.mas_bottom).with.offset(30);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.temLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.weatLabel.mas_bottom).with.offset(50);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.otherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.temLabel.mas_bottom).with.offset(70);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.tomorrowW mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-10);
        make.width.equalTo(self.view.mas_width);
    }];
}

//实现天气查询的回调函数
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response
{
    //如果是实时天气
    if(request.type == AMapWeatherTypeLive)
    {
        if(response.lives.count == 0)
        {
            return;
        }
        for (AMapLocalWeatherLive *live in response.lives) {
            self.cityLabel.text = live.city;
            self.weatLabel.text = live.weather;
            self.temLabel.text = [NSString stringWithFormat:@"%@°",live.temperature];
            self.otherLabel.text = [NSString stringWithFormat:@"%@风  %@级  湿度%@％",live.windDirection,live.windPower,live.humidity];
        }
    }
    //如果是预报天气
    else
    {
        if(response.forecasts.count == 0)
        {
            return;
        }
        for (AMapLocalWeatherForecast *forecast in response.forecasts)
        {
            for (AMapLocalDayWeatherForecast *dayForecast in forecast.casts)
            {
                [self.weatherArr addObject:dayForecast];
            }
        }
        AMapLocalDayWeatherForecast *dayForecast1 = self.weatherArr[1];
        self.tomorrowW.text = [NSString stringWithFormat:@"%@(明天)     星期%@     %@     %@  %@",dayForecast1.date,dayForecast1.week,dayForecast1.dayWeather,dayForecast1.nightTemp,dayForecast1.dayTemp];
    }
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
