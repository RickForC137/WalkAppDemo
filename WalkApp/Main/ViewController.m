//
//  ViewController.m
//  WalkApp
//
//  Created by ZDwork on 16/2/18.
//  Copyright © 2016年 ZDwork. All rights reserved.
//

#import "ViewController.h"
#import "MapViewController.h"
#import "WeatherViewController.h"
#import "AppDelegate.h"
#import "AnnoModel.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "WXApi.h"

@interface ViewController ()<MAMapViewDelegate,AMapSearchDelegate>
{
    AMapSearchAPI *_search;
}
@property (nonatomic,strong) UIButton *rightBtn;
@property (nonatomic,strong) UIButton *leftBtn;
@property (nonatomic,strong) UIButton *locationBtn;
@property (nonatomic, strong) UIImage *imageLocated;
@property (nonatomic, strong) UIImage *imageNotLocate;
@property (nonatomic,strong) UIButton *changeBtn;
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,assign) int times;
@property (nonatomic,assign) MAMapPoint beforePoint;
@property (nonatomic,assign) BOOL isFirst;
@property (nonatomic,assign) BOOL isStartFirst;
@property (nonatomic,strong) NSArray *walkArr;
@property (nonatomic,strong) NSString *startTime;
@property (nonatomic,strong) NSManagedObjectContext *context;

@property (nonatomic,assign) float leastMeter;
@property (nonatomic,assign) float mostMeter;
@property (nonatomic,assign) float leastMin;
@property (nonatomic,assign) float nowX;
@property (nonatomic,assign) float nowY;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.leftBtn setTitle:@"实时天气" forState:UIControlStateNormal];
    self.leftBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.leftBtn sizeToFit];
    [self.leftBtn setTitleColor:[UIColor colorWithRed:30/255.0 green:166/255.0 blue:184/255.0 alpha:1] forState:UIControlStateNormal];
    [self.leftBtn addTarget:self action:@selector(leftBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.leftBtn];
    
    self.rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.rightBtn setTitle:@"分享位置" forState:UIControlStateNormal];
    self.rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.rightBtn sizeToFit];
    [self.rightBtn setTitleColor:[UIColor colorWithRed:30/255.0 green:166/255.0 blue:184/255.0 alpha:1] forState:UIControlStateNormal];
    [self.rightBtn addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightBtn];
    
    BOOL isInstall = [WXApi isWXAppInstalled];
    if (isInstall == NO)
    {
        [self.rightBtn setTitleColor:[UIColor colorWithRed:30/255.0 green:166/255.0 blue:184/255.0 alpha:0] forState:UIControlStateNormal];
    }
    else
    {
        [self.rightBtn setTitleColor:[UIColor colorWithRed:30/255.0 green:166/255.0 blue:184/255.0 alpha:1] forState:UIControlStateNormal];
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    self.leastMeter = [[userDefault objectForKey:@"leastMeter"] floatValue];
    self.mostMeter = [[userDefault objectForKey:@"mostMeter"] floatValue];
    self.leastMin = [[userDefault objectForKey:@"leastMin"] floatValue];
    
    if (self.leastMeter == 0) {
        self.leastMeter = 50;
        [userDefault setObject:[NSNumber numberWithFloat:self.leastMeter] forKey:@"leastMeter"];
    }
    if (self.mostMeter == 0) {
        self.mostMeter = 1000;
        [userDefault setObject:[NSNumber numberWithFloat:self.mostMeter] forKey:@"mostMeter"];
    }
    if (self.leastMin == 0) {
        self.leastMin = 3;
        [userDefault setObject:[NSNumber numberWithFloat:self.leastMin] forKey:@"leastMin"];
    }
    
    self.walkArr = [[NSArray alloc]init];
    self.isFirst = YES;
    self.isStartFirst = YES;
    _times = 1;
    self.title = @"当前位置";
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;    //YES 为打开定位，NO为关闭定位
//    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    
    self.mapView.pausesLocationUpdatesAutomatically = NO;
    self.mapView.allowsBackgroundLocationUpdates = YES;//iOS9以上系统必须配置
    [self initLocationButton];
    [self loadData];
}

- (void)initLocationButton
{
    self.imageLocated = [UIImage imageNamed:@"location_11"];
    self.imageNotLocate = [UIImage imageNamed:@"location_22"];
    
    self.locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.bounds)*0.8, 50, 50)];
    self.locationBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.locationBtn.backgroundColor = [UIColor whiteColor];
    self.locationBtn.layer.cornerRadius = 5;
    [self.locationBtn addTarget:self action:@selector(actionLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
    
    [self.view addSubview:self.locationBtn];
}

#pragma mark - locationBtn的点击方法
- (void)actionLocation
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *number = [userDefault objectForKey:@"type"];
    if (number == nil) {
        number = 0;
    }
    int a = [number intValue];
    //更改地图模式
    switch (a) {
        case 0:
            self.mapView.mapType = MAMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MAMapTypeSatellite;
            break;
//        case 2:
//            self.mapView.mapType = MAMapTypeStandardNight;
//            break;
        default:
            break;
    }
    
    if (self.mapView.userTrackingMode == MAUserTrackingModeFollowWithHeading)
    {
        [self.mapView setUserTrackingMode:MAUserTrackingModeNone];
    }
    else
    {
        [self.mapView setUserTrackingMode:MAUserTrackingModeFollowWithHeading];
    }
}

