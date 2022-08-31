#import "NSTimer+T1M.h"

@implementation NSTimer(CountDownDoc)
+ (NSTimer *)addedTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)sel repeats:(BOOL)repeats {
  NSTimer *timer = [NSTimer timerWithTimeInterval:seconds  target:target selector:sel userInfo:nil repeats:repeats];
  NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
  [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
  [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
#ifdef NSModalPanelRunLoopMode
  [runLoop addTimer:timer forMode:NSModalPanelRunLoopMode];
#endif
#ifdef NSEventTrackingRunLoopMode
  [runLoop addTimer:timer forMode:NSEventTrackingRunLoopMode];
#endif
  return timer;
}
@end

