//  T1MIntervalPickerView.h
//  Timers
//
//  Created by David Phillip Oster on 8/18/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Pretty much a replacement for UIDatePicker in CountdownTimer mode. But you can set seconds in 5 second increments.
///
/// Works on Mac, (UIDatePicker does not)
/// width:160 height=190 . ignores dynamic fonts.
@interface T1MIntervalPickerView : UIView
@property(nonatomic) NSTimeInterval countDownDuration;
@end

NS_ASSUME_NONNULL_END
