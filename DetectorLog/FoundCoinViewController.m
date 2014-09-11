//
//  PickerViewController.m
//  NeighbourRentingApp
//
//  Created by Bennett Lin on 6/22/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "FoundCoinViewController.h"
#import "FoundCoinFormViewController.h"

#define kImagePadding 10.f
#define kScrollBottomMargin 116.f // change this value
#define kImageFrameWidth (self.view.frame.size.width * 3/4)

@interface FoundCoinViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) FoundCoinFormViewController *foundCoinFormVC;

@end

@implementation FoundCoinViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  self.scrollView = [[UIScrollView alloc] init];
  self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width,
                                     self.view.frame.size.height - kScrollBottomMargin);
  [self.view addSubview:self.scrollView];
  self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 600.f); // was 420.f hard coded value
  [self presentForm];
}

-(void)viewWillAppear:(BOOL)animated {
  if (self.myCoin) {
    self.foundCoinFormVC.myCoin = self.myCoin;
  }
}

-(void)presentForm {
  self.foundCoinFormVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FoundCoinFormVC"];
  self.foundCoinFormVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 600.f);
//  self.foundCoinFormVC.view.layer.cornerRadius = 10.f;
//  self.foundCoinFormVC.view.clipsToBounds = YES;
  
  [self.scrollView addSubview:self.foundCoinFormVC.view];
  [self addChildViewController:self.foundCoinFormVC];
  [self.foundCoinFormVC didMoveToParentViewController:self];
}

#pragma mark - system

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
