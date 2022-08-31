//  ViewController.m
//  Timers
//
//  Created by David Phillip Oster on 8/18/22.
//

#import "T1MTimerListController.h"

#import "T1MColor.h"
#import "T1MPopTimeViewController.h"
#import "T1MTimer.h"
#import "T1MTimerCell.h"
#import "TimeIntervalFormatter.h"
#import "UIView+T1M.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

static NSString *const kTimers = @"timers";

enum {
  NumTimers = 12
};

@interface T1MTimerListController () <
  PresentationDismisser,
  T1MTimerCellDelegate,
  T1MTimerDelegate,
  UIPopoverPresentationControllerDelegate,
  UITableViewDelegate,
  UITableViewDataSource,
  UITextFieldDelegate,
  UNNotificationContentExtension,
  UNUserNotificationCenterDelegate>
@property(nonatomic) UITableView *tableView;
@property(nonatomic) NSArray<T1MTimer *> *timers;
@property(nonatomic) T1MPopTimeViewController *durationController;

@property(nonatomic, nullable, weak) UITextField *currentTextField;
@property(nonatomic) T1MTimer *currentTimer;
@property(nonatomic) NSString *currentTimersOriginalLabel;
@end

@implementation T1MTimerListController

- (instancetype)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
  self = [super initWithNibName:nibName bundle:nibBundle];
  self.title = @"Timers";
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(appendTimer:)];

  NSURL *folderURL = FolderURL();
  NSURL *fileURL = [folderURL URLByAppendingPathComponent:@"timers.plist"];
  NSData *data = [NSData dataWithContentsOfURL:fileURL];
  // data = nil; // uncomment to use the compiled in sample data
  NSMutableArray  *a = [NSMutableArray array];
  if (data.length) {
    NSDictionary *root = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:NULL];
    NSArray *timersDictionaries = root[kTimers];
    for (NSDictionary *timerDict in timersDictionaries) {
      T1MTimer *timer = [[T1MTimer alloc] initWithDictionary:timerDict];
      if (timer) {
        [a addObject:timer];
      }
    }
  }
  if (0 == a.count) {
    NSDictionary *labels = @{
      @(1): @"Turkey",
      @(2): @"Potatoes",
      @(3): @"Running",
      @(5): @"Class Time",
    };
    for (int i = 0;i < NumTimers; ++i) {
      T1MTimer *timer = [[T1MTimer alloc] init];
      timer.maxSeconds = MAX(0, 200 - i*15);
      timer.runState = (0 < timer.maxSeconds && 1 == (i&1)) ? RunStateRunning : RunStateIdle;
      timer.label = labels[@(i)];
      [a addObject:timer];
    }
  }
  self.timers = a;
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
  [nc addObserver:self selector:@selector(becomeInactive:) name:UIApplicationWillResignActiveNotification object:nil];
  [self.undoManager setLevelsOfUndo:100];
  return self;
}


