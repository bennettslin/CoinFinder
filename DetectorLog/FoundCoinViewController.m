//
//  PickerViewController.m
//  NeighbourRentingApp
//
//  Created by Bennett Lin on 6/22/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "FoundCoinViewController.h"
#import "FoundCoinFormViewController.h"
#import "Constants.h"
#import "IndentedTextField.h"

#define kImagePadding 10.f
//#define kScrollBottomMargin 116.f // change this value

#define kImageFrameWidth (self.view.frame.size.width * 3/4)

@interface FoundCoinViewController () <FoundCoinFormDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) FoundCoinFormViewController *foundCoinFormVC;

@end

@implementation FoundCoinViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = kColourLightAqua;
  
  self.scrollView = [[UIScrollView alloc] init];
  self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width,
                                     self.view.frame.size.height - kTopBarHeight);
  [self.view addSubview:self.scrollView];
  self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 560); // hard-coded value is from storyboard
  [self presentForm];
  
//  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardDidShow:(NSNotification *)notification {
  
  CGFloat yOffset = 0;
  
    // FIXME: hard-coded values for now
  UIView *firstResponderView = [self.foundCoinFormVC checkFirstResponder];
  if (firstResponderView == self.foundCoinFormVC.titleField) {
    yOffset = 10.f;
  } else if (firstResponderView == self.foundCoinFormVC.detailField) {
    yOffset = 100.f;
  } else if (firstResponderView == self.foundCoinFormVC.placemarkField) {
    yOffset = 216.f;
  }
  
  [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
      // keyboard height is 216
    self.foundCoinFormVC.view.frame = CGRectMake(0, -yOffset, self.view.frame.size.width, 560);
  } completion:^(BOOL finished) {
  
  }];
}

-(void)keyboardDidHide:(NSNotification *)notification {
  [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    
    self.foundCoinFormVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 560);
  } completion:^(BOOL finished) {
    
  }];

}

-(void)viewWillAppear:(BOOL)animated {
  if (self.myCoin) {
    self.foundCoinFormVC.myCoin = self.myCoin;
  }
}

-(void)presentForm {
  self.foundCoinFormVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FoundCoinFormVC"];
  self.foundCoinFormVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 560);
  self.foundCoinFormVC.delegate = self;
  
  [self.scrollView addSubview:self.foundCoinFormVC.view];
  [self addChildViewController:self.foundCoinFormVC];
  [self.foundCoinFormVC didMoveToParentViewController:self];
}

-(BOOL)firstTime {
  return self.postingNewCoinForFirstTime;
}

#pragma mark - system

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
