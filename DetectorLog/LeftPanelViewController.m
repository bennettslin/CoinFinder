#import "LeftPanelViewController.h"
#import "LeftPanelTableViewCell.h"
#import "MainViewController.h"
#import "Constants.h"

@interface LeftPanelViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation LeftPanelViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = kColourDarkTan;
  
  self.cellsArray = @[@"Add new coin", @"My found collection", @"Map of find locations"];
  self.myTableView.delegate = self;
  self.myTableView.dataSource = self;
  self.myTableView.separatorColor = kColourDarkTan;
}

#pragma mark UITableView Datasource/Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.cellsArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  LeftPanelTableViewCell *pagesCell = [tableView dequeueReusableCellWithIdentifier:@"LeftPanelCell" forIndexPath:indexPath];
  
  pagesCell.backgroundColor = kColourLightTan;
  pagesCell.titleLabel.text = self.cellsArray[indexPath.row];
  pagesCell.titleLabel.font = [UIFont fontWithName:kFontMacBeth size:24.f];
  pagesCell.titleLabel.textColor = kColourTextBlack;

  return pagesCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.row) {
    case 0:
      [self.myMainVC loadChildPage:kPageTypeFoundCoin withCoin:nil showCoinInMap:NO];
      break;
    case 1:
      [self.myMainVC loadChildPage:kPageTypeMyCoins withCoin:nil showCoinInMap:NO];
      break;
    case 2:
      [self.myMainVC loadChildPage:kPageTypeCoinMap withCoin:nil showCoinInMap:NO];
      break;
  }
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  LeftPanelTableViewCell *cell = (LeftPanelTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
  cell.contentView.backgroundColor = [UIColor whiteColor];
  cell.backgroundColor = [UIColor whiteColor];
}

-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  LeftPanelTableViewCell *cell = (LeftPanelTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
  cell.contentView.backgroundColor = kColourLightTan;
  cell.backgroundColor = kColourLightTan;
}

#pragma mark Default System Code

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
