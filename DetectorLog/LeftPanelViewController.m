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
      [self.myMainVC loadChildPage:kPageTypeFoundCoin withCoin:nil];
      break;
    case 1:
      [self.myMainVC loadChildPage:kPageTypeMyCoins withCoin:nil];
      break;
    case 2:
        // FIXME
      break;
  }
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Default System Code

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
