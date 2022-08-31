//  T1MPopTimeViewController.h
//  Timers
//
//  Created by David Phillip Oster on 8/18/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PresentationDismisser;

@interface T1MPopTimeViewController : UIViewController
@property(nonatomic, nullable, weak) id<PresentationDismisser> presentationDelegate;
@property(nonatomic) NSUInteger seconds;
@property(nonatomic) NSIndexPath *path;
@end

@protocol PresentationDismisser <NSObject>
- (void)didDismissPresentation;
@end

NS_ASSUME_NONNULL_END
