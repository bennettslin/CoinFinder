#import "LeftPanelViewController.h"

@protocol CenterViewControllerDelegate <NSObject>

-(void)movePanelRight;
-(void)movePanelToOriginalPosition;

@end

@interface CenterViewController : UIViewController

@property (nonatomic, assign) id<CenterViewControllerDelegate> centerViewDelegate;
@property (nonatomic, weak) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UILabel *topBarLabel;

@end
