//
//  DataTableViewCell.m
//  WalkApp
//
//  Created by ZDwork on 16/2/24.
//  Copyright © 2016年 ZDwork. All rights reserved.
//

#import "DataTableViewCell.h"

@interface DataTableViewCell ()

@property (nonatomic, strong) UILabel *latLabel;
@property (nonatomic, strong) UILabel *lonLabel;
@property (nonatomic, strong) UILabel *timLabel;

@end

@implementation DataTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(AnnoModel *)model
{
    _model = model;
    self.latLabel.text = [NSString stringWithFormat:@"lat:%@",model.latitude];
    self.latLabel.textAlignment = NSTextAlignmentLeft;
    self.lonLabel.text = [NSString stringWithFormat:@"lon:%@",model.longitude];
    self.lonLabel.textAlignment = NSTextAlignmentLeft;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm"];
    NSString *dateString = [dateFormatter stringFromDate:model.detailDate];
    self.timLabel.text = dateString;
    self.timLabel.textAlignment = NSTextAlignmentLeft;
}

- (void)configureCell
{
    UIView *superView = self.contentView;
    self.latLabel = [[UILabel alloc]init];
    [superView addSubview:self.latLabel];
    
    self.lonLabel = [[UILabel alloc]init];
    [superView addSubview:self.lonLabel];
    
    self.timLabel = [[UILabel alloc]init];
    [superView addSubview:self.timLabel];
    
    [self.latLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superView.mas_top).with.offset(0);
        make.left.equalTo(superView.mas_left).with.offset(10);
        make.width.equalTo(@150);
        make.height.equalTo(@30);
    }];
    
    [self.lonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superView.mas_top).with.offset(0);
        make.left.equalTo(self.latLabel.mas_right).with.offset(10);
        make.width.equalTo(@150);
        make.height.equalTo(@30);
    }];
    
    [self.timLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.latLabel.mas_bottom).with.offset(0);
        make.left.equalTo(superView.mas_left).with.offset(10);
        make.width.equalTo(@150);
        make.height.equalTo(@30);
    }];
}

@end
