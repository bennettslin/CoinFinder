//
//  Coin.h
//  CoinFinder
//
//  Created by Bennett Lin on 9/11/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class CLPlacemark;

@interface Coin : NSManagedObject <MKAnnotation>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *detail;
@property (nonatomic, retain) CLPlacemark *placemark;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSDate *date;

@property (nonatomic, retain) NSNumber *photoID;

+(NSInteger)nextPhotoID;
-(BOOL)hasPhoto;
-(NSString *)photoPath;
-(UIImage *)photoImage;
-(void)removePhotoFile;

@end
