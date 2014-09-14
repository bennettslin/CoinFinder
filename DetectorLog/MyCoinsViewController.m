//
//  ItemsViewController.m
//  NeighbourRentingApp
//
//  Created by Bennett Lin on 7/6/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "MyCoinsViewController.h"
#import "AppDelegate.h"
#import "MyCoinsViewCell.h"
#import "Constants.h"
#import "UIImage+Resize.h"
//#import "Coins.h"
#import "Coin.h"

@interface MyCoinsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, CollectionViewCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) UILabel *noCoinsLabel;

@end

@implementation MyCoinsViewController

-(NSFetchedResultsController *)instantiateFetchedResultsController {

  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Coin" inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];
  
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
  [fetchRequest setSortDescriptors:@[sortDescriptor]];
  
  [fetchRequest setFetchBatchSize:20];
  
  NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Coins"];

  return fetchedResultsController;
}

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = kColourLightAqua;
  
    // easiest way to get it from appDelegate, don't care what anyone else says, haha
  AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
  self.managedObjectContext = appDelegate.managedObjectContext;
  
  self.fetchedResultsController = [self instantiateFetchedResultsController];
  self.fetchedResultsController.delegate = self;
  
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  self.collectionView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - kTopBarHeight);
  
  self.noCoinsLabel = [[UILabel alloc] init];
  self.noCoinsLabel.text = @" You haven't added any coins! ";
  self.noCoinsLabel.frame = CGRectMake(0, 0, self.view.frame.size.width * 5/6, 100);
  self.noCoinsLabel.adjustsFontSizeToFitWidth = YES;
  self.noCoinsLabel.font = [UIFont fontWithName:kFontCaflisch size:48.f];
  self.noCoinsLabel.textColor = kColourTextBlack;
  self.noCoinsLabel.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height - kTopBarHeight) / 2);
  
  [self.view addSubview:self.noCoinsLabel];
}

-(void)performFetch {
  
    // FIXME: really stupid kludge workaround:
    // I don't know why it needs to delete an object
    // in order to register recently added coins
  Coin *coin = [NSEntityDescription insertNewObjectForEntityForName:@"Coin" inManagedObjectContext:self.managedObjectContext];
  [self.managedObjectContext deleteObject:coin];
  
    //--------------------------------------------------------------------------
  
  NSError *error;
  BOOL fetchedResultsNoError = [self.fetchedResultsController performFetch:&error];
  if (!fetchedResultsNoError) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kManagedObjectContextSaveDidFailNotification object:error];
  }
}

-(void)viewWillAppear:(BOOL)animated {
  
  [self checkIfNoCoins];
}

-(void)checkIfNoCoins {
  
  [self performFetch];
  [self.collectionView reloadData];
  
  if (self.fetchedResultsController.fetchedObjects.count == 0) {
    self.noCoinsLabel.hidden = NO;
  } else {
    self.noCoinsLabel.hidden = YES;
  }
}

#pragma mark - collection view data source and delegate methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

  return self.fetchedResultsController.fetchedObjects.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  MyCoinsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CoinCell" forIndexPath:indexPath];
  
  Coin *coin = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];

  if ([coin hasPhoto]) { // FIXME: eventually check if coin has image
    UIImage *image;
    image = [coin photoImage];
    image = [image resizedImageWithBounds:CGSizeMake(150, 150)];
    cell.imageView.image = image;
    cell.imageView.layer.cornerRadius = 75.f;
    cell.imageView.clipsToBounds = YES;
    
  } else {
    cell.imageView.image = [UIImage imageNamed:@"placeholder_coin"];
    cell.imageView.layer.cornerRadius = 0.f;
  }
  
  cell.myCoin = coin;
  cell.titleLabel.text = coin.name;
  cell.titleLabel.adjustsFontSizeToFitWidth = YES;
  [cell.deleteButton setImage:[UIImage imageNamed:@"delete_icon"] forState:UIControlStateNormal];
  
  if (![coin.latitude isEqual:@(MAXFLOAT)] && ![coin.longitude isEqual:@(MAXFLOAT)]) {
    cell.mapButton.hidden = NO;
    cell.mapButton.enabled = YES;
    [cell.mapButton setImage:[UIImage imageNamed:@"map_icon"] forState:UIControlStateNormal];
  } else {
    cell.mapButton.hidden = YES;
    cell.mapButton.enabled = NO;
  }
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateStyle:NSDateFormatterShortStyle];
  cell.dateLabel.text = [NSString stringWithFormat:@"Found %@", [dateFormatter stringFromDate:coin.date]];
  cell.dateLabel.adjustsFontSizeToFitWidth = YES;
  
  cell.delegate = self;
  
  return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  
  Coin *coin = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
  NSMutableDictionary *coinInfo = [NSMutableDictionary dictionary];
  [coinInfo setObject:coin forKey:@"coin"];
  
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter postNotificationName:@"editCoin" object:self userInfo:coinInfo];
}

#pragma mark - NSFetchedResultsController delegate methods

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  
  [self performFetch];
  [self.collectionView reloadData];
}

#pragma mark - collection view cell delegate methods

-(void)deleteCoin:(Coin *)myCoin {

  [myCoin removePhotoFile];
  [self.managedObjectContext deleteObject:myCoin];
  
  NSError *error;
  if (![self.managedObjectContext save:&error]) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kManagedObjectContextSaveDidFailNotification object:error];
    abort();
  }
  
  [self checkIfNoCoins];
}

#pragma mark - system methods

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
