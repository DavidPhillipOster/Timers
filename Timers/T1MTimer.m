//  Timer.m
//  Timers
//
//  Created by David Phillip Oster on 8/18/22.
//
#import "T1MTimer.h"

#import "Heartbeat.h"
#import "Sound.h"
#import <AVFoundation/AVFoundation.h>

static NSString *const kMaxSeconds = @"max";
static NSString *const kRunState = @"runState";
static NSString *const kLabel = @"label";
static NSString *const kAlarmName = @"alarmName";
static NSString *const kTargetTime = @"target";
static NSString *const kUUIDName = @"uuid";

static AVSpeechSynthesizer *sSynthesizer;

@interface T1MTimer () <HeartbeatProtocol>
@property(nonatomic, readwrite) NSTimeInterval targetTime;
@property(nonatomic, readwrite) NSUUID *uuid;
@end

@implementation T1MTimer

+ (AVSpeechSynthesizer *)synthesizer {
  if (sSynthesizer == nil) {
    sSynthesizer = [[AVSpeechSynthesizer alloc] init];
  }
  return sSynthesizer;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _uuid = [NSUUID UUID];
  }
  return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [self init];
  if (self) {
    NSNumber *maxSeconds = dict[kMaxSeconds];
    if (maxSeconds) { _maxSeconds = maxSeconds.integerValue; }
    NSNumber *targetTime = dict[kTargetTime];
    if (targetTime) { _targetTime = targetTime.doubleValue; }
    _label = dict[kLabel];
    _alarmName = dict[kAlarmName];

    NSString *uuidString = dict[kUUIDName];
    if (uuidString.length) { _uuid = [[NSUUID alloc] initWithUUIDString:uuidString]; }

    // do this last.
    NSNumber *runState = dict[kRunState];
    if (runState) {
      NSInteger n = runState.integerValue;
      if (RunStateIdle <= n && n <= RunStateAlarming) {
        [self setRunState: (RunState)n];
      }
    }
  }
  return self;
}

- (NSDictionary *)asDictionary {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  if (_maxSeconds) { dict[kMaxSeconds] = @(_maxSeconds); }
  if (_targetTime) { dict[kTargetTime] = @(_targetTime); }
  if (_label.length) { dict[kLabel] = _label; }
  if (_alarmName.length) { dict[kAlarmName] = _alarmName; }
  if (_uuid) { dict[kUUIDName] = [_uuid UUIDString]; }
  if (_runState) { dict[kRunState] = @((int)_runState); }
  return dict;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
  T1MTimer *other = [[[self class] allocWithZone:zone] init];
  if (other) {
    other.maxSeconds = self.maxSeconds;
    other.targetTime = self.targetTime;
    other.runState = self.runState;
    other.label = self.label;
    other.alarmName = self.alarmName;
    // don't trigger delegate methods until after we've set these.
    other.delegate = self.delegate;
  }
  return other;
}

- (NSUInteger)hash {
  return self.maxSeconds ^ self.label.hash ^ self.alarmName.hash;
}

- (BOOL)isEqual:(id)object {
  // don't compare uuids.
  if (object == self) { return YES; }
  if ([[object class] isKindOfClass:[self class]]) {
    T1MTimer *other = (T1MTimer *)object;
    return other.maxSeconds == self.maxSeconds &&
      other.targetTime == self.targetTime &&
      other.runState == self.runState &&
      (other.label == self.label || [other.label isEqual: self.label]) &&
      (other.alarmName == self.alarmName || [other.alarmName isEqual: self.alarmName]);
  }
  return NO;
}

// Alarming Timers are 'larger' than running timers, which are larger than idle timers,
// Timers that will go off further in the future are larger.
- (NSComparisonResult)compare:(id)object {
  T1MTimer *other = (T1MTimer *)object;
  NSComparisonResult result = NSOrderedAscending;
  if ([[object class] isKindOfClass:[self class]]) {
    if([self isEqual:other]){
      result = NSOrderedSame;
    } else if (self.runState != other.runState) {
      result = 0 < ((int)self.runState - (int)other.runState) ? NSOrderedAscending : NSOrderedDescending;
    } else if (self.targetTime != other.targetTime) {
      result = 0 < (self.targetTime - other.targetTime) ? NSOrderedAscending : NSOrderedDescending;
    } else if (self.maxSeconds != other.maxSeconds) {
      result = 0 < (self.maxSeconds - other.maxSeconds) ? NSOrderedAscending : NSOrderedDescending;
    }
  }
  return result;
}

- (void)heartDidBeat:(NSNumber *)counter {
  if (self.runState == RunStateRunning && 0 < self.maxSeconds && 0 < self.targetTime) {
    NSTimeInterval now = [counter doubleValue];
    NSTimeInterval tick = self.targetTime - now;
    if (0 <= tick) {
      [self.delegate secondsRemainingChanged:self];
    } else {
      [self setRunState:RunStateAlarming];
      [self.delegate alarmTickChanged:self];
    }
  } else if (self.runState == RunStateAlarming) {
    [self.delegate alarmTickChanged:self];
  }
}

- (NSTimeInterval)secondsRemaining {
  if (self.targetTime) {
    NSTimeInterval result = self.targetTime - Heartbeat.sharedInstance.previousHeartBeat;
    return 0 < result ? result : 0;
  }
  return 0;
}

- (void)setLabel:(NSString *)label {
  if (![_label isEqual:label] ) {
    _label = label;
    [self.delegate labelChanged:self];
  }
}

- (void)setMaxSeconds:(NSInteger)maxSeconds {
  if (_maxSeconds != maxSeconds) {
    _maxSeconds = maxSeconds;
    [self.delegate maxSecondsChanged:self];
  }
}

- (void)setRunState:(RunState)runState {
  if (_runState != runState) {
    _runState = runState;
    switch (runState) {
    case RunStateIdle:
      [Heartbeat.sharedInstance removeSubscriber:self];
      self.targetTime = 0;
      break;
    case RunStateRunning:
      [Heartbeat.sharedInstance addSubscriber:self];
      self.targetTime = self.maxSeconds + Heartbeat.sharedInstance.previousHeartBeat;
      break;
    case RunStateAlarming: {
        NSString *alarmName = self.alarmName;
        if (alarmName.length == 0) {
          alarmName = @"Spell";
        }
        alarmName = [alarmName stringByAppendingPathExtension:@"caf"];
        [Sound.sharedInstance playResource:alarmName completion:[self completion]];
      }
      break;
    }
    [self.delegate stateChanged:self];
  }
}

// return nil if the label is nil. Otherwise, a completion that will speak the name.
- (void (^)(void))completion {
  NSString *label = self.label;
  AVSpeechSynthesizer *synthesizer = self.class.synthesizer;
  if (0 < label.length && nil != synthesizer) {
    return ^{
      AVSpeechUtterance *utter = [AVSpeechUtterance speechUtteranceWithString:label];
      if (utter) {
        [synthesizer speakUtterance:utter];
      }
    };
  }
  return nil;
}

@end
