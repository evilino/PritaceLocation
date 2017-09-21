//
//  XSZSLoadPosition.m
//  PritaceLocation
//
//  Created by 孙晓康 on 2017/9/4.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "XSZSLoadPosition.h"

@interface XSZSLoadPosition ()<CLLocationManagerDelegate>

//定位
@property (nonatomic, strong)CLLocationManager *locationManager;

//地理位置反编码
@property (nonatomic, strong)CLGeocoder *geocode;

@property (nonatomic, copy)void(^locationBlock)(CLLocation *location);

@property (nonatomic, copy)void(^locationArroundBlock)(CLLocation *location);

@end


@implementation XSZSLoadPosition


- (instancetype)init {
    
    if (self = [super init]) {
        
        [_locationManager requestWhenInUseAuthorization];
        
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        _geocode = [[CLGeocoder alloc] init];
    }
    
    return self;
}

- (void)LoadCurrentPosition {
    
    [self startSetLocalManger];
    
    __weak XSZSLoadPosition* weakSelf = self;
    self.locationBlock = ^(CLLocation *location) {
   
         [weakSelf loadLocationWithGenCode:location];
    };
    
   
}

- (void)LoadCurrentPositionArrountWithKeyStr:(NSString *)keyStr {
    
    [self startSetLocalManger];
    
    __weak XSZSLoadPosition* weakSelf = self;
    self.locationArroundBlock = ^(CLLocation *location) {
    
        [weakSelf fetchNearbyInfoWithLocation:location KeyStr:keyStr];
    };
}



#pragma mark -- 开启定位服务，获取用户当前位置信息
- (void)startSetLocalManger{
    //判断用户定位服务是否开启
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status)  {
        
        //不能定位用户的位置
        //1.提醒用户检查当前的网络状况
        //2.提醒用户打开定位开关
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在设备的'设置-隐私-定位服务'中允许访问定位。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alert show];
        
    }else {
        
        
        //每隔多少米定位一次（这里的设置为任何的移动）
        CLLocationDistance distance = 1.0;//十米定位一次
        _locationManager.distanceFilter = distance;
        //设置定位的精准度，一般精准度越高，越耗电（这里设置为精准度最高的，适用于导航应用）
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        //2.设置代理
        _locationManager.delegate = self;
        if ([[UIDevice currentDevice].systemVersion integerValue] >= 8.0) {
            [_locationManager requestWhenInUseAuthorization];//使用程序其间允许访问位置数据（iOS8定位需要）
        }
        //开始定位用户的位置
        [_locationManager startUpdatingLocation];
        
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *loc = [locations firstObject];
    
    if (self.locationBlock) {
        
        self.locationBlock(loc);
    }
    
    if (self.locationArroundBlock) {
        
        self.locationArroundBlock(loc);
    }
    
    //获取成功，停止定位服务
    [_locationManager stopUpdatingLocation];
    
}


- (void)loadLocationWithGenCode:(CLLocation *)location {
    
    [_geocode reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (error == nil && placemarks.count > 0) {
            
            CLPlacemark *place = [placemarks lastObject];
            
            if ([self.positionDelegate respondsToSelector:@selector(loadCurrentPositionWithPosition:ProvincePositon:)]) {
                
                [self.positionDelegate loadCurrentPositionWithPosition:place.name ProvincePositon:[place.addressDictionary[@"FormattedAddressLines"] lastObject]];
            }
        }else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取地理位置信息失败，请手动输入。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            [alert show];
        }
        
    }];
    
}


- (void)fetchNearbyInfoWithLocation:(CLLocation *)location KeyStr:(NSString *)keyStr{
    
    
    MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(location.coordinate, 100 ,100);
    
    MKLocalSearchRequest *requst = [[MKLocalSearchRequest alloc] init];
    requst.region = region;
    requst.naturalLanguageQuery = keyStr; //想要的信息
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:requst];
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        if (!error) {
            
            
            if ([self.positionDelegate respondsToSelector:@selector(loadCurrentArroundPosition:)]) {
                
                [self.positionDelegate loadCurrentArroundPosition:response];
            }
            
        }else{
            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取附近地理位置信息失败，请手动输入。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            
//            [alert show];
        }
    }];
    
}




@end
