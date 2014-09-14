//
//  Coin.m
//  CoinFinder
//
//  Created by Bennett Lin on 9/11/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Coin.h"

@implementation Coin

@dynamic name;
@dynamic detail;
@dynamic placemark;
@dynamic latitude;
@dynamic longitude;
@dynamic date;

@dynamic photoID;

-(CLLocationCoordinate2D)coordinate {
  return CLLocationCoordinate2DMake([self.latitude floatValue], [self.longitude floatValue]);
}

-(NSString *)title {
  if (self.name.length > 0) {
    return self.name;
  } else {
    return @"";
  }
}

-(NSString *)subtitle {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateStyle:NSDateFormatterShortStyle];
  return [NSString stringWithFormat:@"Found %@", [dateFormatter stringFromDate:self.date]];
}

-(BOOL)hasPhoto {
  return (self.photoID && [self.photoID integerValue] != -1);
}

-(NSString *)documentsDirectory {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths lastObject];
  return documentsDirectory;
}

-(NSString *)photoPath {
  NSString *fileName = [NSString stringWithFormat:@"Photo-%d.jpg", [self.photoID integerValue]];
  return [[self documentsDirectory] stringByAppendingPathComponent:fileName];
}

-(UIImage *)photoImage {
  return [UIImage imageWithContentsOfFile:[self photoPath]];
}

+(NSInteger)nextPhotoID {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSInteger photoID = [defaults integerForKey:@"PhotoID"];
  [defaults setInteger:photoID + 1 forKey:@"PhotoID"];
  [defaults synchronize];
  return photoID;
}

-(void)removePhotoFile {
  NSString *path = [self photoPath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath:path]) {
    NSError *error;
    if (![fileManager removeItemAtPath:path error:&error]) {
    }
  }
}

@end
