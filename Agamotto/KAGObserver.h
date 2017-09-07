//
//  KAGObserver.h
//  Agamotto
//
//  Created by William Towe on 4/29/17.
//  Copyright © 2017 Kosoku Interactive, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol for objects returned by the below methods, which can be used to manually stop observation, but is not required. Observation is stopped automatically on deallocation.
 */
@protocol KAGObserver <NSObject>
@required
/**
 Returns the set of key paths being observed.
 */
@property (readonly,copy,nonatomic,nullable) NSSet<NSString *> *observingKeyPaths;
/**
 Returns the notification names being observed.
 */
@property (readonly,copy,nonatomic,nullable) NSSet<NSNotificationName> *observingNotificationNames;
/**
 Stops observation of the key paths returned by observingKeyPaths. The method is thread safe and can be called multiple times safely.
 */
- (void)stopObserving;
@end

NS_ASSUME_NONNULL_END
