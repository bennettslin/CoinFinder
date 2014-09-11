//
//  PickerFormViewController.m
//  NeighbourRentingApp
//
//  Created by Bennett Lin on 6/22/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "FoundCoinFormViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Coin.h"

@interface FoundCoinFormViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *addOrChangePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *postCoinButton;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *detailField;
@property (weak, nonatomic) IBOutlet UITextField *placemarkField;

@property (weak, nonatomic) IBOutlet UILabel *coordinateLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;

  // pointers and bools
@property (nonatomic) NSUInteger sourceType;
@property (nonatomic) BOOL postingCoinForFirstTime;

@end

@implementation FoundCoinFormViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.titleField.delegate = self;
  self.detailField.delegate = self;
  
  self.imageView.contentMode = UIViewContentModeScaleAspectFit;
  self.imageView.layer.cornerRadius = 10.f;
  self.imageView.clipsToBounds = YES;
  
    // FIXME: need other method to determine if posting or editing
    // check whether posting or editing
  _postingCoinForFirstTime = self.myCoin ? NO : YES;
}

-(void)viewWillAppear:(BOOL)animated {
  
    // adding coin
  if (!self.myCoin) {
    self.myCoin = [[Coin alloc] init];
    [self updatePickedImage:nil];
    
      // editing coin
  } else {
    [self updatePickedImage:self.myCoin.image];
    self.titleField.text = self.myCoin.title;
    self.detailField.text = self.myCoin.detail;
    self.placemarkField.text = [self.myCoin placemarkString];
    self.coordinateLabel.text = [NSString stringWithFormat:@"latitude %.5f, longitude %.5f", self.myCoin.location.coordinate.latitude, self.myCoin.location.coordinate.longitude];
    self.postDateLabel.text = [NSString stringWithFormat:@"found on %@", self.myCoin.date];
    NSLog(@"%@, %@", self.coordinateLabel.text, self.postDateLabel.text);
  }
  
  NSString *buttonText = _postingCoinForFirstTime ? @"Add this coin" : @"Save changes";
  [self.postCoinButton setTitle:buttonText forState:UIControlStateNormal];
}

-(void)updatePickedImage:(UIImage *)pickedImage {
  
  if (pickedImage) {
    self.imageView.image = pickedImage;
    [self.addOrChangePhotoButton setTitle:@"Change photo" forState:UIControlStateNormal];
    
  } else {
    [self.addOrChangePhotoButton setTitle:@"Add photo" forState:UIControlStateNormal];
    // FIXME: present default background image if no picked image
    self.imageView.backgroundColor = [UIColor darkGrayColor];
  }
  
  self.myCoin.image = self.imageView.image;
}


#pragma mark - UIImagePickerController

-(void)pickerWithSourceType:(NSUInteger)sourceType {
  
  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
  
  _sourceType = sourceType;
  picker.sourceType = sourceType;
  picker.delegate = self;
  picker.allowsEditing = YES;
  
  [self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  
  [self dismissViewControllerAnimated:YES completion:^{
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [self updatePickedImage:pickedImage];
  }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [self dismissViewControllerAnimated:YES completion:^{
    NSLog(@"User cancelled image picker");
  }];
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
  if (error) {
    NSLog(@"There was an error");
  } else {
    NSLog(@"Image successfully saved");
  }
}

-(void)presentPickerActionSheet {
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
      // if camera is available, let user choose between taking or selecting photo
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take a photo", @"Select photo from camera roll", nil];
    [actionSheet showInView:self.view.superview];
  } else {
      // otherwise user has no choice but to select photo
    [self pickerWithSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
  }
}

#pragma mark - button methods

-(IBAction)addPhotoTapped:(id)sender {
  [self presentPickerActionSheet];
}

-(IBAction)postCoinTapped:(id)sender {
  
  NSMutableDictionary *coinInfo = [NSMutableDictionary dictionary];
  [coinInfo setObject:self.myCoin forKey:@"coin"];
  
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter postNotificationName:@"storeCoin" object:self userInfo:coinInfo];
}

#pragma mark - action sheet methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
    case 0:
        // take photo
      NSLog(@"User chose to take photo");
      [self pickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
      break;
    case 1:
        // select photo
      NSLog(@"User chose to select photo");
      [self pickerWithSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
      break;
  }
}

#pragma mark - text field delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  self.myCoin.title = self.titleField.text;
  self.myCoin.detail = self.detailField.text;
  [textField resignFirstResponder];
  return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.titleField resignFirstResponder];
  [self.detailField resignFirstResponder];
  [self.placemarkField resignFirstResponder];
}

#pragma mark - system methods

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
