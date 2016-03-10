//
//  LocationCacheDataModal.m
//  YuCloud
//
//  Created by 熊国锋 on 16/1/4.
//  Copyright © 2016年 VIROYAL-ELEC. All rights reserved.
//

#import "LocationCacheDataModal.h"
#import "ObjectProcessor.h"
#import "AppDelegate.h"
#import "YuCloudQueueManager.h"


@implementation LocationData

- (instancetype)initWithLocation:(CLLocationCoordinate2D)point address:(NSString *)address poi:(NSString *)poi
{
    if(self = [super init])
    {
        self.key = [LocationCacheDataModal keyForLocation:point];
        self.address = address;
        self.poi = poi;
    }
    
    return self;
}

- (instancetype)initWithKey:(NSString *)key address:(NSString *)address poi:(NSString *)poi
{
    if(self = [super init])
    {
        self.key = key;
        self.address = address;
        self.poi = poi;
    }
    
    return self;
}

@end

@interface LocationReGeoObject : NSObject

@property (nonatomic, strong) NSString                      *key;
@property (nonatomic, copy) LocationCacheCompletionHandler  completionHandler;

@end

@implementation LocationReGeoObject


@end


@interface LocationCacheDataModal () < ObjectProcessDelegate, AMapSearchDelegate >

@property (nonatomic, strong) ObjectProcessor           *Objprocessor;
@property (nonatomic, strong) AMapSearchAPI             *mapSearch;
@property (nonatomic, strong) NSMutableDictionary       *reGeoDic;

@end

@implementation LocationCacheDataModal

+ (LocationCacheDataModal *)sharedClient
{
    static LocationCacheDataModal *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[LocationCacheDataModal alloc] init];
    });
    
    return _sharedClient;
}

- (instancetype)init
{
    if(self = [super init])
    {
        [[ObjectProcessor sharedOperationQueue] addOperation:self.Objprocessor];
    }
    
    return self;
}

- (ObjectProcessor *)Objprocessor
{
    if(_Objprocessor == nil)
    {
        _Objprocessor = [[ObjectProcessor alloc] init];
        
        _Objprocessor.delegate = self;
        _Objprocessor.persistentStoreCoordinator = self.managedObjectContext.persistentStoreCoordinator;
    }
    
    return _Objprocessor;
}

- (NSManagedObjectContext *)managedObjectContext
{
    AppDelegate *app = getAppDelegate();
    return app.managedObjectContext;
}

- (void)editDidSave:(NSNotification *)saveNotification
{
    if([NSThread isMainThread])
    {
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(editDidSave:) withObject:saveNotification waitUntilDone:NO];
    }
}

- (void)addObject:(LocationData *)data
{
    [self.Objprocessor performSelector:@selector(addObject:)
                              onThread:self.Objprocessor.thread
                            withObject:data
                         waitUntilDone:NO];
}

- (void)clearLocationData
{
    [self.Objprocessor performSelector:@selector(clearDataForEntity:)
                              onThread:self.Objprocessor.thread
                            withObject:@{@"entity" : @"LocationInfo"}
                         waitUntilDone:NO];
}

+ (NSString *)keyForLocation:(CLLocationCoordinate2D)location
{
    NSString *string = [NSString stringWithFormat:@"%.12f-%.12f", location.latitude, location.longitude];
    return string;
}

- (LocationData *)dataForLocation:(CLLocationCoordinate2D)location
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LocationInfo"];
    NSString *key = [LocationCacheDataModal keyForLocation:location];
    [request setPredicate:[NSPredicate predicateWithFormat:@"key == %@", key]];
    
    NSSortDescriptor *dayDescriptor = [[NSSortDescriptor alloc] initWithKey:@"address" ascending:NO];
    NSArray *sortDescriptors = @[dayDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:nil];
    if([objects count])
    {
        LocationInfo *item = [objects firstObject];
        LocationData *data = [[LocationData alloc] initWithKey:item.key address:item.address poi:item.poi];
        return data;
    }
    
    return nil;
}

- (AMapSearchAPI *)mapSearch
{
    if(_mapSearch == nil)
    {
        _mapSearch = [[AMapSearchAPI alloc] init];
        [_mapSearch setDelegate:self];
    }
    
    return _mapSearch;
}

- (NSMutableDictionary *)reGeoDic
{
    if(_reGeoDic == nil)
    {
        _reGeoDic = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    return _reGeoDic;
}

- (void)ReGeocodeLocation:(CLLocationCoordinate2D)location block:(void (^)(BOOL, LocationData * _Nullable))block
{
    LocationData *data = [self dataForLocation:location];
    if(data)
    {
        if(block)
        {
            block(YES, data);
        }
    }
    else if(location.latitude == 0 && location.longitude == 0)
    {
        if(block)
        {
            block(NO, nil);
        }
    }
    else
    {
        WEAK(self, wself);
        dispatch_queue_t queue = [YuCloudQueueManager map_related_queue];
        dispatch_async(queue, ^{
            STRONG(wself, sself);
            NSString *key = [LocationCacheDataModal keyForLocation:location];
            for (LocationReGeoObject *item in [sself.reGeoDic allValues])
            {
                if([item.key isEqualToString:key])
                {
                    //已经在请求网络解析中，直接结束本次请求
                    return;
                }
            }
            
            AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
            regeo.location = [AMapGeoPoint locationWithLatitude:location.latitude longitude:location.longitude];
            regeo.radius = 1000;
            regeo.requireExtension = YES;
            
            NSString *reqAdd = [NSString stringWithFormat:@"%p", regeo];
            LocationReGeoObject *object = [[LocationReGeoObject alloc] init];
            object.key = key;
            object.completionHandler = block;
            [sself.reGeoDic setObject:object forKey:reqAdd];
            
            [sself.mapSearch AMapReGoecodeSearch:regeo];
        });
    }
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    NSString *reqAdd = [NSString stringWithFormat:@"%p", request];
    LocationReGeoObject *object = [self.reGeoDic objectForKey:reqAdd];
    if(object)
    {
        [self.reGeoDic removeObjectForKey:reqAdd];
    }
    else
    {
        return;
    }
    
    NSString *key = object.key;
    LocationCacheCompletionHandler block = object.completionHandler;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([response.regeocode.formattedAddress length] > 0)
        {
            NSArray *pois = response.regeocode.pois;
            if([pois count] > 0)
            {
                AMapPOI *poi = [pois firstObject];
                NSString *strPoi = poi.name;
                NSString *strAddress;
                
                AMapAddressComponent *com = response.regeocode.addressComponent;
                strAddress = [NSString stringWithFormat:@"%@%@%@%@", com.province, com.city, com.district, com.township];
                NSString *prefix = getAppDelegate().addressPre;
                if([prefix length])
                {
                    strAddress = [strAddress stringByReplacingOccurrencesOfString:prefix withString:@""];
                }
                
                LocationData *data = [[LocationData alloc] initWithKey:key address:strAddress poi:strPoi];
                [[LocationCacheDataModal sharedClient] addObject:data];
                
                if(block)
                {
                    block(YES, data);
                }
            }
            else
            {
                LocationData *data = [[LocationData alloc] initWithKey:key address:response.regeocode.formattedAddress poi:nil];
                [[LocationCacheDataModal sharedClient] addObject:data];
                
                if(block)
                {
                    block(YES, data);
                }
            }
        }
        else
        {
            if(block)
            {
                block(NO, nil);
            }
        }
    });
}

@end

