//
//  Coins.h
//  DetectorLog
//
//  Created by Bennett Lin on 9/10/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Coin;

@interface Coins : NSObject <NSCoding>

@property (readonly, nonatomic) NSMutableArray *myCoins;

+(void)saveCoins:(Coins *)coins;
+(Coins *)getCoins;

-(BOOL)addToMyCoinsThisCoin:(Coin *)addedCoin;
-(BOOL)removeFromMyCoinsThisCoin:(Coin *)removedCoin;

@end
