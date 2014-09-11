//
//  ItemsViewController.m
//  NeighbourRentingApp
//
//  Created by Bennett Lin on 7/6/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "MyCoinsViewController.h"
#import "MyCoinsViewCell.h"
#import "Coins.h"
#import "Coin.h"

@interface MyCoinsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MyCoinsViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retrieveCoins:) name:@"sendCoins" object:nil];
  
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  self.collectionView.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
}

-(void)viewWillAppear:(BOOL)animated {
    // post notification to get user from mainVC
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter postNotificationName:@"presentCoins" object:self userInfo:nil];
}

#pragma mark - collection view data source and delegate methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.myCoins.myCoins.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  MyCoinsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CoinCell" forIndexPath:indexPath];
  
  Coin *coin = self.myCoins.myCoins[indexPath.row];
  cell.imageView.image = coin.image;
  cell.titleLabel.text = coin.title;
  cell.dateLabel.text = coin.date.description;
  return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  
  Coin *coin = self.myCoins.myCoins[indexPath.row];
  NSMutableDictionary *coinInfo = [NSMutableDictionary dictionary];
  [coinInfo setObject:coin forKey:@"coin"];
  
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter postNotificationName:@"editCoin" object:self userInfo:coinInfo];
}

#pragma mark - NSNotification methods

-(void)retrieveCoins:(NSNotification *)notification {
  if ([notification.name isEqualToString:@"sendCoins"]) {
    NSDictionary *coinsInfo = notification.userInfo;
    self.myCoins = [coinsInfo objectForKey:@"coins"];
    [self.collectionView reloadData];
  }
}

#pragma mark - system methods

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
