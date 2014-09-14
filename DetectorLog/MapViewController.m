//
//  MapViewController.m
//  CoinFinder
//
//  Created by Bennett Lin on 9/13/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Constants.h"
#import "Coin.h"

#define kRegionLength 250.f

@interface MapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIButton *coinsButton;
@property (weak, nonatomic) IBOutlet UIButton *userButton;

@property (strong, nonatomic) NSArray *coins;

@property (assign, nonatomic) BOOL firstTimeGettingUserLocation;

@end

@implementation MapViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  const CGFloat coinsButtonLength = 54;
  const CGFloat userButtonLength = 72;
  const CGFloat padding = 24;
  
  [self.coinsButton setImage:[UIImage imageNamed:@"coins_icon"] forState:UIControlStateNormal];
  [self.userButton setImage:[UIImage imageNamed:@"user_icon"] forState:UIControlStateNormal];
  self.coinsButton.frame = CGRectMake(padding, self.view.frame.size.height - coinsButtonLength - kTopBarHeight - padding * 1.5, coinsButtonLength, coinsButtonLength);
  self.userButton.frame = CGRectMake(self.view.frame.size.width - userButtonLength - padding + ((userButtonLength - coinsButtonLength) / 2), self.view.frame.size.height - ((coinsButtonLength + userButtonLength) / 2) - kTopBarHeight - padding * 1.5, userButtonLength, userButtonLength);
  
  BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled] &&
  [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied;
  
  UIView *leftButtonBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, userButtonLength, userButtonLength)];
  UIView *rightButtonBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, userButtonLength, userButtonLength)];
  leftButtonBackground.center = self.coinsButton.center;
  rightButtonBackground.center = self.userButton.center;
  leftButtonBackground.backgroundColor = kColourDarkAqua;
  rightButtonBackground.backgroundColor = kColourDarkAqua;
  [self.view insertSubview:leftButtonBackground belowSubview:self.coinsButton];
  [self.view insertSubview:rightButtonBackground belowSubview:self.userButton];
  leftButtonBackground.layer.cornerRadius = 5.f;
  leftButtonBackground.clipsToBounds = YES;
  rightButtonBackground.layer.cornerRadius = 5.f;
  rightButtonBackground.layer.masksToBounds = YES;
  
  if (!locationServicesEnabled) {
    self.userButton.enabled = NO;
    self.userButton.hidden = YES;
    rightButtonBackground.alpha = 0.f;
  } else {
    self.userButton.enabled = YES;
    self.userButton.hidden = NO;
    rightButtonBackground.alpha = 1.f;
  }
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableScroll) name:@"enableMapScroll" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableScroll) name:@"disableMapScroll" object:nil];
  
// easiest way to get it from appDelegate, don't care what anyone else says, haha
  AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
  self.managedObjectContext = appDelegate.managedObjectContext;
  
  self.mapView.delegate = self;
  [self updateCoins];
  
  if (!self.coinToShowInMap) {
    [self showCoinsAnimated:NO];
  } else {
    [self centerOnCoin:self.coinToShowInMap];
  }
}

-(void)viewWillAppear:(BOOL)animated {
  self.firstTimeGettingUserLocation = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
  self.coinToShowInMap = nil;
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
  if (self.firstTimeGettingUserLocation && !self.coinToShowInMap) {
    [self showCoinsAnimated:YES];
    self.firstTimeGettingUserLocation = NO;
  }
}

-(void)enableScroll {
  self.mapView.scrollEnabled = YES;
}

-(void)disableScroll {
  self.mapView.scrollEnabled = NO;
}

-(IBAction)showUser:(id)sender {
  
  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, kRegionLength, kRegionLength);
  
  [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

-(IBAction)showCoins:(id)sender {
  [self showCoinsAnimated:YES];
}

-(void)showCoinsAnimated:(BOOL)animated {
  MKCoordinateRegion region = [self regionForAnnotations:self.coins];
  
  [self.mapView setRegion:region animated:animated];
}

-(void)updateCoins {
  
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Coin" inManagedObjectContext:self.managedObjectContext];
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  [fetchRequest setEntity:entity];
  
  NSError *error;
  NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  if (!foundObjects) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kManagedObjectContextSaveDidFailNotification object:error];
    abort();
  }
  
  if (self.coins) {
    [self.mapView removeAnnotations:self.coins];
  }
  
  self.coins = foundObjects;
  [self.mapView addAnnotations:self.coins];
}


  // not DRY
-(void)centerOnCoin:(Coin *)coin {
  MKCoordinateRegion region;
  id <MKAnnotation> annotation = coin;
  region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, kRegionLength, kRegionLength);
  [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

-(MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations {
  
  NSMutableArray *tempArray = [NSMutableArray new];
  
  for (id object in annotations) {
    id <MKAnnotation> annotation = object;
    if (annotation.coordinate.latitude != MAXFLOAT &&
        annotation.coordinate.longitude != MAXFLOAT) {
      
      [tempArray addObject:annotation];
    };
  }
  
  NSArray *annotationArray = [NSArray arrayWithArray:tempArray];
  
  MKCoordinateRegion region;
  
  if (annotationArray.count == 0) {
    region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, kRegionLength, kRegionLength);
    
  } else if (annotationArray.count == 1) {
    id <MKAnnotation> annotation = [annotationArray lastObject];
    region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, kRegionLength, kRegionLength);
    
  } else {
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for (id<MKAnnotation> annotation in annotationArray) {
      topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
      topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
      bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
      bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
    }
    const double extraSpace = 1.25;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2.0;
    region.center.longitude = topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2.0;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace;
    region.span.longitudeDelta = fabs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace;
  }
  return [self.mapView regionThatFits:region];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  if ([annotation isKindOfClass:[Coin class]]) {
    static NSString *identifier = @"Coin";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!annotationView) {
      annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
      annotationView.enabled = YES;
      annotationView.canShowCallout = YES;
      annotationView.animatesDrop = YES;
      annotationView.pinColor = MKPinAnnotationColorGreen;
      
      UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
      [rightButton addTarget:self action:@selector(showCoinDetails:) forControlEvents:UIControlEventTouchUpInside];
      annotationView.rightCalloutAccessoryView = rightButton;
    } else {
      annotationView.annotation = annotation;
    }
    
    UIButton *button = (UIButton *)annotationView.rightCalloutAccessoryView;
    button.tag = [self.coins indexOfObject:(Coin *)annotation];
    return annotationView;
  }
  return nil;
}

-(void)showCoinDetails:(UIButton *)button {
  Coin *coin = [self.coins objectAtIndex:button.tag];
  NSMutableDictionary *coinInfo = [NSMutableDictionary dictionary];
  [coinInfo setObject:coin forKey:@"coin"];
  
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter postNotificationName:@"editCoin" object:self userInfo:coinInfo];
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