- (BOOL)canBecomeFirstResponder {
  return YES;
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

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self becomeFirstResponder];
  NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
  [nc addObserver:self selector:@selector(adjustForKeyboard:) name:UIKeyboardWillHideNotification object:nil];
  [nc addObserver:self selector:@selector(adjustForKeyboard:) name:UIKeyboardWillChangeFrameNotification object:nil];

  if (@available(iOS 10.0, *)) {
    UNUserNotificationCenter *center = UNUserNotificationCenter.currentNotificationCenter;
    center.delegate = self;
    UNAuthorizationOptions options = UNAuthorizationOptionSound | UNAuthorizationOptionAlert;
    if (@available(iOS 15.0, *)) {
      options |= UNAuthorizationOptionTimeSensitive;
    }
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError *error){
    }];
  }

}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self resignFirstResponder];
  NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
  [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
  [nc removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)didReceiveNotification:(UNNotification *)notification API_AVAILABLE(ios(10.0)) {
}

- (void)becomeActive:(NSNotification *)note {
}

- (void)becomeInactive:(NSNotification *)note {
  NSMutableDictionary *root = [NSMutableDictionary dictionary];
  NSMutableArray *timerDictionaries = [NSMutableArray array];
  for (T1MTimer *timer in self.timers) {
    [timerDictionaries addObject:[timer asDictionary]];
  }
  root[kTimers] = timerDictionaries;
  NSData *data = [NSPropertyListSerialization dataWithPropertyList:root format:NSPropertyListXMLFormat_v1_0 options:0 error:NULL];
  if (data.length) {
    NSURL *folderURL = FolderURL();
    NSURL *fileURL = [folderURL URLByAppendingPathComponent:@"timers.plist"];
    [data writeToURL:fileURL atomically:YES];
  }
}

#pragma mark -

- (void)appendTimer:(id)sender {
  T1MTimer *timer = [[T1MTimer alloc] init];
  timer.maxSeconds = 30;
  NSUInteger count = self.timers.count;
  [self undoablyAddTimer:timer atIndex:count];
}


- (void)setTimers:(NSArray<T1MTimer *> *)timers {
  for (T1MTimer *timer in _timers) {
    timer.delegate = nil;
  }
  _timers = timers;
  for (T1MTimer *timer in _timers) {
    timer.delegate = self;
  }
}

- (void)undoablyAddTimer:(T1MTimer *)timer atIndex:(NSInteger)index {
  if (!(self.undoManager.undoing || self.undoManager.redoing)) {
    [self.undoManager setActionName:@"add timer"];
  }
  [[self.undoManager prepareWithInvocationTarget:self] undoablyRemoveTimer:timer atIndex:index];
  NSMutableArray<T1MTimer *> *a = [self.timers mutableCopy];
  [a insertObject:timer atIndex:index];
  self.timers = a;
  NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
  [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
  [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)undoablyRemoveTimer:(T1MTimer *)timer atIndex:(NSInteger)index {
  if (!(self.undoManager.undoing || self.undoManager.redoing)) {
    [self.undoManager setActionName:@"delete timer"];
  }
  [[self.undoManager prepareWithInvocationTarget:self] undoablyAddTimer:timer atIndex:index];
  NSMutableArray<T1MTimer *> *a = [self.timers mutableCopy];
  [a removeObjectAtIndex:index];
  self.timers = a;
  NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
  [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)setTimer:(T1MTimer *)timer label:(NSString *)label prevLabel:(NSString *)prevLabel {
  timer.label = label;
  [[self.undoManager prepareWithInvocationTarget:self] setTimer:timer label:prevLabel prevLabel:label];
  [self updateTimer:timer];
}


- (void)setTimer:(T1MTimer *)timer maxSeconds:(NSInteger)maxSeconds prevMaxSeconds:(NSInteger)prevMaxSeconds {
  timer.maxSeconds = maxSeconds;
  [[self.undoManager prepareWithInvocationTarget:self] setTimer:timer maxSeconds:prevMaxSeconds prevMaxSeconds:maxSeconds];
}

- (void)setTimers:(NSArray<T1MTimer *> *)timers prevTimers:(NSArray<T1MTimer *> *)prevTimers {
  self.timers = timers;
  [[self.undoManager prepareWithInvocationTarget:self] setTimers:prevTimers prevTimers:timers];
}

#pragma mark -

// When Popover dismissed on iPad. Not called in iOS 9 iPad.
- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController {
  [self didDismissPresentation];
}

- (void)didDismissPresentation {
  if (self.durationController) {
    T1MTimer *timer = self.timers[self.durationController.path.row];
    NSInteger seconds = self.durationController.seconds;
    if (seconds != timer.maxSeconds) {
      [self setTimer:timer maxSeconds:seconds prevMaxSeconds:timer.maxSeconds];
      NSString *timeString = [T1MTimerCell.timeIntervalFormatter stringFromInteger:seconds];
      NSString *s = [NSString stringWithFormat:@"set duration to %@", timeString];
      [self.undoManager setActionName:s];
    }
    self.durationController = nil;
  }
}

- (void)popSetUILabel:(UILabel *)label path:(NSIndexPath *)path {
  T1MTimer *timer = self.timers[path.row];
  T1MPopTimeViewController *controller = [[T1MPopTimeViewController alloc] init];
  controller.presentationDelegate = self;
  UINavigationController *nav = nil;
  if (!IsIpadMode()) {
    nav = [[UINavigationController alloc] initWithRootViewController:controller];
  }
  UIViewController *presentable = nav ? nav : controller;

  controller.path = path;
  controller.seconds = MAX(0, timer.maxSeconds);
  self.durationController = controller;
  presentable.modalPresentationStyle = UIModalPresentationPopover;
  UIPopoverPresentationController *pop = presentable.popoverPresentationController;
  pop.delegate = self;
  pop.sourceView = label;
  pop.sourceRect = label.bounds;
  pop.permittedArrowDirections = UIPopoverArrowDirectionAny;
  [self presentViewController:presentable animated:YES completion:nil];
}

- (void)didTapTimeLabel:(UILabel *)label {
  UITableViewCell *cell = [label tm_superviewOfClass:[UITableViewCell class]];
  if (self.tableView == [cell tm_superviewOfClass:[UITableView class]]) {
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    if (path) {
      T1MTimer *timer = self.timers[path.row];
      switch (timer.runState) {
      case RunStateIdle:
        [self popSetUILabel:label path:path];
        break;
      case RunStateRunning:
      case RunStateAlarming:
        [timer setRunState:RunStateIdle];
        break;
      }
    }
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.timers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  T1MTimerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"a"];
  if (nil == cell) {
    cell = [[T1MTimerCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"a"];
    cell.textField.delegate = self;
    cell.delegate = self;
  }
  cell.timer = self.timers[indexPath.row];
  return cell;
}

// Without this, on iOS 9, the cells are only 40 tall.
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 100.0;
}

// Don't update invisible cells.
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
  // check for deleting the last cell.
  if (indexPath.row < self.timers.count) {
    T1MTimer *timer = self.timers[indexPath.row];
    if ((id)cell == timer.delegate) {
      timer.delegate = nil;
    }
  }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    T1MTimer *timer = self.timers[indexPath.row];
    [self undoablyRemoveTimer:timer atIndex:indexPath.row];
  }
}

#pragma mark -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//  self.currentTextField = textField;
//  UITableViewCell *cell = [textField tm_superviewOfClass:[UITableViewCell class]];
//  if (self.tableView == [cell tm_superviewOfClass:[UITableView class]]) {
//    NSIndexPath *path = [self.tableView indexPathForCell:cell];
//    if (path) {
//      [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
//      self.currentTimer = self.timers[path.row];
//      self.currentTimersOriginalLabel = self.currentTimer.label ?: @"";
//    }
//  }
  return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  UITableViewCell *cell = [textField tm_superviewOfClass:[UITableViewCell class]];
  if (self.tableView == [cell tm_superviewOfClass:[UITableView class]]) {
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    if (path) {
      [self.tableView deselectRowAtIndexPath:path animated:YES];
      T1MTimer *timer = self.timers[path.row];
//      if (![timer.label isEqual:textField.text]) {
//        [self setTimer:timer label:textField.text prevLabel:timer.label];
//        self.currentTimer = nil;
//        [self.undoManager setActionName:@"set timer name"];
//      } else {
        timer.label = textField.text;
//      }
    }
  }
  if (self.currentTextField == textField) {
    self.currentTextField = nil;
  }
}


- (void)adjustForKeyboard:(NSNotification *)note {
  NSValue *keyboardValue = note.userInfo[UIKeyboardFrameEndUserInfoKey];
  if (keyboardValue) {
    CGRect keyboardScreenEndFrame = [keyboardValue CGRectValue];
    CGRect keyboardViewEndFrame = [self.view convertRect:keyboardScreenEndFrame fromView:self.view.window];

    if(note.name == UIKeyboardWillHideNotification) {
      self.tableView.contentInset = UIEdgeInsetsZero;
    } else {
      self.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardViewEndFrame.size.height - self.view.tm_safeAreaInsets.bottom, 0);
    }
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    NSIndexPath *selectedRow = self.tableView.indexPathForSelectedRow;
    [self.tableView scrollToRowAtIndexPath:selectedRow atScrollPosition:UITableViewScrollPositionBottom animated:YES];
  }
}

#pragma mark -

- (void)updateTimer:(T1MTimer *)timer {
  // We might not be in the window if a diffent viewController is showing.
  if (self.tableView.window) {
    NSUInteger row = [self.timers indexOfObject:timer];
    if (NSNotFound != row) {
      NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
      [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    }
  }
}

- (void)labelChanged:(T1MTimer *)timer {
}

- (void)maxSecondsChanged:(T1MTimer *)timer {
  [self updateTimer:timer];
}

- (void)secondsRemainingChanged:(T1MTimer *)timer {
  [self updateTimer:timer];
}

- (void)stateChanged:(T1MTimer *)timer {
  [self updateTimer:timer];
}

- (void)alarmTickChanged:(T1MTimer *)timer {
  [self updateTimer:timer];
}

#pragma mark -


@end
