//
//  Sound.h
//  Chimes
//
//  Created by david on 1/13/16.
//  Copyright © 2016 David Phillip Oster. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// use the sharedInstance to play a sound
@interface Sound : NSObject

+ (instancetype)sharedInstance;

- (void)play:(NSURL *)url completion:(nullable void (^)(void))completion;

// Assumes the filename is in the bundle.
- (void)playResource:(NSString *)filename completion:(nullable void (^)(void))completion;


@end

NS_ASSUME_NONNULL_END
