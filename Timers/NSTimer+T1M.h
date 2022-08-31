#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer(CountDownDoc)
+ (NSTimer *)addedTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)sel repeats:(BOOL)repeats;
@end

NS_ASSUME_NONNULL_END
