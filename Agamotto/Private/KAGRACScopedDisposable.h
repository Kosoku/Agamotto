//
//  KAGRACScopedDisposable.h
//  ReactiveCocoa
//
//  Created by Josh Abernathy on 3/28/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "KAGRACDisposable.h"

/// A disposable that calls its own -dispose when it is dealloc'd.
@interface KAGRACScopedDisposable : KAGRACDisposable

/// Creates a new scoped disposable that will also dispose of the given
/// disposable when it is dealloc'd.
+ (instancetype)scopedDisposableWithDisposable:(KAGRACDisposable *)disposable;

@end
