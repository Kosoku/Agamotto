//
//  KAGRACSerialDisposable.m
//  ReactiveCocoa
//
//  Created by Justin Spahr-Summers on 2013-07-22.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "KAGRACSerialDisposable.h"

#import <os/lock.h>

@interface KAGRACSerialDisposable () {
	// The receiver's `disposable`. This variable must only be referenced while
	// _spinLock is held.
	KAGRACDisposable * _disposable;

	// YES if the receiver has been disposed. This variable must only be modified
	// while _spinLock is held.
	BOOL _disposed;

	// A spinlock to protect access to _disposable and _disposed.
	//
	// It must be used when _disposable is mutated or retained and when _disposed
	// is mutated.
	os_unfair_lock _spinLock;
}

@end

@implementation KAGRACSerialDisposable

#pragma mark Properties

- (BOOL)isDisposed {
	return _disposed;
}

- (KAGRACDisposable *)disposable {
	KAGRACDisposable *result;

	os_unfair_lock_lock(&_spinLock);
	result = _disposable;
	os_unfair_lock_unlock(&_spinLock);

	return result;
}

- (void)setDisposable:(KAGRACDisposable *)disposable {
	[self swapInDisposable:disposable];
}

#pragma mark Lifecycle

+ (instancetype)serialDisposableWithDisposable:(KAGRACDisposable *)disposable {
	KAGRACSerialDisposable *serialDisposable = [[self alloc] init];
	serialDisposable.disposable = disposable;
	return serialDisposable;
}

- (id)initWithBlock:(void (^)(void))block {
	self = [self init];
	if (self == nil) return nil;

	self.disposable = [KAGRACDisposable disposableWithBlock:block];

	return self;
}

#pragma mark Inner Disposable

- (KAGRACDisposable *)swapInDisposable:(KAGRACDisposable *)newDisposable {
	KAGRACDisposable *existingDisposable;
	BOOL alreadyDisposed;

	os_unfair_lock_lock(&_spinLock);
	alreadyDisposed = _disposed;
	if (!alreadyDisposed) {
		existingDisposable = _disposable;
		_disposable = newDisposable;
	}
	os_unfair_lock_unlock(&_spinLock);

	if (alreadyDisposed) {
		[newDisposable dispose];
		return nil;
	}

	return existingDisposable;
}

#pragma mark Disposal

- (void)dispose {
	KAGRACDisposable *existingDisposable;

	os_unfair_lock_lock(&_spinLock);
	if (!_disposed) {
		existingDisposable = _disposable;
		_disposed = YES;
		_disposable = nil;
	}
	os_unfair_lock_unlock(&_spinLock);
	
	[existingDisposable dispose];
}

@end
