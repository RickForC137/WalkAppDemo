//
//  AnnoModel.h
//  WalkApp
//
//  Created by ZDwork on 16/2/22.
//  Copyright © 2016年 ZDwork. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface AnnoModel : NSManagedObject

@property (nonatomic,strong) NSString *latitude;
@property (nonatomic,strong) NSString *longitude;
@property (nonatomic,strong) NSString *nowDate;
@property (nonatomic,strong) NSDate   *detailDate;

@end
