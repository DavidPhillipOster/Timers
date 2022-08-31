//  UIView+T1M.m
//  RemEvent
//
//  Created by David Phillip Oster on 8/16/22.
//

#import "UIView+T1M.h"

@implementation UIView (T1M)

- (UIEdgeInsets)tm_safeAreaInsets {
  if (@available(iOS 11.0, *)) {
    return [self safeAreaInsets];
  } else {
    return UIEdgeInsetsZero;
  }
}

- (nullable __kindof UIView *)tm_superviewOfClass:(Class)class {
  UIView *v = self;
  for(; v != nil; v = [v superview]) {
    if ([v isKindOfClass:class]) {
      return v;
    }
  }
  return v;
}

@end

@implementation NSLayoutXAxisAnchor (T1M)

- (NSLayoutConstraint *)tm_constraintEqualToSystemSpacingAfterAnchor:(NSLayoutXAxisAnchor *)anchor multiplier:(CGFloat)multiplier {
  if (@available(iOS 11.0, *)) {
    return [self constraintEqualToSystemSpacingAfterAnchor:anchor multiplier:multiplier];
  } else {
#if DEBUG
    if (multiplier != 1.0) {
      NSLog(@"%@ unexpected multiplier: %@", NSStringFromSelector(_cmd), @(multiplier));
    }
#endif
    return [self constraintEqualToAnchor:anchor];
  }
}

@end

@implementation NSLayoutYAxisAnchor (T1M)

- (NSLayoutConstraint *)tm_constraintEqualToSystemSpacingBelowAnchor:(NSLayoutYAxisAnchor *)anchor multiplier:(CGFloat)multiplier {
  if (@available(iOS 11.0, *)) {
    return [self constraintEqualToSystemSpacingBelowAnchor:anchor multiplier:multiplier];
  } else {
#if DEBUG
    if (multiplier != 1.0) {
      NSLog(@"%@ unexpected multiplier: %@", NSStringFromSelector(_cmd), @(multiplier));
    }
#endif
    return [self constraintEqualToAnchor:anchor];
  }
}

@end


/// Use a popover if we are in full ipad mode. If we are running on iPhone, or iPad split-view, use a nav bar with adone button.
BOOL IsIpadMode(void) {
  if (UIUserInterfaceIdiomPad == UIDevice.currentDevice.userInterfaceIdiom) {
    if (@available(iOS 13.0, *)) {
      UITraitCollection *current = UITraitCollection.currentTraitCollection;
      return UIUserInterfaceSizeClassRegular == current.horizontalSizeClass && UIUserInterfaceSizeClassRegular == current.verticalSizeClass;
    } else {
      return YES;
    }
  }
  return NO;
}

NSURL *FolderURL() {
  NSFileManager *fm = [NSFileManager defaultManager];
  NSURL *folderURL = [[fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject];
  NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  folderURL = [folderURL URLByAppendingPathComponent:bundleIdentifier];
  [fm createDirectoryAtURL:folderURL withIntermediateDirectories:YES attributes:nil error:NULL];
  return folderURL;
}
