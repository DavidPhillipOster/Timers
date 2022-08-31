//
//  Sound.m
//  Chimes
//
//  Created by david on 1/13/16.
//  Copyright © 2016 David Phillip Oster. All rights reserved.
//

#import "Sound.h"

#import <AudioToolbox/AudioToolbox.h>

@interface Sound()
@property(nonatomic) NSMutableDictionary *soundIds;
@end

static Sound *sSound = nil;

@implementation Sound

+ (instancetype)sharedInstance {
  if (nil == sSound) {
    sSound = [[self alloc] init];
  }
  return sSound;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _soundIds = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)dealloc {
 for(NSNumber *n in _soundIds) {
    UInt32 ident = (UInt32)[n unsignedIntegerValue];
    AudioServicesDisposeSystemSoundID(ident);
  }
}

- (void)play:(NSURL *)url completion:(void (^)(void))completion {
  UInt32 ident = 0;
  NSNumber *n = _soundIds[url];
  if (nil == n) {
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &ident);
    if (0 != ident) {
      _soundIds[url] = @(ident);
    }
  } else {
    ident = (UInt32)[n unsignedIntegerValue];
  }
  if (ident) {
    if (completion) {
      AudioServicesPlayAlertSoundWithCompletion(ident, completion);
    } else {
      AudioServicesPlayAlertSound(ident);
    }
  }
}

- (void)playResource:(NSString *)filename completion:(void (^)(void))completion {
  NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
  NSString *filePath = [resourcePath stringByAppendingPathComponent:filename];
  [self play:[NSURL fileURLWithPath:filePath] completion:completion];
}

@end
