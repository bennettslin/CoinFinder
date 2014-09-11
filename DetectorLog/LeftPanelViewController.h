#import <UIKit/UIKit.h>
@class MainViewController;

@interface LeftPanelViewController : UIViewController

@property (weak, nonatomic) MainViewController *myMainVC;
@property (strong, nonatomic) NSArray *cellsArray;

@end