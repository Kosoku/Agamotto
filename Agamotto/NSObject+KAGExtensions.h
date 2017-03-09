//
//  NSObject+KAGExtensions.h
//  Agamotto
//
//  Created by William Towe on 3/9/17.
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
 Typedef for a block that is invoked on each KVO change, passing the *keyPath* that changed, the new value and the KVO change dictionary.
 
 @param keyPath the key path that changed
 @param value The new value, can be nil
 @param change The KVO change dictionary
 */
typedef void(^KAGObserverBlock)(NSString *keyPath, id _Nullable value, NSDictionary<NSKeyValueChangeKey, id> *change);

/**
 Protocol for objects returned by the below methods, which can be used to manually stop observation, but is not required. Observation is stopped automatically on deallocation.
 */
@protocol KAGObserver <NSObject>
@required
/**
 Returns the set of key paths being observed.
 */
@property (readonly,copy,nonatomic) NSSet<NSString *> *observingKeyPaths;
/**
 Stops observation of the key paths returned by observingKeyPaths. The method is thread safe and can be called multiple times safely.
 */
- (void)stopObserving;
@end

@interface NSObject (KAGExtensions)

/**
 Returns `[self KAG_observeTarget:target forKeyPath:keyPath options:0 block:block]`.
 
 @param target The target to observe
 @param keyPath The key path to observe
 @param block The block that will be invoked on each change
 @return An object that can be used to manually stop the observation
 */
+ (id<KAGObserver>)KAG_observeTarget:(NSObject *)target forKeyPath:(NSString *)keyPath block:(KAGObserverBlock)block;
/**
 Returns `[self KAG_observeTarget:target forKeyPath:keyPath options:options block:block]`.
 
 @param target The target to observe
 @param keyPath The key path to observe
 @param options The KVO options to use
 @param block The block that will be invoked on each change
 @return An object that can be used to manually stop the observation
 */
+ (id<KAGObserver>)KAG_observeTarget:(NSObject *)target forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(KAGObserverBlock)block;
/**
 Sets up KVO observation on the *target* for the provided *keyPaths* and returns an object that can be used to manually stop observation.
 
 @param target The target to observe
 @param keyPaths The key paths to observe
 @param options The KVO options to use
 @param block The block that will be invoked on each change
 @return An object that can be used to manually stop the observation
 */
+ (id<KAGObserver>)KAG_observeTarget:(NSObject *)target forKeyPaths:(id<NSFastEnumeration>)keyPaths options:(NSKeyValueObservingOptions)options block:(KAGObserverBlock)block;

/**
 Returns `[self KAG_addObserverForKeyPath:keyPath options:0 block:block]`.
 
 @param keyPath The key path to observe
 @param block The block that will be invoked on each change
 @return An object that can be used to manually stop the observation
 */
- (id<KAGObserver>)KAG_addObserverForKeyPath:(NSString *)keyPath block:(KAGObserverBlock)block;
/**
 Returns `[self KAG_addObserverForKeyPaths:@[keyPath] options:0 block:block]`.
 
 @param keyPath The key path to observe
 @param options The KVO options to use
 @param block The block that will be invoked on each change
 @return An object that can be used to manually stop the observation
 */
- (id<KAGObserver>)KAG_addObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(KAGObserverBlock)block;
/**
 Returns `[self.class KAG_observeTarget:self keyPaths:keyPaths options:options block:block]`.
 
 @param keyPaths The key paths to observe
 @param options The KVO options to use
 @param block The block that will be invoked on each change
 @return An object that can be used to manually stop the observation
 */
- (id<KAGObserver>)KAG_addObserverForKeyPaths:(id<NSFastEnumeration>)keyPaths options:(NSKeyValueObservingOptions)options block:(KAGObserverBlock)block;

@end

NS_ASSUME_NONNULL_END
