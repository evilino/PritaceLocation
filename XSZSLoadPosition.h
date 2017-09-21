//
//  XSZSLoadPosition.h
//  PritaceLocation
//
//  Created by 孙晓康 on 2017/9/4.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@protocol XSZSLoadPositionDelegate <NSObject>
@optional
- (void)loadCurrentPositionWithPosition:(NSString *)position ProvincePositon:(NSString *)provincePosition;

- (void)loadCurrentArroundPosition:(MKLocalSearchResponse *)response;

@end


@interface XSZSLoadPosition : NSObject

- (instancetype)init;

+ (instancetype)sharedPosition;

//获取当前位置
- (void)LoadCurrentPosition;

//获取周边信息
- (void)LoadCurrentPositionArrountWithKeyStr:(NSString *)keyStr;


@property (nonatomic, weak)id<XSZSLoadPositionDelegate> positionDelegate;

@end
