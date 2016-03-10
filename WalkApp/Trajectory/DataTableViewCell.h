//
//  DataTableViewCell.h
//  WalkApp
//
//  Created by ZDwork on 16/2/24.
//  Copyright © 2016年 ZDwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnoModel.h"

@interface DataTableViewCell : UITableViewCell

@property (nonatomic,strong) AnnoModel *model;

- (void)configureCell;

@end
