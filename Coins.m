//
//  Coins.m
//  DetectorLog
//
//  Created by Bennett Lin on 9/10/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Coins.h"
#import "Coin.h"

#define kMyCoinsKey @"coinsKey"

@interface Coins ()

@property (strong, nonatomic) NSMutableArray *myCoins;

@end

@implementation Coins

-(id)init {
  self = [super init];
  if (self) {
    self.myCoins = [NSMutableArray new];
  }
  return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    self.myCoins = [aDecoder decodeObjectForKey:kMyCoinsKey];
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.myCoins forKey:kMyCoinsKey];
}

#pragma mark - my coins methods

-(BOOL)addToMyCoinsThisCoin:(Coin *)addedCoin {

  [self.myCoins addObject:addedCoin];
  return YES;
}

-(BOOL)removeFromMyCoinsThisCoin:(Coin *)removedCoin {
  
  if ([self.myCoins containsObject:removedCoin]) {
    [self.myCoins removeObject:removedCoin];
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - archive methods

+(void)saveCoins:(Coins *)coins {
  [NSKeyedArchiver archiveRootObject:coins toFile:[self getPathToArchive]];
}

+(Coins *)getCoins {
  Coins *coins = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getPathToArchive]];
  return coins ? coins : [[Coins alloc] init];
}

+(NSString *)getPathToArchive {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *directory = [paths objectAtIndex:0];
  NSString *pathString = [directory stringByAppendingPathComponent:@"coins.plist"];
  return pathString;
}

#pragma mark - singleton method

+(Coins *)coins {
  static dispatch_once_t pred;
  static Coins *shared = nil;
  dispatch_once(&pred, ^{
    shared = [[Coins alloc] init];
  });
  return shared;
}

@end
