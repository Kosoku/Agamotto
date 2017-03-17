//
//  KAGRACCompoundDisposable.m
//  ReactiveCocoa
//
//  Created by Josh Abernathy on 11/30/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "KAGRACCompoundDisposable.h"

#import <os/lock.h>

// The number of child disposables for which space will be reserved directly in
// `KAGRACCompoundDisposable`.
//
// This number has been empirically determined to provide a good tradeoff
// between performance, memory usage, and `KAGRACCompoundDisposable` instance size
// in a moderately complex GUI application.
//
// Profile any change!
#define KAGRACCompoundDisposableInlineCount 2

static CFMutableArrayRef RACCreateDisposablesArray(void) {
	// Compare values using only pointer equality.
	CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
	callbacks.equal = NULL;

	return CFArrayCreateMutable(NULL, 0, &callbacks);
}

@interface KAGRACCompoundDisposable () {
	// Used for synchronization.
	os_unfair_lock _spinLock;

	#if KAGRACCompoundDisposableInlineCount
	// A fast array to the first N of the receiver's disposables.
	//
	// Once this is full, `_disposables` will be created and used for additional
	// disposables.
	//
	// This array should only be manipulated while _spinLock is held.
	KAGRACDisposable *_inlineDisposables[KAGRACCompoundDisposableInlineCount];
	#endif

	// Contains the receiver's disposables.
	//
	// This array should only be manipulated while _spinLock is held. If
	// `_disposed` is YES, this may be NULL.
	CFMutableArrayRef _disposables;

	// Whether the receiver has already been disposed.
	//
	// This ivar should only be accessed while _spinLock is held.
	BOOL _disposed;
}

@end

@implementation KAGRACCompoundDisposable

#pragma mark Properties

- (BOOL)isDisposed {
	os_unfair_lock_lock(&_spinLock);
	BOOL disposed = _disposed;
	os_unfair_lock_unlock(&_spinLock);

	return disposed;
}

#pragma mark Lifecycle

+ (instancetype)compoundDisposable {
	return [[self alloc] initWithDisposables:nil];
}

+ (instancetype)compoundDisposableWithDisposables:(NSArray *)disposables {
	return [[self alloc] initWithDisposables:disposables];
}

- (id)initWithDisposables:(NSArray *)otherDisposables {
	self = [self init];
	if (self == nil) return nil;
    
    _spinLock = OS_UNFAIR_LOCK_INIT;
    
	#if KAGRACCompoundDisposableInlineCount
	[otherDisposables enumerateObjectsUsingBlock:^(KAGRACDisposable *disposable, NSUInteger index, BOOL *stop) {
		_inlineDisposables[index] = disposable;

		// Stop after this iteration if we've reached the end of the inlined
		// array.
		if (index == KAGRACCompoundDisposableInlineCount - 1) *stop = YES;
	}];
	#endif

	if (otherDisposables.count > KAGRACCompoundDisposableInlineCount) {
		_disposables = RACCreateDisposablesArray();

		CFRange range = CFRangeMake(KAGRACCompoundDisposableInlineCount, (CFIndex)otherDisposables.count - KAGRACCompoundDisposableInlineCount);
		CFArrayAppendArray(_disposables, (__bridge CFArrayRef)otherDisposables, range);
	}

	return self;
}

- (id)initWithBlock:(void (^)(void))block {
	KAGRACDisposable *disposable = [KAGRACDisposable disposableWithBlock:block];
	return [self initWithDisposables:@[ disposable ]];
}

- (void)dealloc {
	#if KAGRACCompoundDisposableInlineCount
	for (unsigned i = 0; i < KAGRACCompoundDisposableInlineCount; i++) {
		_inlineDisposables[i] = nil;
	}
	#endif

	if (_disposables != NULL) {
		CFRelease(_disposables);
		_disposables = NULL;
	}
}

#pragma mark Addition and Removal

