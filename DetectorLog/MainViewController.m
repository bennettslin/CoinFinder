#import "MainViewController.h"
#import "CenterViewController.h"
#import "LeftPanelViewController.h"
#import "FoundCoinViewController.h"
#import "MyCoinsViewController.h"
#import "Coins.h"
#import "Coin.h"

#define kCenterTag 1
#define kLeftPanelTag 2
#define kCornerRadius 4.f
#define kSlideTiming .25f
#define kPanelWidth 60.f

  // offset for child VCs to sit below search bar
#define kTopOffset 64.f

@interface MainViewController () <CenterViewControllerDelegate, UIGestureRecognizerDelegate>

  // view controllers
@property (strong, nonatomic) CenterViewController *centerVC;
@property (strong, nonatomic) LeftPanelViewController *leftPanelVC;

  // model objects
@property (strong, nonatomic) Coins *myCoins;

  // bools and pointers
@property (assign, nonatomic) BOOL showingLeftPanel;
@property (nonatomic, assign) BOOL showPanel;
@property (nonatomic, assign) CGPoint preVelocity;

@end

@implementation MainViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  [self setupView];
  
  self.myCoins = [Coins getCoins];
  
//  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotificationToStoreCoin:) name:@"storeCoin" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotificationToEditCoin:) name:@"editCoin" object:nil];
//  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotificationToPresentCoins:) name:@"presentCoins" object:nil];
}

#pragma mark - views

-(void)setupView {
  
    // setup left view
  self.leftPanelVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftPanelVC"];
  self.leftPanelVC.view.tag = kLeftPanelTag;
  self.leftPanelVC.myMainVC = self;
  
    // setup center view
  self.centerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CenterVC"];
  self.centerVC.view.tag = kCenterTag;
  self.centerVC.centerViewDelegate = self;
  
  [self.view addSubview:self.centerVC.view];
  [self addChildViewController:_centerVC];
  [_centerVC didMoveToParentViewController:self];
  
    // default page when it loads
  [self loadChildPage:kPageTypeFoundCoin withCoin:nil];
  [self movePanelRight];
  [self setupGestures];
}

-(void)resetMainView {
  
  _centerVC.leftButton.tag = 1;
  self.showingLeftPanel = NO;
  
    // remove view shadows
//  [self showCenterViewWithShadow:NO withOffset:0];
  
}

-(UIView *)getLeftView {

  [self.view addSubview:self.leftPanelVC.view];
  [self addChildViewController:_leftPanelVC];
  [_leftPanelVC didMoveToParentViewController:self];
  
  self.showingLeftPanel = YES;
  
    // set up view shadows
  [self showCenterViewWithShadow:YES withOffset:-7.5];
  
  UIView *view = self.leftPanelVC.view;
  return view;
}

#pragma mark - child pages

-(void)removeCenterChildVCs {
  UIViewController *centerChildVC;
  if (![self.centerVC.childViewControllers containsObject:centerChildVC]) {
    for (UIViewController *vc in self.centerVC.childViewControllers) {
      [vc willMoveToParentViewController:nil];
      [vc.view removeFromSuperview];
      [vc removeFromParentViewController];
    }
  }
}

-(void)loadChildPage:(PageType)pageType withCoin:(Coin *)coin {
  [self removeCenterChildVCs];
  UIViewController *childVC;

  if (pageType == kPageTypeFoundCoin) {
    FoundCoinViewController *foundCoinVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FoundCoinVC"];
    foundCoinVC.myCoin = coin;
    foundCoinVC.postingNewCoinForFirstTime = YES;
    childVC = foundCoinVC;
    self.centerVC.topBarLabel.text = self.leftPanelVC.cellsArray[0];

  } else if (pageType == kPageTypeEditCoin) {
    FoundCoinViewController *editCoinVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FoundCoinVC"];
    editCoinVC.myCoin = coin;
    editCoinVC.postingNewCoinForFirstTime = NO;
    childVC = editCoinVC;
    self.centerVC.topBarLabel.text = @"Edit this coin";
    
  } else if (pageType == kPageTypeMyCoins) {
    MyCoinsViewController *myCoinsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCoinsVC"];
    childVC = myCoinsVC;
    self.centerVC.topBarLabel.text = self.leftPanelVC.cellsArray[1];
  
  } else if (pageType == kPageTypeCoinMap) {

      // FIXME: add
    self.centerVC.topBarLabel.text = self.leftPanelVC.cellsArray[2];
  }
  
  if (childVC) {
    childVC.view.frame = CGRectMake(0, kTopOffset, self.view.frame.size.width, self.view.frame.size.height - kTopOffset);
    [self.centerVC.view addSubview:childVC.view];
    [self.centerVC addChildViewController:childVC];
    [childVC didMoveToParentViewController:self.centerVC];
    [self movePanelToOriginalPosition];
  }
}

