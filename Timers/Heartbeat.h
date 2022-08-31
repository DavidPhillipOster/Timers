//
//  Hearbeat.h
//  CountDown
//
//  Created by David Phillip Oster on 9/2/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Twice a second. (So I can blink the alarm state.)
@protocol HeartbeatProtocol <NSObject>
- (void)heartDidBeat:(NSNumber *)counter;
@end

// this is the master one second timer for the app so that multiple active timers tick together.
@interface Heartbeat : NSObject

@property(nonatomic, readonly) NSTimeInterval previousHeartBeat;

+ (instancetype)sharedInstance;

- (void)addSubscriber:(id<HeartbeatProtocol>)sender;
- (void)removeSubscriber:(id<HeartbeatProtocol>)sender;

@end

NS_ASSUME_NONNULL_END
