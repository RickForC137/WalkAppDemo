//
//  MapTypeViewController.m
//  WalkApp
//
//  Created by ZDwork on 16/2/25.
//  Copyright © 2016年 ZDwork. All rights reserved.
//

#import "MapTypeViewController.h"

@interface MapTypeViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *typeArr;
@property (nonatomic,strong) NSString *soundStr;
@property (nonatomic,strong) NSIndexPath *selectedIndexPath;
@property (nonatomic,strong) NSNumber *number;

@end

@implementation MapTypeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"地图模式";
    self.view.backgroundColor = [UIColor whiteColor];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *number = [userDefault objectForKey:@"type"];
    self.number = number;
    [self createUI];
}

- (void)createUI
{
    _typeArr = @[@"标准模式",@"卫星模式"];
    _soundStr = [[NSString alloc]init];
    UIBarButtonItem *okBtn = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(okBtnClicked)];
    self.navigationItem.rightBarButtonItem = okBtn;
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, LFScreenWidth, LFScreenHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    UILabel *label = [[UILabel alloc]init];
    label.numberOfLines = 0;
    label.text = @"提示：地图模式设置完成之后，需点击首页的定位按钮完成刷新。";
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).with.offset(50);
        make.right.equalTo(self.view.mas_right).with.offset(-50);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-50);
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.equalTo(@50);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _typeArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"soundID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",_typeArr[indexPath.row]];
    if ([NSNumber numberWithInteger:indexPath.row] == self.number)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _selectedIndexPath = indexPath;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - 地图模式的切换
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedIndexPath)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:_selectedIndexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.number = [NSNumber numberWithInteger:indexPath.row];
    _soundStr = _typeArr[indexPath.row];
    _selectedIndexPath = indexPath;
}

#pragma mark - 数据存储
- (void)okBtnClicked
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.number forKey:@"type"];
    [userDefaults synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
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
