//
//  MapViewController.h
//  CoinFinder
//
//  Created by Bennett Lin on 9/13/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Coin;

@interface MapViewController : UIViewController

@property (strong, nonatomic) Coin *coinToShowInMap;
-(void)centerOnCoin:(Coin *)coin;

@end
