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
#import <Agamotto/KAGObserver.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Typedef for a block that is invoked on each KVO change, passing the *keyPath* that changed, the new value and the KVO change dictionary.
 
 @param keyPath the key path that changed
 @param value The new value, can be nil
 @param change The KVO change dictionary
 */
typedef void(^KAGKVOObserverBlock)(NSString *keyPath, id _Nullable value, NSDictionary<NSKeyValueChangeKey, id> *change);
/**
 Typedef for a block that is invoked on each notification change, passing the notification object.
 
 @param notification The notification object
 */
typedef void(^KAGNotificationObserverBlock)(NSNotification *notification);

@interface NSObject (KAGExtensions)

/**
 Sets up KVO observation on the *target* for the provided *keyPaths* and returns an object that can be used to manually stop observation.
 
 @param target The target to observe
 @param keyPaths The key paths to observe
 @param options The KVO options to use
 @param block The block that will be invoked on each change
 @return An object that can be used to manually stop the observation
 */
+ (id<KAGObserver>)KAG_observeTarget:(NSObject *)target forKeyPaths:(id<NSFastEnumeration>)keyPaths options:(NSKeyValueObservingOptions)options block:(KAGKVOObserverBlock)block;

/**
 Returns `[self KAG_addObserverForKeyPaths:@[keyPath] options:options block:block]`.
 
 @param keyPath The key path to observe
 @param options The KVO options to use
 @param block The block that will be invoked on each change
 @return An object that can be used to manually stop the observation
 */
- (id<KAGObserver>)KAG_addObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(KAGKVOObserverBlock)block;
/**
 Returns `[self.class KAG_observeTarget:self keyPaths:keyPaths options:options block:block]`.
 
 @param keyPaths The key paths to observe
 @param options The KVO options to use
 @param block The block that will be invoked on each change
 @return An object that can be used to manually stop the observation
 */
- (id<KAGObserver>)KAG_addObserverForKeyPaths:(id<NSFastEnumeration>)keyPaths options:(NSKeyValueObservingOptions)options block:(KAGKVOObserverBlock)block;

/**
 Returns `[self KAG_addObserverToNotificationCenter:nil notificationName:notificationName object:object block:block]`.
 
 @param notificationName The notification name to filter notifications for
 @param object The object to filter notifications for
 @param block The block to invoke when a matching notification is received
 @return An object that can be used to manually stop the observation
 */
- (id<KAGObserver>)KAG_addObserverForNotificationName:(nullable NSNotificationName)notificationName object:(nullable id)object block:(KAGNotificationObserverBlock)block;
/**
 Loops through each item in *notificationNames* and calls `[self KAG_addObserverToNotificationCenter:nil notificationName:notificationName object:object block:block]`.
 
 @param notificationNames The notification names to filter notifications for
 @param object The object to filter notifications for
 @param block The block to invoke when a matching notification is received
 @return An object that can be used to manually stop the observation
 */
- (id<KAGObserver>)KAG_addObserverForNotificationNames:(id<NSFastEnumeration>)notificationNames object:(nullable id)object block:(KAGNotificationObserverBlock)block;
/**
 Sets up notification observing on *notificationCenter* for the provided *notificationName* and *object*, invoking *block* when a matching notification is received. Returns an object that can be used to manually stop the observation, otherwise the observation ends when the receiver is deallocated. If nil is passed for *notificationCenter*, [NSNotificationCenter defaultCenter] is used.
 
 @param notificationCenter The notification center to subscribe to
 @param notificationName The notification name to filter notifications for
 @param object The object to filter notifications for
 @param block The block to invoke when a matching notification is received
 @return An object that can be used to manually stop the observation
 */
- (id<KAGObserver>)KAG_addObserverToNotificationCenter:(nullable NSNotificationCenter *)notificationCenter notificationName:(nullable NSNotificationName)notificationName object:(nullable id)object block:(KAGNotificationObserverBlock)block;
/**
 Sets up notification observing on *notificationCenter* for the provided *notificationNames* and *object*, invoking *block* when a matching notification is received. Returns an object that can be used to manually stop the observation, otherwise the observation ends when the receiver is deallocated. If nil is passed for *notificationCenter*, [NSNotificationCenter defaultCenter] is used.
 
 @param notificationCenter The notification center to subscribe to
 @param notificationNames The notification names to filter notifications for
 @param object The object to filter notifications for
 @param block The block to invoke when a matching notification is received
 @return An object that can be used to manually stop the observation
 */
- (id<KAGObserver>)KAG_addObserverToNotificationCenter:(nullable NSNotificationCenter *)notificationCenter notificationNames:(id<NSFastEnumeration>)notificationNames object:(nullable id)object block:(KAGNotificationObserverBlock)block;

@end

NS_ASSUME_NONNULL_END
