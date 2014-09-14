//
//  PickerFormViewController.m
//  NeighbourRentingApp
//
//  Created by Bennett Lin on 6/22/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "FoundCoinFormViewController.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "IndentedTextField.h"
#import "LocationEngine.h"
#import "Coin.h"
#import "Constants.h"

@interface FoundCoinFormViewController () <UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, LocationEngineDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *addOrChangePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *postCoinButton;

@property (weak, nonatomic) IBOutlet UILabel *coordinateLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;

@property (strong, nonatomic) LocationEngine *locationEngine;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) UIImage *tempImage;

  // pointers and bools
@property (nonatomic) NSUInteger sourceType;
@property (nonatomic) BOOL postingCoinForFirstTime;

@end

@implementation FoundCoinFormViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
    // easiest way to get it from appDelegate, don't care what anyone else says, haha
  AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
  self.managedObjectContext = appDelegate.managedObjectContext;
  
  self.titleField.delegate = self;
  self.detailField.delegate = self;
  self.placemarkField.delegate = self;
  
  self.imageView.contentMode = UIViewContentModeScaleAspectFit;
  self.imageView.layer.cornerRadius = 10.f;
  self.imageView.clipsToBounds = YES;
  
  self.locationEngine = [LocationEngine new];
  self.locationEngine.delegate = self;
  
  self.titleField.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.titleField.layer.borderWidth = 1.f;
  self.titleField.backgroundColor = [UIColor whiteColor];
  self.titleField.layer.cornerRadius = 5.f;
  self.titleField.clipsToBounds = YES;
  self.titleField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
  self.titleField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
  
  self.detailField.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.detailField.layer.borderWidth = 1.f;
  [self returnTextViewPlaceholderIfNecessary];
  self.detailField.layer.cornerRadius = 5.f;
  self.detailField.clipsToBounds = YES;

  self.placemarkField.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.placemarkField.layer.borderWidth = 1.f;
  self.placemarkField.backgroundColor = [UIColor whiteColor];
  self.placemarkField.layer.cornerRadius = 5.f;
  self.placemarkField.clipsToBounds = YES;
  self.placemarkField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
  self.placemarkField.autocapitalizationType = UITextAutocapitalizationTypeWords;
  
  self.postDateLabel.adjustsFontSizeToFitWidth = YES;
  self.coordinateLabel.adjustsFontSizeToFitWidth = YES;
}

-(void)checkIfAddOrEdit {
  self.postingCoinForFirstTime = [self.delegate firstTime];
  NSString *postCoinButtonText;
  
    // adding coin
  if (self.postingCoinForFirstTime) {
    NSLog(@"adding coin first time");
    self.myCoin = nil;
    [self updatePickedImage:nil];
    self.titleField.text = @"";
    self.detailField.text = @"";
    [self returnTextViewPlaceholderIfNecessary];
    
    postCoinButtonText = @" Add this coin! ";
    
    [self updatePlacemark:nil];
    [self updateLatitude:MAXFLOAT longitude:MAXFLOAT];
    [self updateDate:[NSDate date]];
    
      // editing coin
  } else {
    
    NSLog(@"editing coin");
    if ([self.myCoin hasPhoto]) {
      [self updatePickedImage:[self.myCoin photoImage]];
    } else {
      [self updatePickedImage:nil];
    }
    self.titleField.text = self.myCoin.title;
    self.detailField.text = self.myCoin.detail;
    [self returnTextViewPlaceholderIfNecessary];
    
    postCoinButtonText = @" Save changes! ";
    
    [self updatePlacemark:self.myCoin.placemark];
    [self updateLatitude:[self.myCoin.latitude floatValue]
               longitude:[self.myCoin.longitude floatValue]];
    [self updateDate:self.myCoin.date];
  }
  
  [self.postCoinButton setTitle:postCoinButtonText forState:UIControlStateNormal];
  self.postCoinButton.titleLabel.font = [UIFont fontWithName:kFontCaflisch size:36.f];
  [self checkToEnablePostCoinButton];
}

-(void)viewWillAppear:(BOOL)animated {
  if (![self.locationEngine checkLocationServicesEnabled] || !self.postingCoinForFirstTime) {
    self.currentLocationButton.enabled = NO;
  } else {
    self.currentLocationButton.enabled = YES;
  }
}

-(void)viewWillDisappear:(BOOL)animated {
  [self.locationEngine stopLocationManagerWithError:nil];
  self.myCoin = nil;
}

-(void)updatePickedImage:(UIImage *)pickedImage {
  self.tempImage = pickedImage;
  
  if (pickedImage) {
    self.imageView.image = pickedImage;
    [self.addOrChangePhotoButton setTitle:@"Change photo" forState:UIControlStateNormal];
    
  } else {
    self.imageView.image = [UIImage imageNamed:@"placeholder_coin"];
    [self.addOrChangePhotoButton setTitle:@"Add photo" forState:UIControlStateNormal];
  }
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
  }];
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
  if (error) {
    [self showErrorAlertView:error];
  }
}

-(void)showErrorAlertView:(NSError *)error {
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:[NSString stringWithFormat:@"There was an error: %@", error.description] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
  [alertView show];
}

