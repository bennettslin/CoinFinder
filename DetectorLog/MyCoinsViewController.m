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
#import "Coins.h"
#import "Coin.h"

@interface MyCoinsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, CollectionViewCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation MyCoinsViewController

-(NSFetchedResultsController *)instantiateFetchedResultsController {
  
//  if (!_fetchedResultsController) {
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Coin" inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];
  
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
  [fetchRequest setSortDescriptors:@[sortDescriptor]];
  
  [fetchRequest setFetchBatchSize:20];
  
  NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Coins"];
//  }
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
  self.collectionView.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
}

-(void)performFetch {
  NSError *error;
  if (![self.fetchedResultsController performFetch:&error]) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kManagedObjectContextSaveDidFailNotification object:error];
  }
}

-(void)viewWillAppear:(BOOL)animated {
  
  NSLog(@"coins view will appear, perform fetch");
  [self performFetch];
  [self.collectionView reloadData];
}

#pragma mark - collection view data source and delegate methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

  NSLog(@"fetched objects count is %i", self.fetchedResultsController.fetchedObjects.count);
  return self.fetchedResultsController.fetchedObjects.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  MyCoinsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CoinCell" forIndexPath:indexPath];
  
  Coin *coin = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];

  if (FALSE) { // FIXME: eventually check if coin has image
    //  cell.imageView.image = coin.image;
  } else {
    cell.imageView.image = [UIImage imageNamed:@"placeholder_coin"];
  }
  
  cell.myCoin = coin;
  cell.titleLabel.text = coin.title;
  cell.titleLabel.adjustsFontSizeToFitWidth = YES;
  [cell.deleteButton setImage:[UIImage imageNamed:@"delete_icon"] forState:UIControlStateNormal];
  
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

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//  [self.collectionView reloadData];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
  switch (type) {
    case NSFetchedResultsChangeInsert:
      NSLog(@"insert");
//      [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
      break;
    case NSFetchedResultsChangeDelete:
      NSLog(@"delete");
//      [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
      break;
    case NSFetchedResultsChangeUpdate:
      NSLog(@"update");
//      [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
      break;
    case NSFetchedResultsChangeMove:
      NSLog(@"change move");
//      [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
//      [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
      break;
    default:
      break;
  }
  [self.collectionView reloadData];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
  switch (type) {
    case NSFetchedResultsChangeInsert:
//      NSLog(@"controller insert");
//      [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
      break;
    case NSFetchedResultsChangeDelete:
//      NSLog(@"controller delete");
//      [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
      break;
    default:
      break;
  }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  
  NSLog(@"controller did change content");
  
  [self performFetch];
  [self.collectionView reloadData];
}

#pragma mark - collection view cell delegate methods

-(void)deleteCoin:(Coin *)myCoin {
  
  NSLog(@"delete coin method called");
  [self.managedObjectContext deleteObject:myCoin];
  
  NSError *error;
  if (![self.managedObjectContext save:&error]) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kManagedObjectContextSaveDidFailNotification object:error];
    abort();
  }
}

#pragma mark - system methods

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