#pragma mark - gestures

-(void)setupGestures {
  UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
  [panRecognizer setMinimumNumberOfTouches:1];
  [panRecognizer setMaximumNumberOfTouches:1];
  [panRecognizer setDelegate:self];
  
  [_centerVC.view addGestureRecognizer:panRecognizer];
}

-(void)movePanel:(id)sender {
  [[[(UITapGestureRecognizer *)sender view] layer] removeAllAnimations];
  
  CGPoint translatedPoint = [(UIPanGestureRecognizer *)sender translationInView:self.view];
  CGPoint velocity = [(UIPanGestureRecognizer *)sender velocityInView:[sender view]];
  
  if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
    UIView *childView = nil;
    
    if(velocity.x > 0) {
      childView = [self getLeftView];
    }
      // Make sure the view you're working with is front and center.
    [self.view sendSubviewToBack:childView];
    [[sender view] bringSubviewToFront:[(UIPanGestureRecognizer *)sender view]];
  }
  
  if([(UIPanGestureRecognizer *)sender state] == UIGestureRecognizerStateEnded) {
    if (!_showPanel) {
      [self movePanelToOriginalPosition];
    } else {
      if (_showingLeftPanel) {
        [self movePanelRight];
      }
    }
  }
  
  if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
    _showPanel = velocity.x > 0 ?
      [sender view].center.x > _centerVC.view.frame.size.width * 9/16 :
      [sender view].center.x > _centerVC.view.frame.size.width * 23/16 - kPanelWidth;
    
      // will not drag too far left
    CGFloat xCoord = ([sender view].center.x + translatedPoint.x) < self.view.frame.size.width / 2 ?
        0 : translatedPoint.x;
    
    [sender view].center = CGPointMake([sender view].center.x + xCoord, [sender view].center.y);
    [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
  }
}

#pragma mark - actions

-(void)movePanelRight { // to show left panel
  UIView *childView = [self getLeftView];
  [self.view sendSubviewToBack:childView];
  
  [UIView animateWithDuration:kSlideTiming delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                   animations:^{
                     _centerVC.view.frame = CGRectMake(self.view.frame.size.width - kPanelWidth, 0, self.view.frame.size.width, self.view.frame.size.height);
                   }
                   completion:^(BOOL finished) {
                     if (finished) {
                       _centerVC.leftButton.tag = 0;
                     }
                   }];

}

-(void)movePanelToOriginalPosition {
  [UIView animateWithDuration:kSlideTiming delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                   animations:^{
                     _centerVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                   }
                   completion:^(BOOL finished) {
                     if (finished) {
                       
                       [self resetMainView];
                     }
                   }];
}

-(void)showCenterViewWithShadow:(BOOL)value withOffset:(double)offset {
  if (value) {
//    [_centerVC.view.layer setCornerRadius:kCornerRadius];
//    _centerVC.view.clipsToBounds = YES;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_centerVC.view.bounds];
    _centerVC.view.layer.masksToBounds = NO;
    _centerVC.view.layer.shadowColor = [UIColor blackColor].CGColor;
    _centerVC.view.layer.shadowOffset = CGSizeMake(offset, 0);
    _centerVC.view.layer.shadowOpacity = 0.3f;
    _centerVC.view.layer.shadowPath = shadowPath.CGPath;
    
  } else {
    _centerVC.view.layer.cornerRadius = 0.f;
    _centerVC.view.layer.shadowOffset = CGSizeMake(offset, 0);
  }
}

#pragma mark - NSNotification method

//-(void)receiveNotificationToStoreCoin:(NSNotification *)notification {
//  if ([notification.name isEqualToString:@"storeCoin"]) {
//    NSDictionary *coinInfo = notification.userInfo;
//    Coin *coin = [coinInfo objectForKey:@"coin"];
//    [self storeCoin:coin];
//  }
//}

-(void)receiveNotificationToEditCoin:(NSNotification *)notification {
  if ([notification.name isEqualToString:@"editCoin"]) {
    
    NSDictionary *coinInfo = notification.userInfo;
    Coin *myCoin = [coinInfo objectForKey:@"coin"];
    [self loadChildPage:kPageTypeEditCoin withCoin:myCoin];
  }
}

//-(void)receiveNotificationToPresentCoins:(NSNotification *)notification {
//  NSMutableDictionary *coinsInfo = [NSMutableDictionary dictionary];
//  [coinsInfo setObject:self.myCoins forKey:@"coins"];
//  
//  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//  [notificationCenter postNotificationName:@"sendCoins" object:self userInfo:coinsInfo];
//}

#pragma mark - Store and persist data methods

//-(void)storeCoin:(Coin *)myCoin {
//  
//  [self.myCoins addToMyCoinsThisCoin:myCoin];
//  [self loadChildPage:kPageTypeMyCoins withCoin:nil];
//}

#pragma mark Default System Code

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
