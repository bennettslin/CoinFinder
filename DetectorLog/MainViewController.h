#import <UIKit/UIKit.h>
@class Coin;

typedef enum pageType {
  kPageTypeFoundCoin,
  kPageTypeEditCoin,
  kPageTypeMyCoins,
  kPageTypeCoinMap
} PageType;

@interface MainViewController : UIViewController

-(void)removeCenterChildVCs;
-(void)loadChildPage:(PageType)pageType withCoin:(Coin *)coin showCoinInMap:(BOOL)showCoinInMap;

@end