#import "CenterViewController.h"
#import "Constants.h"

@interface CenterViewController ()

@end

@implementation CenterViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  self.leftButton.tag = 1;
  [self.leftButton setImage:[UIImage imageNamed:@"hamburger_icon"] forState:UIControlStateNormal];
  self.leftButton.frame = CGRectMake(8, 18, 44, 44);
  
//  self.leftButton.layer.borderColor = [UIColor redColor].CGColor;
//  self.leftButton.layer.borderWidth = 1.f;
  self.topBar.backgroundColor = kColourDarkAqua;
  
  self.topBarLabel.font = [UIFont fontWithName:kFontMacBeth size:24.f];
  self.topBarLabel.textColor = kColourTextBlack;
  self.topBarLabel.adjustsFontSizeToFitWidth = YES;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(btnMovePanelRight:) name:@"movePanelRight" object:nil];
}

#pragma mark - button actions

-(IBAction)btnMovePanelRight:(id)sender {
  
  if (![sender isKindOfClass:UIButton.class]) {
    [_centerViewDelegate movePanelRight];
    return;
  }
  
  UIButton *button = sender;
  
  switch (button.tag) {
    case 0: {
      [_centerViewDelegate movePanelToOriginalPosition];
      break;
    }
    case 1: {
      [_centerViewDelegate movePanelRight];
      break;
    }
  }
}

#pragma mark - default system code

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