- (void)addDisposable:(KAGRACDisposable *)disposable {
	NSCParameterAssert(disposable != self);
	if (disposable == nil || disposable.disposed) return;

	BOOL shouldDispose = NO;

	os_unfair_lock_lock(&_spinLock);
	{
		if (_disposed) {
			shouldDispose = YES;
		} else {
			#if KAGRACCompoundDisposableInlineCount
			for (unsigned i = 0; i < KAGRACCompoundDisposableInlineCount; i++) {
				if (_inlineDisposables[i] == nil) {
					_inlineDisposables[i] = disposable;
					goto foundSlot;
				}
			}
			#endif

			if (_disposables == NULL) _disposables = RACCreateDisposablesArray();
			CFArrayAppendValue(_disposables, (__bridge void *)disposable);

//			if (KAGRACCompoundDisposable_ADDED_ENABLED()) {
//				KAGRACCompoundDisposable_ADDED(self.description.UTF8String, disposable.description.UTF8String, CFArrayGetCount(_disposables) + KAGRACCompoundDisposableInlineCount);
//			}

		#if KAGRACCompoundDisposableInlineCount
		foundSlot:;
		#endif
		}
	}
	os_unfair_lock_unlock(&_spinLock);

	// Performed outside of the lock in case the compound disposable is used
	// recursively.
	if (shouldDispose) [disposable dispose];
}

- (void)removeDisposable:(KAGRACDisposable *)disposable {
	if (disposable == nil) return;

	os_unfair_lock_lock(&_spinLock);
	{
		if (!_disposed) {
			#if KAGRACCompoundDisposableInlineCount
			for (unsigned i = 0; i < KAGRACCompoundDisposableInlineCount; i++) {
				if (_inlineDisposables[i] == disposable) _inlineDisposables[i] = nil;
			}
			#endif

			if (_disposables != NULL) {
				CFIndex count = CFArrayGetCount(_disposables);
				for (CFIndex i = count - 1; i >= 0; i--) {
					const void *item = CFArrayGetValueAtIndex(_disposables, i);
					if (item == (__bridge void *)disposable) {
						CFArrayRemoveValueAtIndex(_disposables, i);
					}
				}

//				if (KAGRACCompoundDisposable_REMOVED_ENABLED()) {
//					KAGRACCompoundDisposable_REMOVED(self.description.UTF8String, disposable.description.UTF8String, CFArrayGetCount(_disposables) + KAGRACCompoundDisposableInlineCount);
//				}
			}
		}
	}
	os_unfair_lock_unlock(&_spinLock);
}

#pragma mark KAGRACDisposable

static void disposeEach(const void *value, void *context) {
	KAGRACDisposable *disposable = (__bridge id)value;
	[disposable dispose];
}

- (void)dispose {
	#if KAGRACCompoundDisposableInlineCount
	KAGRACDisposable *inlineCopy[KAGRACCompoundDisposableInlineCount];
	#endif

	CFArrayRef remainingDisposables = NULL;

	os_unfair_lock_lock(&_spinLock);
	{
		_disposed = YES;

		#if KAGRACCompoundDisposableInlineCount
		for (unsigned i = 0; i < KAGRACCompoundDisposableInlineCount; i++) {
			inlineCopy[i] = _inlineDisposables[i];
			_inlineDisposables[i] = nil;
		}
		#endif

		remainingDisposables = _disposables;
		_disposables = NULL;
	}
	os_unfair_lock_unlock(&_spinLock);

	#if KAGRACCompoundDisposableInlineCount
	// Dispose outside of the lock in case the compound disposable is used
	// recursively.
	for (unsigned i = 0; i < KAGRACCompoundDisposableInlineCount; i++) {
		[inlineCopy[i] dispose];
	}
	#endif

	if (remainingDisposables == NULL) return;

	CFIndex count = CFArrayGetCount(remainingDisposables);
	CFArrayApplyFunction(remainingDisposables, CFRangeMake(0, count), &disposeEach, NULL);
	CFRelease(remainingDisposables);
}

@end
