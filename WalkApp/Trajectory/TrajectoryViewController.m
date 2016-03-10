//
//  TrajectoryViewController.m
//  WalkApp
//
//  Created by ZDwork on 16/2/18.
//  Copyright © 2016年 ZDwork. All rights reserved.
//

#import "TrajectoryViewController.h"
#import "DataTableViewController.h"
#import "AppDelegate.h"
#import "JTCalendarDay.h"
#import "JTCalendar.h"
#import "AnnoModel.h"
#import <MAMapKit/MAMapKit.h>

@interface TrajectoryViewController ()<JTCalendarDelegate,MAMapViewDelegate,UITabBarControllerDelegate>

@property (nonatomic, strong) JTHorizontalCalendarView      *calendarView;
@property (nonatomic, strong) JTCalendarManager             *calendarManager;
@property (nonatomic, strong) NSDate                        *selectedDate;
@property (nonatomic, strong) NSArray                       *walkArr;
@property (nonatomic, strong) NSMutableArray                *annotations;
@property (nonatomic, strong) MAPolyline                    *polyline;
@property (nonatomic, strong) UIButton                      *rightBtn;
@property (nonatomic, strong) UIButton                      *leftBtn;

@property (nonatomic, strong) MAPointAnnotation *myLocation;
@property (nonatomic, assign) CLLocationCoordinate2D * coords;
@property (nonatomic, assign) NSInteger currentLocationIndex;
@property (nonatomic, assign) BOOL isPlaying;

@end

@implementation TrajectoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.delegate = self;
    self.mapView.frame = CGRectMake(0 , NavHeight + 54 , LFScreenWidth, LFScreenHeight - NavHeight - TabBarHeight - 54);

    self.leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.leftBtn setTitle:@"播放轨迹" forState:UIControlStateNormal];
    self.leftBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.leftBtn sizeToFit];
    [self.leftBtn setTitleColor:[UIColor colorWithRed:30/255.0 green:166/255.0 blue:184/255.0 alpha:1] forState:UIControlStateNormal];
    [self.leftBtn addTarget:self action:@selector(actionPlayAndStop) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.leftBtn];
    
    self.rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.rightBtn setTitle:@"当天数据" forState:UIControlStateNormal];
    self.rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.rightBtn sizeToFit];
    [self.rightBtn setTitleColor:[UIColor colorWithRed:30/255.0 green:166/255.0 blue:184/255.0 alpha:1] forState:UIControlStateNormal];
    [self.rightBtn addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightBtn];
    
    self.mapView.delegate = self;
    self.annotations = [[NSMutableArray alloc]init];
    self.walkArr = [[NSArray alloc]init];
    self.title = @"行走轨迹";
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect rect = self.view.bounds;
    rect.origin.y = NavHeight;
    rect.size.height = 54;
    _calendarView = [[JTHorizontalCalendarView alloc] initWithFrame:rect];
    _calendarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_calendarView];
    
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    _calendarManager.settings.weekModeEnabled = YES;
    [_calendarManager setContentView:_calendarView];
    [self performSelector:@selector(gotoToday) withObject:nil afterDelay:0.01];
    // Do any additional setup after loading the view.
    
    [self loadTodayData];
}

- (void)loadTodayData
{
    //直接获取到当天的数据
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"AnnoModel"];
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    request.predicate = [NSPredicate predicateWithFormat:@"nowDate == %@",dateString];
    self.walkArr = [getAppDelegate().managedObjectContext executeFetchRequest:request error:nil];
    if (self.walkArr.count == 0)
    {
        [self.leftBtn setTitleColor:[UIColor colorWithRed:30/255.0 green:166/255.0 blue:184/255.0 alpha:0.3] forState:UIControlStateNormal];
        self.leftBtn.userInteractionEnabled = NO;
        
        [self.rightBtn setTitleColor:[UIColor colorWithRed:30/255.0 green:166/255.0 blue:184/255.0 alpha:0.3] forState:UIControlStateNormal];
        self.rightBtn.userInteractionEnabled = NO;
    }
    else
    {
        [self processRouteData:self.walkArr];
    }
}

- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    // Today
    if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date])
    {
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor blueColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(self.selectedDate && [_calendarManager.dateHelper date:self.selectedDate isTheSameDayThan:dayView.date])
    {
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor redColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarView.date isTheSameMonthThan:dayView.date])
    {
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else
    {
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    if([dayView.date compare:[NSDate date]] == NSOrderedDescending)
    {
        dayView.userInteractionEnabled = NO;
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    else
    {
        dayView.userInteractionEnabled = YES;
    }
    
    if([self haveEventForDay:dayView.date])
    {
        dayView.dotView.hidden = NO;
    }
    else
    {
        dayView.dotView.hidden = YES;
    }
}

- (BOOL)haveEventForDay:(NSDate *)date
{
    if([date compare:[NSDate date]] == NSOrderedDescending)
    {
        return NO;
    }
    
    
    return NO;
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    self.selectedDate = dayView.date;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:nil];
    
    if(![_calendarManager.dateHelper date:_calendarView.date isTheSameMonthThan:dayView.date] && _calendarManager.settings.weekModeEnabled == NO)
    {
        if([_calendarView.date compare:dayView.date] == NSOrderedAscending)
        {
            [_calendarView loadNextPageWithAnimation];
        }
        else
        {
            [_calendarView loadPreviousPageWithAnimation];
        }
    }
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    if(_selectedDate != nil)
    {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        
        NSString *str1 = [format stringFromDate:_selectedDate];
        NSString *str2 = [format stringFromDate:selectedDate];
        NSLog(@"%@",str2);
        //指定查询条件
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"AnnoModel"];
        //指定查询条件
        request.predicate = [NSPredicate predicateWithFormat:@"nowDate == %@",str2];
        //查询符合条件的所有model，以NSArray返回
        self.walkArr = [getAppDelegate().managedObjectContext executeFetchRequest:request error:nil];
        if (self.walkArr.count == 0)
        {
            [self.leftBtn setTitleColor:[UIColor colorWithRed:30/255.0 green:166/255.0 blue:184/255.0 alpha:0.3] forState:UIControlStateNormal];
            self.leftBtn.userInteractionEnabled = NO;
            
            [self.rightBtn setTitleColor:[UIColor colorWithRed:30/255.0 green:166/255.0 blue:184/255.0 alpha:0.3] forState:UIControlStateNormal];
            self.rightBtn.userInteractionEnabled = NO;
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"当天没有数据", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                return ;
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            [self.leftBtn setTitleColor:[UIColor colorWithRed:30/255.0 green:166/255.0 blue:184/255.0 alpha:1] forState:UIControlStateNormal];
            self.leftBtn.userInteractionEnabled = YES;
            
            [self.rightBtn setTitleColor:[UIColor colorWithRed:30/255.0 green:166/255.0 blue:184/255.0 alpha:1] forState:UIControlStateNormal];
            self.rightBtn.userInteractionEnabled = YES;
        }
        
        if([str1 compare:str2] == NSOrderedSame)
        {
            return;
        }
    }
    _selectedDate = selectedDate;
    [self updateRouteData:self.selectedDate];
}

- (void)updateRouteData:(NSDate *)date
{
    [self.mapView removeAnnotation:self.myLocation];
    [self.mapView removeAnnotations:self.annotations];
    [self.mapView removeOverlay:self.polyline];
    [self.annotations removeAllObjects];
    [self processRouteData:self.walkArr];
    
    MAPointAnnotation *item = [self.annotations lastObject];
    [self.mapView selectAnnotation:item animated:YES];
}

- (void)gotoToday
{
    self.selectedDate = [NSDate date];
    [_calendarView setDate:self.selectedDate];
}

- (void)processRouteData:(id)data
{
    if(self.navigationController.topViewController != self)
    {
        return;
    }
    
    for (NSDictionary *item in data)
    {
        NSNumber *amap_lat = [item valueForKey:@"latitude"];
        NSNumber *amap_lng = [item valueForKey:@"longitude"];
        CLLocationCoordinate2D point = CLLocationCoordinate2DMake([amap_lat doubleValue], [amap_lng doubleValue]);
        
        MAPointAnnotation*anno = [[MAPointAnnotation alloc] init];
        anno.coordinate = point;
        [self.annotations addObject:anno];
    }
    
    /*
     *  增加位置点标注的同时，增加直线overlay
     */
    
    [self.mapView addAnnotations:self.annotations];
    CLLocationCoordinate2D polylineCoords[100];
    NSInteger count = 0;
    for (count = 0; count < [self.annotations count] && count < 100; count++)
    {
        MAPointAnnotation *item = [self.annotations objectAtIndex:count];
        polylineCoords[count].latitude = item.coordinate.latitude;
        polylineCoords[count].longitude = item.coordinate.longitude;
    }
    
    self.polyline = [MAPolyline polylineWithCoordinates:polylineCoords count:count];
    [self.mapView addOverlay:self.polyline];
}

