//  main.m
//  Timers
//
//  Created by David Phillip Oster on 8/18/22.
//

#import <UIKit/UIKit.h>
#import "T1MAppDelegate.h"

int main(int argc, char * argv[]) {
  NSString * appDelegateClassName;
  @autoreleasepool {
    // Setup code that might create autoreleased objects goes here.
    appDelegateClassName = NSStringFromClass([T1MAppDelegate class]);
  }
  return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
