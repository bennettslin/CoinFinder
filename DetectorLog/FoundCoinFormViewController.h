//
//  PickerFormViewController.h
//  NeighbourRentingApp
//
//  Created by Bennett Lin on 6/22/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Coin;

@interface FoundCoinFormViewController : UIViewController

@property (strong, nonatomic) Coin *myCoin;

-(void)updatePickedImage:(UIImage *)pickedImage;

@end
