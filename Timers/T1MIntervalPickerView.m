//  T1MIntervalPickerView.m
//  Timers
//
//  Created by David Phillip Oster on 8/18/22.
//

#import "T1MIntervalPickerView.h"

@interface T1MIntervalPickerView () <UIPickerViewDelegate, UIPickerViewDataSource>
@property(nonatomic) UIPickerView *picker;
@property(nonatomic) UIView *clipperView;
@property(nonatomic) UIStackView *hStack;
@end

@implementation T1MIntervalPickerView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  [self initIntervalPickerView];
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  [self initIntervalPickerView];
  return self;
}

- (void)initIntervalPickerView {
  UILabel *H = [[UILabel alloc] init];
  H.text = @"H";
  H.textAlignment = NSTextAlignmentCenter;
  UILabel *M = [[UILabel alloc] init];
  M.text = @"M";
  M.textAlignment = NSTextAlignmentCenter;
  UILabel *S = [[UILabel alloc] init];
  S.text = @"S";
  S.textAlignment = NSTextAlignmentCenter;
  self.hStack = [[UIStackView alloc] initWithArrangedSubviews: @[H, M, S]];
  self.hStack.axis = UILayoutConstraintAxisHorizontal;
  self.hStack.distribution = UIStackViewDistributionEqualCentering;
  [self addSubview:self.hStack];
  self.clipperView = [[UIView alloc] init];
  self.clipperView.clipsToBounds = YES;
  [self addSubview:self.clipperView];
  self.picker = [[UIPickerView alloc] init];
  self.picker.delegate = self;
  self.picker.dataSource = self;
  [self.clipperView addSubview:self.picker];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.hStack.frame = CGRectMake(20, 0, 120, 30);
  self.clipperView.frame = CGRectMake(0, 30, 160, 160);
  self.picker.center = CGPointMake(160/2, 160/2);
}

- (CGSize)intrinsicContentSize  {
  return CGSizeMake(160, 160+30);
}

- (void)setCountDownDuration:(NSTimeInterval)countDownDuration {
  if (_countDownDuration != countDownDuration) {
    _countDownDuration = countDownDuration;
    [self updatePickerComponents];
  }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
// multiple copies so the minutes and seconds rotors will wrap around.
  switch (component) {
  case 0: return 24;
  case 2: return 4*9;
  case 1:
  default: return 60*9;
  }
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  // my iOS 9 device uses 32-bit NSIntegers.
  switch (component) {
  case 0: return [NSString stringWithFormat:@"%ld", (long)(row % 24)];
  case 1: return [NSString stringWithFormat:@"%ld", (long)(row % 60)];
  case 2: return [NSString stringWithFormat:@"%ld", (long)(row % 4)*15];
  default: return [NSString stringWithFormat:@"%ld", (long)row];
  }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
  return 50;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
  return 30;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
// reset minutes and seconds rotors to the center of their range.
  switch(component){
    case 1: [self.picker selectRow:(row % 60) + 60*5 inComponent:2 animated:NO];
       break;
    case 2: [self.picker selectRow:(row % 4) + 4*5 inComponent:2 animated:NO];
      break;
    default:
      break;
  }
  [self updateCountownDuration];
}

- (void)updateCountownDuration {
  NSUInteger totalSeconds = MAX(0, [self.picker selectedRowInComponent:0]) * 60 * 60 +
    (MAX(0, [self.picker selectedRowInComponent:1]) % 60) * 60 +
    (MAX(0, [self.picker selectedRowInComponent:2]) % 4) * 15;
  _countDownDuration = totalSeconds;
}

- (void)updatePickerComponents {
  NSUInteger hours = ((NSUInteger)_countDownDuration) / (60*60);
  NSUInteger minutes = (((NSUInteger)_countDownDuration) % (60*60)) / 60;
  NSUInteger seconds = ((NSUInteger)_countDownDuration) % 60;
  [self.picker selectRow:hours inComponent:0 animated:NO];
  [self.picker selectRow:minutes + 60*5 inComponent:1 animated:NO];
  [self.picker selectRow:seconds/15 + 4*5 inComponent:2 animated:NO];
}

@end
