//  UIView+T1M.h
//  RemEvent1
//
//  Created by David Phillip Oster on 8/16/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

BOOL IsIpadMode(void);

NSURL *FolderURL(void);

@interface UIView (T1M)

@property (nonatomic,readonly) UIEdgeInsets tm_safeAreaInsets;

- (nullable __kindof UIView *)tm_superviewOfClass:(Class)class;

@end

// Compatability before iOS 11
@interface NSLayoutXAxisAnchor (T1M)

- (NSLayoutConstraint *)tm_constraintEqualToSystemSpacingAfterAnchor:(NSLayoutXAxisAnchor *)anchor multiplier:(CGFloat)multiplier __attribute__((warn_unused_result));

@end

// Compatability before iOS 11
@interface NSLayoutYAxisAnchor (T1M)

- (NSLayoutConstraint *)tm_constraintEqualToSystemSpacingBelowAnchor:(NSLayoutYAxisAnchor *)anchor multiplier:(CGFloat)multiplier __attribute__((warn_unused_result));

@end

NS_ASSUME_NONNULL_END

