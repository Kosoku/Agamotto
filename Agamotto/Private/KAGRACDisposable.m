//
//  KAGRACDisposable.m
//  ReactiveCocoa
//
//  Created by Josh Abernathy on 3/16/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "KAGRACDisposable.h"
#import "KAGRACScopedDisposable.h"

#import <stdatomic.h>

@interface KAGRACDisposable () {
	// A copied block of type void (^)(void) containing the logic for disposal,
	// a pointer to `self` if no logic should be performed upon disposal, or
	// NULL if the receiver is already disposed.
	//
	// This should only be used atomically.
	void * volatile _disposeBlock;
}

@end

@implementation KAGRACDisposable

#pragma mark Properties

- (BOOL)isDisposed {
	return _disposeBlock == NULL;
}

#pragma mark Lifecycle

- (id)init {
	self = [super init];
	if (self == nil) return nil;

	_disposeBlock = (__bridge void *)self;
    atomic_thread_fence(memory_order_seq_cst);

	return self;
}

- (id)initWithBlock:(void (^)(void))block {
	NSCParameterAssert(block != nil);

	self = [super init];
	if (self == nil) return nil;

	_disposeBlock = (void *)CFBridgingRetain([block copy]); 
	atomic_thread_fence(memory_order_seq_cst);

	return self;
}

+ (instancetype)disposableWithBlock:(void (^)(void))block {
	return [[self alloc] initWithBlock:block];
}

- (void)dealloc {
	if (_disposeBlock == NULL || _disposeBlock == (__bridge void *)self) return;

	CFRelease(_disposeBlock);
	_disposeBlock = NULL;
}

#pragma mark Disposal

- (void)dispose {
	void (^disposeBlock)(void) = NULL;

	while (YES) {
		void *blockPtr = _disposeBlock;
        if (atomic_compare_exchange_strong((volatile _Atomic(void*)*)&_disposeBlock, &blockPtr, NULL)) {
			if (blockPtr != (__bridge void *)self) {
				disposeBlock = CFBridgingRelease(blockPtr);
			}

			break;
		}
	}

	if (disposeBlock != nil) disposeBlock();
}

#pragma mark Scoped Disposables

- (KAGRACScopedDisposable *)asScopedDisposable {
	return [KAGRACScopedDisposable scopedDisposableWithDisposable:self];
}

@end