-(void)presentPickerActionSheet {
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
      // if camera is available, let user choose between taking or selecting photo
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take a photo", @"Select from photos album", nil];
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
  
  [self.locationEngine stopLocationManagerWithError:nil];
  
  if (!self.myCoin) {
    self.myCoin = [NSEntityDescription insertNewObjectForEntityForName:@"Coin" inManagedObjectContext:self.managedObjectContext];
    self.myCoin.photoID = @-1;
  }
  
  [self.myCoin setName:self.titleField.text];
  [self.myCoin setDetail:self.detailField.text];
  
  if ([self.coordinateLabel.text isEqualToString:@""]) {
    [self.myCoin setLatitude:@(MAXFLOAT)];
    [self.myCoin setLongitude:@(MAXFLOAT)];
  } else {
    [self.myCoin setLatitude:@(self.locationEngine.latestLocation.coordinate.latitude)];
    [self.myCoin setLongitude:@(self.locationEngine.latestLocation.coordinate.longitude)];
  }
  
  [self.myCoin setDate:(self.postingCoinForFirstTime ? [NSDate date] : self.myCoin.date)];
  [self.myCoin setPlacemark:self.locationEngine.latestPlacemark];
  
  if (self.tempImage) {
    
    if (![self.myCoin hasPhoto]) {
      self.myCoin.photoID = @([Coin nextPhotoID]);
    }
    
    NSData *data = UIImageJPEGRepresentation(self.tempImage, 0.5);
    NSError *error;
    if (![data writeToFile:[self.myCoin photoPath] options:NSDataWritingAtomic error:&error]) {
      [self showErrorAlertView:error];
    }
  }
  
  NSError *error;
  if (![self.managedObjectContext save:&error]) {
    
      // FIXME: currently, nothing is listening for this notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kManagedObjectContextSaveDidFailNotification object:error];
    abort();
    
  } else {
    
    UIAlertView *alertView;
    if (self.postingCoinForFirstTime) {
      alertView = [[UIAlertView alloc] initWithTitle:@"Coin added!" message:@"New coin added to collection." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
      
    } else {
      alertView = [[UIAlertView alloc] initWithTitle:@"Coin edited!" message:@"Your changes have been saved." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    }
    alertView.tag = 50;
    [alertView show];

  }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0 && alertView.tag == 50) {
    self.myCoin = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"movePanelRight" object:nil];
  }
}

-(IBAction)currentLocationTapped:(id)sender {
  [self.locationEngine startLocationManager];
}

#pragma mark - action sheet methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
    case 0:
        // take photo
      [self pickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
      break;
    case 1:
        // select photo
      [self pickerWithSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
      break;
  }
}

#pragma mark - update textField methods

-(void)updateLocationServicesDisabled {
//  self.coordinateLabel.text = @"Location services have been disabled for this app.";
  self.currentLocationButton.enabled = NO;
}

-(void)updateLatitude:(float)latitude longitude:(float)longitude {
  if (latitude != MAXFLOAT && longitude != MAXFLOAT) {
  self.coordinateLabel.text = [NSString stringWithFormat:@"Found at latitude %.4f, longitude %.4f", latitude, longitude];
  } else {
    self.coordinateLabel.text = @"";
  }
}

-(void)updatePlacemark:(CLPlacemark *)placemark {
  if (placemark) {
    self.placemarkField.text = [self stringFromPlacemark:placemark];
  } else {
    self.placemarkField.text = @"";
  }
}

-(NSString *)stringFromPlacemark:(CLPlacemark *)placemark {
  return [NSString stringWithFormat:@"%@ %@, %@ %@ %@",
          placemark.subThoroughfare,
          placemark.thoroughfare,
          placemark.locality,
          placemark.administrativeArea,
          placemark.postalCode];
}

-(void)updateDate:(NSDate *)date {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateStyle:NSDateFormatterShortStyle];

  self.postDateLabel.text = [NSString stringWithFormat:@"Found %@", [dateFormatter stringFromDate:date]];
}

#pragma mark - text field and view delegate methods

-(void)textViewDidBeginEditing:(UITextView *)textView {
  [self.delegate keyboardDidShow:nil];
  if ([textView.text isEqualToString:@"Describe your find"]) {
    textView.text = @"";
  }
  
  textView.textColor = [UIColor blackColor];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
  textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  [self returnTextViewPlaceholderIfNecessary];
  [self.detailField resignFirstResponder];
}

-(void)textViewDidChange:(UITextView *)textView {
//  [self returnTextViewPlaceholderIfNecessary];
}

-(void)returnTextViewPlaceholderIfNecessary {
  if (self.detailField.text.length == 0) {
    self.detailField.textColor = [UIColor lightGrayColor];
    self.detailField.text = @"Describe your find";
  }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
  
  if (textField == self.titleField) {
    [self.delegate keyboardDidShow:nil];
  }
  
  if (textField == self.placemarkField) {
    [self.delegate keyboardDidShow:nil];
    [self.locationEngine stopLocationManagerWithError:nil];
  }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
  textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  [self checkToEnablePostCoinButton];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  self.myCoin.name = self.titleField.text;
  self.myCoin.detail = self.detailField.text;
  
  [self.titleField resignFirstResponder];
  [self.detailField resignFirstResponder];
  [self.placemarkField resignFirstResponder];
  return YES;
}

-(UIView *)checkFirstResponder {
  for (UIView *subView in self.view.subviews) {
    if ([subView isFirstResponder]) {
      return subView;
    }
  }
  return nil;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self resignFirstResponders];
}

-(void)resignFirstResponders {
  [self.titleField resignFirstResponder];
  [self.detailField resignFirstResponder];
  [self.placemarkField resignFirstResponder];
}

-(void)checkToEnablePostCoinButton {
  if (self.titleField.text.length == 0) {
    self.postCoinButton.enabled = NO;
  } else {
    self.postCoinButton.enabled = YES;
  }
}

#pragma mark - system methods

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
