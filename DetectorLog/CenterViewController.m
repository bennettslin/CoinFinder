#import "CenterViewController.h"

@interface CenterViewController ()

@end

@implementation CenterViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  self.leftButton.tag = 1;
  [self.leftButton setImage:[UIImage imageNamed:@"hamburger_icon"] forState:UIControlStateNormal];
}

#pragma mark - button actions

-(IBAction)btnMovePanelRight:(id)sender {
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

@end