#pragma mark - 标记点和移动的点
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if([annotation isEqual:self.myLocation]) {
        
        static NSString *annotationIdentifier = @"myLcoationIdentifier";
        
        MAAnnotationView *poiAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        }
        
        poiAnnotationView.image = [UIImage imageNamed:@"iconfont-iconxianlufeiji"];
        poiAnnotationView.canShowCallout = NO;
        
        return poiAnnotationView;
    }
    else
    {
        static NSString *userLocationStyleReuseIndetifier = @"TVCID";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:userLocationStyleReuseIndetifier];
        }
        if (annotation == [self.annotations firstObject]) {
            annotationView.image = [UIImage imageNamed:@"iconfont-qidian"];
            annotationView.backgroundColor = [UIColor whiteColor];
            annotationView.layer.cornerRadius = 25.0f;
        }
        else if (annotation == [self.annotations lastObject]) {
            annotationView.image = [UIImage imageNamed:@"iconfont-zhongdian"];
            annotationView.backgroundColor = [UIColor whiteColor];
            annotationView.layer.cornerRadius = 25.0f;
        }
        else
        {
            annotationView.image = [UIImage imageNamed:@"iconfont-xiaoqizi"];
        }
        return annotationView;
    }
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineRenderer.lineWidth   = 5.f;
        polylineRenderer.strokeColor = [UIColor colorWithRed:30/255.0 green:166/255.0 blue:184/255.0 alpha:1];
        
        return polylineRenderer;
    }
    
    return nil;
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
    region.span.latitudeDelta = fmax((topRight.latitude - bottomLeft.latitude) * 1.3, 0.03);
    region.span.longitudeDelta = fmax((topRight.longitude - bottomLeft.longitude) * 1.3, 0.03);
    
    if (self.currentLocationIndex >= 1)
    {
        return;
    }
    [mapView setRegion:region animated:YES];
}

- (void)rightBtnClicked
{
    DataTableViewController *vc = [[DataTableViewController alloc]init];
    vc.dataArr = self.walkArr;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 轨迹平滑移动
- (void)actionPlayAndStop
{
    self.isPlaying = !self.isPlaying;
    NSLog(@"%d",self.isPlaying);
    if (self.isPlaying)
    {
        CLLocationCoordinate2D polylineCoords[100];
        if (self.myLocation == nil)
        {
            self.myLocation = [[MAPointAnnotation alloc] init];
            self.myLocation.title = @"AMap";
            
            NSInteger count = 0;
            self.currentLocationIndex = 1;
            for (count = 0; count < [self.annotations count] && count < 100; count++)
            {
                MAPointAnnotation *item = [self.annotations objectAtIndex:count];
                polylineCoords[count].latitude = item.coordinate.latitude;
                polylineCoords[count].longitude = item.coordinate.longitude;
            }
            self.myLocation.coordinate = polylineCoords[0];
            [self.mapView addAnnotation:self.myLocation];
            [self animateToNextCoordinate];
        }
    }
    else
    {
            [self.mapView removeAnnotation:self.myLocation];
            self.myLocation = nil;
            [self actionPlayAndStop];
    }
}

#pragma mark -循环执行
- (void)animateToNextCoordinate
{
    if (self.myLocation == nil)
    {
        return;
    }
    CLLocationCoordinate2D polylineCoords[100];
    NSInteger count = 0;
    for (count = 0; count < [self.annotations count] && count < 100; count++)
    {
        MAPointAnnotation *item = [self.annotations objectAtIndex:count];
        polylineCoords[count].latitude = item.coordinate.latitude;
        polylineCoords[count].longitude = item.coordinate.longitude;
    }
    CLLocationCoordinate2D nextCoord = polylineCoords[self.currentLocationIndex];
    CLLocationCoordinate2D preCoord = self.currentLocationIndex == 0 ? nextCoord : self.myLocation.coordinate;
    double heading = [self coordinateHeadingFrom:preCoord To:nextCoord];
    //     CLLocationDistance distance = MAMetersBetweenMapPoints(MAMapPointForCoordinate(nextCoord), MAMapPointForCoordinate(preCoord));
    NSTimeInterval duration = 2;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.myLocation.coordinate = nextCoord;
                     }
                     completion:^(BOOL finished){
                         self.currentLocationIndex++;
                         if (finished)
                         {
                             if (self.currentLocationIndex == self.annotations.count) {
                                 NSLog(@"结束");
                                 return ;
                             }
                            [self animateToNextCoordinate];
                         }}];
    MAAnnotationView *view = [self.mapView viewForAnnotation:self.myLocation];
    if (view != nil)
    {
        view.transform = CGAffineTransformMakeRotation((CGFloat)(heading/180.0*M_PI));
    }
}

- (double)coordinateHeadingFrom:(CLLocationCoordinate2D)head To:(CLLocationCoordinate2D)rear
{
    if (!CLLocationCoordinate2DIsValid(head) || !CLLocationCoordinate2DIsValid(rear))
    {
        return 0.0;
    }
    
    double delta_lat_y = rear.latitude - head.latitude;
    double delta_lon_x = rear.longitude - head.longitude;
    
    if (fabs(delta_lat_y) < 0.000001)
    {
        return delta_lon_x < 0.0 ? 270.0 : 90.0;
    }
    
    double heading = atan2(delta_lon_x, delta_lat_y) / M_PI * 180.0;
    
    if (heading < 0.0)
    {
        heading += 360.0;
    }
    return heading;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedIndex == 1)
    {
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateString = [dateFormatter stringFromDate:currentDate];
        if ([[dateFormatter stringFromDate:self.selectedDate] isEqualToString: dateString])
        {
            [self setSelectedDate:currentDate];
        }
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
