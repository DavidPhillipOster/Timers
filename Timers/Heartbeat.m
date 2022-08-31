//
//  Hearbeat.m
//  CountDown
//
//  Created by David Phillip Oster on 9/2/20.
//

#import "Heartbeat.h"

#import "NSTimer+T1M.h"

@interface Heartbeat ()
@property (nonatomic) NSTimer *heartbeat;
@property (nonatomic) NSHashTable *heartbeatClients;
@property (nonatomic, readwrite) NSTimeInterval previousHeartBeat;

@end

static Heartbeat *instance = nil;

@implementation Heartbeat

+ (instancetype)sharedInstance {
  if (instance == nil) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[self alloc] init];
      instance.previousHeartBeat = [NSDate timeIntervalSinceReferenceDate];
    });
  }
  return instance;
}

- (void)addSubscriber:(id)sender {
  if (self.heartbeatClients == nil){
    self.heartbeatClients = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:1];
  }
  [self.heartbeatClients addObject:sender];
  if (0 < [self.heartbeatClients count] && nil == self.heartbeat) {
    self.heartbeat = [NSTimer addedTimerWithTimeInterval:0.5 target:self selector:@selector(didBeat:) repeats:YES];
  }
}

- (void)removeSubscriber:(id)sender {
  [self.heartbeatClients removeObject:sender];
  if (0 == [self.heartbeatClients count]) {
    [self.heartbeat invalidate];
    self.heartbeat = nil;
  }
}

- (void)didBeat:(NSTimer *)timer {
  self.previousHeartBeat = [NSDate timeIntervalSinceReferenceDate];
  [[self.heartbeatClients allObjects] makeObjectsPerformSelector:@selector(heartDidBeat:) withObject:@(self.previousHeartBeat)];
}

@end
