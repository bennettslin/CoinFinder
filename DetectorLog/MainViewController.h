#import <UIKit/UIKit.h>
@class Coin;

typedef enum pageType {
  kPageTypeFoundCoin,
  kPageTypeMyCoins,
  kPageTypeCoinMap
} PageType;

@interface MainViewController : UIViewController

-(void)removeCenterChildVCs;
-(void)loadChildPage:(PageType)pageType withCoin:(Coin *)coin;

@end