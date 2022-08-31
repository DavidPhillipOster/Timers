//
//  TimeIntervalFormatter.h
//  CountDown
//
//  Created by David Phillip Oster on 2/16/09.
//   Copyright 2009 David Phillip Oster.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeIntervalFormatter : NSFormatter

- (nullable NSString *)stringForObjectValue:(nullable id)obj;

- (BOOL)getObjectValue:(out id _Nullable * _Nullable)obj
             forString:(NSString *)string
      errorDescription:(out NSString * _Nullable * _Nullable)error;


- (BOOL)isPartialStringValid:(NSString * _Nonnull * _Nonnull)partialStringPtr
       proposedSelectedRange:(nullable NSRangePointer)proposedSelRangePtr
              originalString:(NSString *)origString
       originalSelectedRange:(NSRange)origSelRange
            errorDescription:(NSString * _Nullable * _Nullable)error;

- (NSInteger)integerFromString:(NSString *)s;

- (NSString *)stringFromInteger:(NSInteger)i;

@end

NS_ASSUME_NONNULL_END
