//
//  Coin.m
//  DetectorLog
//
//  Created by Bennett Lin on 9/10/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Coin.h"

@interface Coin ()

@end

@implementation Coin

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    self.title = [aDecoder decodeObjectForKey:@"title"];
    self.image = [aDecoder decodeObjectForKey:@"image"];
    self.detail = [aDecoder decodeObjectForKey:@"detail"];
    self.placemark = [aDecoder decodeObjectForKey:@"placemark"];
    self.location = [aDecoder decodeObjectForKey:@"location"];
    self.date = [aDecoder decodeObjectForKey:@"date"];
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.title forKey:@"title"];
  [aCoder encodeObject:self.image forKey:@"image"];
  [aCoder encodeObject:self.detail forKey:@"detail"];
  [aCoder encodeObject:self.placemark forKey:@"placemark"];
  [aCoder encodeObject:self.location forKey:@"location"];
  [aCoder encodeObject:self.date forKey:@"date"];
}

-(NSString *)placemarkString {
  return [NSString stringWithFormat:@"%@ %@\n%@ %@ %@",
          self.placemark.subThoroughfare,
          self.placemark.thoroughfare,
          self.placemark.locality,
          self.placemark.administrativeArea,
          self.placemark.postalCode];
}

@end
