//
//  T1MHistoryController.m
//  Timers
//
//  Created by david on 8/26/22.
//

#import "T1MHistoryController.h"

#import "T1MAppDelegate.h"
#import "T1MColor.h"
#import "UIView+T1M.h"

@interface T1MHistoryController () <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic) NSArray *history;
@property(nonatomic) UITableView *tableView;
@end

@implementation T1MHistoryController

- (instancetype)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
  self = [super initWithNibName:nibName bundle:nibBundle];
  if (self) {
    self.title = @"History";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Timers" style:UIBarButtonItemStylePlain target:self action:@selector(showTimers:)];
  }
  return self;
}

- (void)showTimers:(id)sender {
  T1MAppDelegate *appDelegate = (T1MAppDelegate *)UIApplication.sharedApplication.delegate;
  [self.navigationController pushViewController:appDelegate.mainController animated:YES];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  UITableView *tableView = [[UITableView alloc] initWithFrame:UIScreen.mainScreen.bounds style:UITableViewStylePlain];
  tableView.dataSource = self;
  tableView.delegate = self;
  tableView.estimatedRowHeight = UITableViewAutomaticDimension;
  tableView.translatesAutoresizingMaskIntoConstraints = NO;
  self.tableView = tableView;
  [self.view addSubview:tableView];
  self.view.backgroundColor = tableView.backgroundColor = T1MColor.systemBackgroundColor;
  [NSLayoutConstraint activateConstraints:@[
    [tableView.topAnchor tm_constraintEqualToSystemSpacingBelowAnchor:self.view.topAnchor multiplier:1],
    [tableView.leadingAnchor tm_constraintEqualToSystemSpacingAfterAnchor:self.view.leadingAnchor multiplier:1],
    [self.view.trailingAnchor tm_constraintEqualToSystemSpacingAfterAnchor: tableView.trailingAnchor multiplier:1],
    [self.view.bottomAnchor tm_constraintEqualToSystemSpacingBelowAnchor: tableView.bottomAnchor multiplier:1],
  ]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.history.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"a"];
  if (nil == cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"a"];
  }
//  cell.timer = self.timers[indexPath.row];
  return cell;
}

@end
