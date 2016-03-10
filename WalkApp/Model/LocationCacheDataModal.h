//
//  LocationCacheDataModal.h
//  YuCloud
//
//  Created by 熊国锋 on 16/1/4.
//  Copyright © 2016年 VIROYAL-ELEC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationInfo.h"
#import <AMapSearchKit/AMapSearchKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationData : NSObject

@property (nonatomic, strong) NSString                  *poi;
@property (nonatomic, strong) NSString                  *address;
@property (nonatomic, strong) NSString                  *key;

- (instancetype)initWithLocation:(CLLocationCoordinate2D)point address:(NSString *)address poi:(NSString *)poi;
- (instancetype)initWithKey:(NSString *)key address:(NSString *)address poi:(nullable NSString *)poi;

@end

typedef void (^LocationCacheCompletionHandler)(BOOL success, LocationData * _Nullable data);

@interface LocationCacheDataModal : NSObject


+ (LocationCacheDataModal *)sharedClient;

- (void)addObject:(LocationData *)data;
- (void)clearLocationData;

+ (NSString *)keyForLocation:(CLLocationCoordinate2D)location;
- (LocationData *)dataForLocation:(CLLocationCoordinate2D)location;

- (void)ReGeocodeLocation:(CLLocationCoordinate2D)location block:(void (^)(BOOL success,  LocationData * _Nullable data))block;



@end

NS_ASSUME_NONNULL_END

