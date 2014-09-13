//
//  ItemViewCell.h
//  NeighbourRentingApp
//
//  Created by Bennett Lin on 7/6/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Coin;

@protocol CollectionViewCellDelegate;

@interface MyCoinsViewCell : UICollectionViewCell

@property (weak, nonatomic) id<CollectionViewCellDelegate> delegate;

@property (strong, nonatomic) Coin *myCoin;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@protocol CollectionViewCellDelegate <NSObject>

-(void)deleteCoin:(Coin *)myCoin;

@end