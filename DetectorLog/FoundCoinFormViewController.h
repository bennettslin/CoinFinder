//
//  PickerFormViewController.h
//  NeighbourRentingApp
//
//  Created by Bennett Lin on 6/22/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Coin;
@class IndentedTextField;

@protocol FoundCoinFormDelegate;

@interface FoundCoinFormViewController : UIViewController

@property (strong, nonatomic) Coin *myCoin;

@property (weak, nonatomic) IBOutlet IndentedTextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *detailField;
@property (weak, nonatomic) IBOutlet IndentedTextField *placemarkField;
@property (weak, nonatomic) id<FoundCoinFormDelegate> delegate;

-(void)updatePickedImage:(UIImage *)pickedImage;
-(UIView *)checkFirstResponder;
-(void)checkIfAddOrEdit;

@end

@protocol FoundCoinFormDelegate <NSObject>

-(BOOL)firstTime;
-(void)keyboardDidShow:(NSNotification *)notification;

@end