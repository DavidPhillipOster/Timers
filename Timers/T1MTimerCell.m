//  TimerCell.m
//  Timers
//
//  Created by David Phillip Oster on 8/18/22.
//

#import "T1MTimerCell.h"

#import "Heartbeat.h"
#import "T1MColor.h"
#import "T1MTimer.h"
#import "TimeIntervalFormatter.h"
#import "T1MPopTimeViewController.h"
#import "UIView+T1M.h"

@interface T1MTimerCell ()
@property(nonatomic) UILabel *counter;
@property(nonatomic) UISwitch *notIdle;
@property(nonatomic) UIProgressView *progress;
@property(nonatomic) UILabel *endTime;
@end

static TimeIntervalFormatter *sTimeIntervalFormatter;
static NSDateFormatter *sTimeFormatter;

// Thanks to https://medium.com/@georgetsifrikas/embedding-uitextview-inside-uitableviewcell-9a28794daf01
@implementation T1MTimerCell

+ (TimeIntervalFormatter *)timeIntervalFormatter {
  if (nil == sTimeIntervalFormatter) {
    sTimeIntervalFormatter = [[TimeIntervalFormatter alloc] init];
  }
  return sTimeIntervalFormatter;
}

+ (NSDateFormatter *)timeFormatter {
  if (sTimeFormatter == nil) {
    sTimeFormatter = [[NSDateFormatter alloc] init];
    sTimeFormatter.dateStyle = NSDateFormatterNoStyle;
    sTimeFormatter.timeStyle = NSDateFormatterShortStyle;
  }
  return sTimeFormatter;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _textField = [[UITextField alloc] initWithFrame:self.contentView.frame];
    _textField.translatesAutoresizingMaskIntoConstraints = NO;
    UIFont *textFieldFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    if (IsIpadMode()) {
      textFieldFont = [textFieldFont fontWithSize:textFieldFont.pointSize * 2];
    }
    _textField.font = textFieldFont;
    _textField.textColor = [T1MColor labelColor];
    _textField.backgroundColor = [T1MColor clearColor];
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.contentView addSubview:_textField];

    _progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _progress.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_progress];

    _endTime = [[UILabel alloc] init];
    _endTime.translatesAutoresizingMaskIntoConstraints = NO;
    _endTime.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    [self.contentView addSubview:_endTime];

    CGRect frame = self.contentView.frame;
    frame.size.width = 150;
    _counter = [[UILabel alloc] initWithFrame:frame];
    [_counter addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCounter:)]];
    UIFont *counterFont = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
    CGFloat counterFontScale = IsIpadMode() ? 3 : 1.5;
    counterFont = [counterFont fontWithSize:counterFont.pointSize * counterFontScale];
    _counter.font = counterFont;
    _counter.translatesAutoresizingMaskIntoConstraints = NO;
    _counter.textAlignment = NSTextAlignmentRight;
    _counter.userInteractionEnabled = YES;
    [_counter setText: @"1:99:99"];
    [self.contentView addSubview:_counter];

    _notIdle = [[UISwitch alloc] init];
    _notIdle.translatesAutoresizingMaskIntoConstraints = NO;
    [_notIdle addTarget:self action:@selector(notIdleChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_notIdle];

    _endTime.backgroundColor = [T1MColor clearColor];
    _progress.backgroundColor = [T1MColor clearColor];

    self.contentView.backgroundColor = [T1MColor clearColor];
    self.backgroundColor = [T1MColor clearColor];

    // Note: I'd originally written the layout in layoutSubView{}, but iOS was ignoring my code when I switched from light to dark mode.

    // if text is too long, try for multiline text
    [_textField setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [_textField setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];

    // use extra space to horizontally stretch the textfield, not the counter.
    [_textField setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [_counter setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    // vertically, stretch counter and textfield, Don't stretch end time.
    [_textField setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    [_counter setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    [_endTime setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    static CGFloat marginX = 5;
    [NSLayoutConstraint activateConstraints:@[
      // H:!-counter-notIdle-textField-|
      [_counter.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:marginX],
      [_notIdle.leftAnchor constraintEqualToAnchor:_counter.rightAnchor constant:marginX],
      [_textField.leftAnchor constraintEqualToAnchor:_notIdle.rightAnchor constant:marginX],
      [self.contentView.rightAnchor constraintEqualToAnchor:_textField.rightAnchor constant:marginX],

      // H: notIdle-progress-endtime-|
      [_progress.leftAnchor constraintEqualToAnchor:_notIdle.rightAnchor constant:marginX],
      [_endTime.leftAnchor constraintEqualToAnchor:_progress.rightAnchor constant:marginX],
      [self.contentView.rightAnchor constraintEqualToAnchor:_endTime.rightAnchor constant:marginX],

      // Vertically, counter is bound to top and bottom, idle is centered.
      [_counter.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
      [_counter.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
      [_notIdle.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],

      // V: |-textField-endTime-| , progress is centered in endTime.
      [_textField.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
      [_textField.bottomAnchor constraintEqualToAnchor:_endTime.topAnchor],
      [_endTime.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
      [_progress.centerYAnchor constraintEqualToAnchor:_endTime.centerYAnchor],
    ]];
  }
  return self;
}

- (CGSize)intrinsicContentSize {
  CGFloat height = MAX(_counter.intrinsicContentSize.height, _textField.intrinsicContentSize.height);
  return CGSizeMake(UIViewNoIntrinsicMetric, height);
}

-(void)didTapCounter:(UIGestureRecognizer*)gestureRecognizer {
  [self.delegate didTapTimeLabel:self.counter];
}

- (void)notIdleChanged:(UISwitch *)sender {
  if (sender.on) {
    if (0 < self.timer.maxSeconds) {
      self.timer.runState = RunStateRunning;
    }
  } else {
    self.timer.runState = RunStateIdle;
  }
}

- (void)awakeFromNib {
  [super awakeFromNib];
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)setTimer:(T1MTimer *)timer {
  _timer = timer;
  if (timer) {
    NSString *name = timer.label;
    if (name.length == 0) {
      name = @"\u00A0"; // nonbreaking space.
    }
    self.textField.text = name;
    if (timer.maxSeconds <= 0) {
      self.counter.text = @"";
      self.counter.textColor = T1MColor.labelColor;
      self.notIdle.on = NO;
      self.notIdle.enabled = NO;
      self.progress.hidden = YES;
      self.endTime.hidden = YES;
    } else {
      self.notIdle.on = !(timer.runState == RunStateIdle);
      self.notIdle.enabled = YES;
      switch (timer.runState) {
      case RunStateIdle:
        self.counter.text = [self.class.timeIntervalFormatter stringFromInteger:timer.maxSeconds];
        self.counter.textColor = T1MColor.labelColor;
        self.progress.hidden = YES;
        self.endTime.hidden = YES;
        break;
      case RunStateRunning:
        self.counter.text = [self.class.timeIntervalFormatter stringFromInteger:timer.secondsRemaining];
        self.counter.textColor = T1MColor.systemGreenColor;
        self.progress.progress = (timer.maxSeconds-timer.secondsRemaining) / (double) timer.maxSeconds;
        self.progress.hidden = NO;
        self.endTime.text = [self.class.timeFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:timer.targetTime]];
        self.endTime.hidden = NO;
        break;
      case RunStateAlarming:
        {
          NSInteger halfSecondsRemaining = (NSInteger)(Heartbeat.sharedInstance.previousHeartBeat*2);
          self.counter.text = [self.class.timeIntervalFormatter stringFromInteger:timer.maxSeconds];
          self.counter.textColor = (halfSecondsRemaining & 1) ? T1MColor.systemRedColor : T1MColor.clearColor;
          self.progress.hidden = NO;
          self.progress.progress = (timer.maxSeconds-timer.secondsRemaining) / (double) timer.maxSeconds;
          self.endTime.text = [self.class.timeFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:timer.targetTime]];
          self.endTime.hidden = NO;
        }
        break;
      }
    }
  }
}

@end
