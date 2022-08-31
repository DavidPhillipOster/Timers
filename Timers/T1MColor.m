//
//  T1MColor.m
//  Timers
//
//  Created by david on 8/27/22.
//

#import "T1MColor.h"

@implementation T1MColor

+ (UIColor *)labelColor {
  if (@available(iOS 13.0, *)) {
    return [super labelColor];
  } else {
    return [UIColor blackColor];
  }
}
+ (UIColor *)systemBackgroundColor {
  if (@available(iOS 13.0, *)) {
    return [super systemBackgroundColor];
  } else {
    return [UIColor whiteColor];
  }
}

@end
