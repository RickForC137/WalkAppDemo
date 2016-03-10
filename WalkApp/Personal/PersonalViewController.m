//
//  PersonalViewController.m
//  WalkApp
//
//  Created by ZDwork on 16/2/18.
//  Copyright © 2016年 ZDwork. All rights reserved.
//

#import "PersonalViewController.h"
#import "MapTypeViewController.h"
#import "BaseSetViewController.h"
#import "LocalSearchViewController.h"

#define LEAST_DISTANCE_VALUE_ONE    20   //最少间隔距离value
#define LEAST_DISTANCE_VALUE_TWO    100
#define MOST_DISTANCE_VALUE_ONE     500  //最大间隔距离value
#define MOST_DISTANCE_VALUE_TWO     2000
#define LEAST_TIME_VALUE_ONE        2    //最小间隔时间value
#define LEAST_TIME_VALUE_TWO        10


@interface PersonalViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSArray *dataArray;

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation PersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSArray arrayWithObjects:@"当前地图模式",@"记录间隔距离",@"记录间隔时间",@"周边搜索", nil];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"个人设置";
    // Do any additional setup after loading the view.
    [self loadData];
}

- (void)loadData
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, LFScreenWidth, LFScreenHeight) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"PVCID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row)
    {
        case 0:
        {
            MapTypeViewController *vc = [[MapTypeViewController alloc]init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            BaseSetViewController *vc = [[BaseSetViewController alloc]init];
            vc.hidesBottomBarWhenPushed = YES;
            [vc setLeastStr:@"最小间隔距离" andMostStr:@"最大间隔距离" andLeastValue1:LEAST_DISTANCE_VALUE_ONE value2:LEAST_DISTANCE_VALUE_TWO andMostValue1:MOST_DISTANCE_VALUE_ONE value2:MOST_DISTANCE_VALUE_TWO indexRow:indexPath.row];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            BaseSetViewController *vc = [[BaseSetViewController alloc]init];
            vc.hidesBottomBarWhenPushed = YES;
            [vc setLeastStr:@"最小间隔时间" andMostStr:nil andLeastValue1:LEAST_TIME_VALUE_ONE value2:LEAST_TIME_VALUE_TWO andMostValue1:0 value2:1 indexRow:indexPath.row];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
//            FenchViewController *vc = [[FenchViewController alloc]init];
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
            LocalSearchViewController *vc = [[LocalSearchViewController alloc]init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        case 4:
        {
            
        }
            break;
        default:
            break;
            
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
