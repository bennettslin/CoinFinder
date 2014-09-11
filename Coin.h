//
//  Coin.h
//  DetectorLog
//
//  Created by Bennett Lin on 9/10/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface Coin : NSObject <NSCoding>

  // user editable
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *detail;
@property (strong, nonatomic) CLPlacemark *placemark;

  // user not editable
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSDate *date;

-(NSString *)placemarkString;

@end
