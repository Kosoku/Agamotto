//
//  KAGRACScopedDisposable.m
//  ReactiveCocoa
//
//  Created by Josh Abernathy on 3/28/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "KAGRACScopedDisposable.h"

@implementation KAGRACScopedDisposable

#pragma mark Lifecycle

+ (instancetype)scopedDisposableWithDisposable:(KAGRACDisposable *)disposable {
	return [self disposableWithBlock:^{
		[disposable dispose];
	}];
}

- (void)dealloc {
	[self dispose];
}

#pragma mark KAGRACDisposable

- (KAGRACScopedDisposable *)asScopedDisposable {
	// totally already are
	return self;
}

@end