- (void)loadData
{
    _label = [[UILabel alloc]init];
    _label.backgroundColor = [UIColor whiteColor];
    _label.alpha = 0.5;
    _label.numberOfLines = 2;
    [_label sizeToFit];
    [self.view addSubview:_label];
    
    [_changeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@100);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-69);
    }];
    
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).with.offset(70);
    }];
}

- (void)mapView:(MAMapView *)mapView  didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MAUserTrackingModeNone)
    {
        [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
    }
    else
    {
        [self.locationBtn setImage:self.imageLocated forState:UIControlStateNormal];
        [self.mapView setZoomLevel:16 animated:YES];
    }
}

#pragma mark - 更新当前位置信息并保存符合条件的数据
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"AnnoModel"];
    self.walkArr = [getAppDelegate().managedObjectContext executeFetchRequest:request error:nil];
    if (self.walkArr.count != 0)
    {
        self.isFirst = NO;
    }
    //第一次启动
    if(updatingLocation)
    {
        CGFloat x = userLocation.coordinate.latitude;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        self.nowX = x;
        [userDefault setObject:[NSNumber numberWithFloat:self.nowX] forKey:@"nowX"];
        CGFloat y = userLocation.coordinate.longitude;
        self.nowY = y;
        [userDefault setObject:[NSNumber numberWithFloat:self.nowY] forKey:@"nowY"];
        //第一次获取数据
        if (self.isFirst == YES)
        {
            self.beforePoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(x,y));
            NSString *  locationString=[self getCurrentTime];
            NSLog(@"locationString:%@",locationString);
        }
        //当前点
        MAMapPoint nowPoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(x,y));
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date1 = [formatter dateFromString:self.startTime];
        NSDate *date2 = [NSDate date];
        NSTimeInterval aTimer = [date2 timeIntervalSinceDate:date1];
        //计算时间
        int hour = (int)(aTimer/3600);
        int minute = (int)(aTimer - hour*3600)/60;
//        int second = aTimer - hour*3600 - minute*60;
        //计算距离
        CLLocationDistance distance = MAMetersBetweenMapPoints(nowPoint,self.beforePoint);
        if (self.isStartFirst == YES)
        {
            [self getCurrentTime];
        }
//        NSLog(@"distance:%f",distance);
        //满足条件则获得该数据(默认每隔2分钟且距离超过50米或者距离超过1000米都会保存数据)
        if (((minute >=self.leastMin || distance >= self.mostMeter) && distance >= self.leastMeter)|| self.isFirst == YES)
        {
            if (self.isStartFirst == YES && self.isFirst == NO)
            {
                self.isStartFirst = NO;
                self.beforePoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(x,y));
                return;
            }
            AnnoModel *model = [NSEntityDescription insertNewObjectForEntityForName:@"AnnoModel" inManagedObjectContext:getAppDelegate().managedObjectContext];
            NSString *strX = [NSString stringWithFormat:@"%f",userLocation.coordinate.latitude];
            NSString *strY = [NSString stringWithFormat:@"%f",userLocation.coordinate.longitude];
            model.latitude = strX;
            model.longitude = strY;
            NSDate *currentDate = [NSDate date];
            model.detailDate = currentDate;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *dateString = [dateFormatter stringFromDate:currentDate];
            model.nowDate = dateString;
            
            NSError *error;
            if(![getAppDelegate().managedObjectContext save:&error])
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"添加失败", nil) preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSLog(@"error:%@",error);
                }];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else
            {
                NSString *str = [NSString stringWithFormat:@"当前有%lu个数据",(unsigned long)self.walkArr.count+1];
                NSLog(@"%@",str);
            }
            [self getCurrentTime];
             self.beforePoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(x,y));
        }
        self.isFirst = NO;
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    /* 自定义userLocation对应的annotationView. */
    if ([annotation isKindOfClass:[MAUserLocation class]])
    {
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:userLocationStyleReuseIndetifier];
        }
        annotationView.image = [UIImage imageNamed:@"location_no"];
        return annotationView;
    }
    return nil;
}

#pragma mark - 获取当前时间
-(NSString *)getCurrentTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    self.startTime = dateTime;
    return self.startTime;
}

#pragma mark - 分享当前位置
- (void)rightBtnClicked
{
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    
    //构造AMapPOIShareSearchRequest对象
    AMapPOIShareSearchRequest *request = [[AMapPOIShareSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:self.nowX longitude:self.nowY];
    request.name = @"我的位置";
    request.address = @"我的当前地点";
    
    //发起POI分享查询
    [_search AMapPOIShareSearch:request];
}

#pragma mark - 实时天气
- (void)leftBtnClicked
{
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    //构造AMapReGeocodeSearchRequest对象
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:self.nowX longitude:self.nowY];
    regeo.radius = 10000;
    regeo.requireExtension = YES;
    //发起逆地理编码
    [_search AMapReGoecodeSearch: regeo];
}

#pragma mark - 实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if(response.regeocode != nil)
    {
        WeatherViewController *vc = [[WeatherViewController alloc]init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.cityName = response.regeocode.addressComponent.city;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 实现短串分享回调函数
- (void)onShareSearchDone:(AMapShareSearchBaseRequest *)request response:(AMapShareSearchResponse *)response
{
    NSLog(@"share response: shareURL = %@", response.shareURL);
    BOOL isInstall = [WXApi isWXAppInstalled];
    if (isInstall == NO)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"未安装微信", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"我的位置";
    [message setThumbImage:[UIImage imageNamed:@"map"]];
    
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = response.shareURL;
    message.mediaObject = webpageObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    [WXApi sendReq:req];
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
