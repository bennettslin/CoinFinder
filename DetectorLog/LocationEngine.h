//
//  FirstViewController.h
//  DetectorLog
//
//  Created by Bennett Lin on 9/6/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationEngineDelegate;

@interface LocationEngine : NSObject

@property (weak, nonatomic) id<LocationEngineDelegate> delegate;
@property (readonly, nonatomic) CLLocation *latestLocation;
@property (readonly, nonatomic) CLPlacemark *latestPlacemark;

-(void)startLocationManager;
-(void)stopLocationManagerWithError:(NSError *)error;
-(BOOL)checkLocationServicesEnabled;

@end

@protocol LocationEngineDelegate <NSObject>

-(void)updateLocationServicesDisabled;
-(void)updateLatitude:(float)latitude longitude:(float)longitude;
-(void)updatePlacemark:(CLPlacemark *)placemark;
-(void)showErrorAlertView:(NSError *)error;

@end

