//
//  FirstViewController.m
//  DetectorLog
//
//  Created by Bennett Lin on 9/6/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "LocationViewController.h"

@interface LocationViewController () <CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UIButton *tagButton;
@property (nonatomic, weak) IBOutlet UIButton *getButton;

  // location manager
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *latestLocation;
@property (nonatomic) BOOL updatingLocation;

  // reverse geocoder
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) CLPlacemark *latestPlacemark;
@property (nonatomic) BOOL reverseGeocoding;

@end

@implementation LocationViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    self.geocoder = [CLGeocoder new];
  }
  return self;
}
            
-(void)viewDidLoad {
  [super viewDidLoad];

  [self startLocationManager];
  [self updateViews];
}

-(void)updateViews {
  
}

#pragma mark - location manager methods

-(void)getLocation {
  
  if (self.updatingLocation) {
    [self stopLocationManagerWithError:nil];
    
  } else {
    self.latestLocation = nil;
    self.latestPlacemark = nil;
    
    [self startLocationManager];
    [self updateViews];
  }
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
        NSLog(@"Location services are disabled for this app.");
      } else {
        NSLog(@"Error %@", error);
      }
    }
  }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  CLLocation *newLocation = [locations lastObject];
  NSLog(@"did update location %@", newLocation);
  
    // ignore cached results or weird results
  if (newLocation.timestamp.timeIntervalSinceNow < -5.0 ||
      newLocation.horizontalAccuracy < 0) {
    return;
  }
  
  CLLocationDistance distance = CGFLOAT_MAX;
  if (self.latestLocation) {
    distance = [newLocation distanceFromLocation:self.latestLocation];
  }
    
  if (!self.latestLocation || self.latestLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
    self.latestLocation = newLocation;
    [self updateViews];
    
    if (self.latestLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
      NSLog(@"stopping because we're accurate enough");
      [self stopLocationManagerWithError:nil];
    }
    
    if (!self.reverseGeocoding) {
      self.reverseGeocoding = YES;
      
        // perform reverse geocode for each improvement of location
      [self.geocoder reverseGeocodeLocation:self.latestLocation
                          completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"found placemarks %@, error %@", placemarks, error);
        if (!error && placemarks.count > 0) {
          self.latestPlacemark = [placemarks lastObject];
          [self logPlacemark];
        } else {
          self.latestPlacemark = nil;
        }
        self.reverseGeocoding = NO;
        [self updateViews];
      }];
    }
    
  } else if (distance < 1.f) {
    NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:self.latestLocation.timestamp];
    if (timeInterval > 10) {
      
      NSLog(@"force done!");
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
  [self updateViews];
}

#pragma mark - location helper methods

-(void)didTimeOut:(id)object {
  if (!self.latestLocation) {
    [self stopLocationManagerWithError:nil];
  }
  
  [self updateViews];
}

-(void)logPlacemark {
  NSString *placemarkString = [NSString stringWithFormat:@"%@ %@\n%@ %@ %@", self.latestPlacemark.subThoroughfare, self.latestPlacemark.thoroughfare, self.latestPlacemark.locality, self.latestPlacemark.administrativeArea, self.latestPlacemark.postalCode];
  NSLog(@"%@", placemarkString);
}

#pragma mark - system methods

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
