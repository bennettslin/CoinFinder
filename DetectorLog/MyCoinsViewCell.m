//
//  ItemViewCell.m
//  NeighbourRentingApp
//
//  Created by Bennett Lin on 7/6/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "MyCoinsViewCell.h"

@interface MyCoinsViewCell () <UIActionSheetDelegate>

@end

@implementation MyCoinsViewCell

-(IBAction)deleteButtonTapped:(id)sender {
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this coin?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil, nil];
  [actionSheet showInView:self];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    NSLog(@"delete button pressed");
    [self.delegate deleteCoin:self.myCoin];
  }
}

@end