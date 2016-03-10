//
//  LocalSearchViewController.m
//  WalkApp
//
//  Created by ZDwork on 16/2/29.
//  Copyright © 2016年 ZDwork. All rights reserved.
//

#import "LocalSearchViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>

#define searchH  40

@interface LocalSearchViewController ()<AMapSearchDelegate,MAMapViewDelegate>
{
    AMapSearchAPI *_search;
}
@property (nonatomic, strong) NSMutableArray                *annotations;
@property (nonatomic, strong) UITextField                   *searchTF;
@property (nonatomic,assign) float nowX;
@property (nonatomic,assign) float nowY;

@end

@implementation LocalSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"周边搜索";
    self.mapView.frame = CGRectMake(0, NavHeight+searchH, LFScreenWidth, LFScreenHeight-NavHeight-searchH);
    self.mapView.delegate = self;
    
    self.mapView.showsUserLocation = YES;    //YES 为打开定位，NO为关闭定位
    
    self.annotations = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
    [self loadData];
}

- (void)loadData
{
    // 创建搜索栏
    _searchTF = [[UITextField alloc]initWithFrame:CGRectMake(0, 64, LFScreenWidth-searchH, searchH)];
    _searchTF.placeholder = @"搜索地点";
    _searchTF.font = [UIFont systemFontOfSize:13.0f];
    _searchTF.borderStyle = UITextBorderStyleRoundedRect;
    _searchTF.backgroundColor = [UIColor whiteColor];
    _searchTF.textAlignment = NSTextAlignmentCenter;
    UIButton *searchBtn = [[UIButton alloc]init];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:searchBtn];
    [self.view addSubview:_searchTF];
    
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_searchTF.mas_right).with.offset(0);
        make.width.equalTo(@(searchH));
        make.height.equalTo(@(searchH));
        make.top.equalTo(self.view.mas_top).with.offset(64);
    }];
}

- (void)search
{
    [_searchTF resignFirstResponder];
    if (_searchTF.text.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"输入不能为空", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    //构造AMapPOIAroundSearchRequest对象，设置周边请求参数
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    self.nowX = [[userDefault objectForKey:@"nowX"] floatValue];
    self.nowY = [[userDefault objectForKey:@"nowY"] floatValue];
    request.location = [AMapGeoPoint locationWithLatitude:self.nowX longitude:self.nowY];
    request.keywords = _searchTF.text;
    request.types = @"餐饮服务|商务住宅|生活服务";
    request.radius = 1000;
    request.sortrule = 0;
    request.requireExtension = YES;
    
    //发起周边搜索
    [_search AMapPOIAroundSearch: request];
}

//实现POI搜索对应的回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"未搜索到相关地点", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    //通过 AMapPOISearchResponse 对象处理搜索结果
    for (AMapPOI *p in response.pois) {
        CLLocationCoordinate2D point = CLLocationCoordinate2DMake(p.location.latitude, p.location.longitude);
        MAPointAnnotation*anno = [[MAPointAnnotation alloc] init];
        anno.coordinate = point;
        [self.annotations addObject:anno];
    }
    [self.mapView addAnnotations:self.annotations];
    [self.mapView showAnnotations:self.annotations animated:YES];
    self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
}

#pragma mark -自动将所有点移动到适合屏幕的范围内
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    /*
     *  位置标记完成之后，自动将所有点移动到适合屏幕的范围内
     */
    MACoordinateRegion region = mapView.region;
    CLLocationCoordinate2D topRight = CLLocationCoordinate2DMake(-10000, -10000);
    CLLocationCoordinate2D bottomLeft = CLLocationCoordinate2DMake(10000, 10000);
    for (MAPinAnnotationView *view in views)
    {
        CLLocationCoordinate2D coordinate = view.annotation.coordinate;
        if(coordinate.latitude > topRight.latitude)
        {
            topRight.latitude = coordinate.latitude;
        }
        if(coordinate.longitude > topRight.longitude)
        {
            topRight.longitude = coordinate.longitude;
        }
        
        if(coordinate.latitude < bottomLeft.latitude)
        {
            bottomLeft.latitude = coordinate.latitude;
        }
        if(coordinate.longitude < bottomLeft.longitude)
        {
            bottomLeft.longitude = coordinate.longitude;
        }
    }
    
    region.center = CLLocationCoordinate2DMake(bottomLeft.latitude + (topRight.latitude - bottomLeft.latitude) / 2.0, bottomLeft.longitude + (topRight.longitude - bottomLeft.longitude) / 2.0);
    region.span.latitudeDelta = fmax((topRight.latitude - bottomLeft.latitude) * 1.3, 0.01);
    region.span.longitudeDelta = fmax((topRight.longitude - bottomLeft.longitude) * 1.3, 0.01);
    
    [mapView setRegion:region animated:YES];
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
