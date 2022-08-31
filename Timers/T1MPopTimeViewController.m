//  T1MPopTimeViewController.m
//  Timers
//
//  Created by David Phillip Oster on 8/18/22.
// I looked at: https://www.codeproject.com/Tips/1055837/UIPopoverPresentationController
//

#import "T1MPopTimeViewController.h"

#import "T1MColor.h"
#import "T1MIntervalPickerView.h"
#import "UIView+T1M.h"

@interface T1MPopTimeViewController ()
@property(nonatomic) T1MIntervalPickerView *picker;
@end

@implementation T1MPopTimeViewController

- (void)loadView {
  self.view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doDone:)];
  self.picker = [[T1MIntervalPickerView alloc] init];
  self.picker.translatesAutoresizingMaskIntoConstraints = NO;
  self.view.backgroundColor = [T1MColor systemBackgroundColor];
  [self.view addSubview:self.picker];
  [NSLayoutConstraint activateConstraints:@[
    [self.picker.topAnchor tm_constraintEqualToSystemSpacingBelowAnchor:self.view.topAnchor multiplier:1],
    [self.picker.leadingAnchor tm_constraintEqualToSystemSpacingAfterAnchor:self.view.leadingAnchor multiplier:1],
    [self.view.trailingAnchor tm_constraintEqualToSystemSpacingAfterAnchor: self.picker.trailingAnchor multiplier:1],
    [self.view.bottomAnchor tm_constraintEqualToSystemSpacingBelowAnchor: self.picker.bottomAnchor multiplier:1],
  ]];
}

- (void)doDone:(id)sender {
  [self dismissViewControllerAnimated:YES completion:^{
    // Called on iOS 15 iPhone.
    [self.presentationDelegate didDismissPresentation];
  }];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  if ([self isBeingDismissed]) {
    // Called on iOS 9 iPad.
    [self.presentationDelegate didDismissPresentation];
  }
}

- (CGSize)preferredContentSize {
  return self.picker.intrinsicContentSize;
}


- (void)setSeconds:(NSUInteger)seconds {
  if (!self.isViewLoaded) {
    [self loadView];
  }
  self.picker.countDownDuration = seconds;
}

- (NSUInteger)seconds {
  return self.picker.countDownDuration;
}

@end
