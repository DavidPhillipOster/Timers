//  Timer.h
//  Timers
//
//  Created by David Phillip Oster on 8/18/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum RunState {
  RunStateIdle,
  RunStateRunning,
  RunStateAlarming
} RunState;

@protocol T1MTimerDelegate;

@interface T1MTimer : NSObject <NSCopying>

@property(nonatomic, nullable, weak) id<T1MTimerDelegate> delegate;

/// negative means not set.
@property(nonatomic) NSInteger maxSeconds;

/// counts down, in seconds, to zero.
@property(nonatomic, readonly) NSTimeInterval secondsRemaining;

// TimeSinceReferenceData when the timer is scheduled to finish else 0.
@property(nonatomic, readonly) NSTimeInterval targetTime;

/// if runState==RunStateRunning &&  0 < maxSeconds && 0 < tick
@property(nonatomic) RunState runState;

@property(nonatomic, nullable) NSString *label;

@property(nonatomic, nullable) NSString *alarmName;

@property(nonatomic, readonly) NSUUID *uuid;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)asDictionary;

@end

@protocol T1MTimerDelegate <NSObject>

- (void)labelChanged:(T1MTimer *)timer;

- (void)maxSecondsChanged:(T1MTimer *)timer;

- (void)secondsRemainingChanged:(T1MTimer *)timer;

- (void)stateChanged:(T1MTimer *)timer;

- (void)alarmTickChanged:(T1MTimer *)timer;

@end

NS_ASSUME_NONNULL_END
