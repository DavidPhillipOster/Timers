//  AppDelegate.m
//  Timers
//
//  Created by David Phillip Oster on 8/18/22.
//

#import "T1MAppDelegate.h"
#import "T1MTimerListController.h"
#import "T1MHistoryController.h"
#import <UserNotifications/UserNotifications.h>

// Currently, the history controller, below the mainController, is unfinished. Set HAS_HISTORY FALSE to never create it.
#define HAS_HISTORY FALSE

@interface T1MAppDelegate ()

@end

@implementation T1MAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  CGRect bounds = UIScreen.mainScreen.bounds;
  self.window = [[UIWindow alloc] initWithFrame:bounds];
  T1MTimerListController *vc = [[T1MTimerListController alloc] init];
  self.mainController = vc;
  T1MHistoryController *hc = nil;
#if HAS_HISTORY
  hc = [[T1MHistoryController alloc] init];
#endif
  UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController: hc ?: vc];
  if (hc) {
    [nc pushViewController:vc animated:NO];
  }
  [self.window setRootViewController:nc];
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
}


@end
