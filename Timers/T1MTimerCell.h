//  TimerCell.h
//  Timers
//
//  Created by David Phillip Oster on 8/18/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class T1MTimer;
@class TimeIntervalFormatter;
@protocol T1MTimerCellDelegate;

// Displays a timer and its label.
@interface T1MTimerCell : UITableViewCell

+ (TimeIntervalFormatter *)timeIntervalFormatter;

@property(nonatomic) id<T1MTimerCellDelegate> delegate;
@property(nonatomic) UITextField *textField;
@property(nonatomic) T1MTimer *timer;
@end

@protocol T1MTimerCellDelegate <NSObject>
- (void)didTapTimeLabel:(UILabel *)label;
@end

NS_ASSUME_NONNULL_END
