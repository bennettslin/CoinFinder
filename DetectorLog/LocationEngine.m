//
//  FirstViewController.m
//  DetectorLog
//
//  Created by Bennett Lin on 9/6/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "LocationEngine.h"

@interface LocationEngine () <CLLocationManagerDelegate>

  // location manager
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *latestLocation;
@property (nonatomic) BOOL updatingLocation;

  // reverse geocoder
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) CLPlacemark *latestPlacemark;
@property (nonatomic) BOOL reverseGeocoding;

@end

@implementation LocationEngine

-(id)init {
  if (self = [super init]) {
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    self.geocoder = [CLGeocoder new];
  }
  return self;
}

#pragma mark - location manager methods

-(void)getLocation {
  
  if (self.updatingLocation) {
    [self stopLocationManagerWithError:nil];
    
  } else {
    self.latestLocation = nil;
    self.latestPlacemark = nil;
    
    [self startLocationManager];
  }
}

-(BOOL)checkLocationServicesEnabled {
  
  return [CLLocationManager locationServicesEnabled] &&
      [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied;
}

-(void)startLocationManager {
  if ([CLLocationManager locationServicesEnabled]) {
    self.updatingLocation = YES;
    [self.locationManager startUpdatingLocation];
    
    [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60.f];
  }
}

-(void)stopLocationManagerWithError:(NSError *)error {
  if (self.updatingLocation) {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
    
    [self.locationManager stopUpdatingLocation];
    self.updatingLocation = NO;
    
    if (error) {
      if (([error.domain isEqualToString:kCLErrorDomain] && error.code == kCLErrorDenied) ||
          ![CLLocationManager locationServicesEnabled]) {
        [self.delegate showErrorAlertView:error];
        [self.delegate updateLocationServicesDisabled];
      } else {
        [self.delegate showErrorAlertView:error];
      }
    }
  }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  CLLocation *newLocation = [locations lastObject];
  
    // ignore cached results or weird results
  if (newLocation.timestamp.timeIntervalSinceNow < -5.0 ||
      newLocation.horizontalAccuracy < 0) {
    return;
  }
  
  CLLocationDistance distance = MAXFLOAT;
  if (self.latestLocation) {
    distance = [newLocation distanceFromLocation:self.latestLocation];
  }
    
  if (!self.latestLocation || self.latestLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
    self.latestLocation = newLocation;
    [self.delegate updateLatitude:self.latestLocation.coordinate.latitude
                        longitude:self.latestLocation.coordinate.longitude];
    
    if (self.latestLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
      [self stopLocationManagerWithError:nil];
    }
    
    if (!self.reverseGeocoding) {
      self.reverseGeocoding = YES;
      
        // perform reverse geocode for each improvement of location
      [self.geocoder reverseGeocodeLocation:self.latestLocation
                          completionHandler:^(NSArray *placemarks, NSError *error) {

        if (!error && placemarks.count > 0) {
          self.latestPlacemark = [placemarks lastObject];
        } else {
          self.latestPlacemark = nil;
        }
                            
        self.reverseGeocoding = NO;
        [self.delegate updatePlacemark:self.latestPlacemark];
      }];
    }
    
  } else if (distance < 1.f) {
    NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:self.latestLocation.timestamp];
    if (timeInterval > 10) {

      [self stopLocationManagerWithError:nil];
    }
  }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  
    // unable to obtain a location now, return and keep trying
  if (error.code == kCLErrorLocationUnknown) {
    return;
  }
  
  [self stopLocationManagerWithError:error];
  [self.delegate updateLatitude:MAXFLOAT longitude:MAXFLOAT];
  [self.delegate updatePlacemark:nil];
}

#pragma mark - location helper methods

-(void)didTimeOut:(id)object {
  if (!self.latestLocation) {
    [self stopLocationManagerWithError:nil];
  }
}

#pragma mark - singleton method

+(LocationEngine *)locationEngine {
  static dispatch_once_t pred;
  static LocationEngine *shared = nil;
  dispatch_once(&pred, ^{
    shared = [[LocationEngine alloc] init];
  });
  return shared;
}

@end
