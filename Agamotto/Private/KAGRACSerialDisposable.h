//
//  KAGRACSerialDisposable.h
//  ReactiveCocoa
//
//  Created by Justin Spahr-Summers on 2013-07-22.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "KAGRACDisposable.h"

/// A disposable that contains exactly one other disposable and allows it to be
/// swapped out atomically.
@interface KAGRACSerialDisposable : KAGRACDisposable

/// The inner disposable managed by the serial disposable.
///
/// This property is thread-safe for reading and writing. However, if you want to
/// read the current value _and_ write a new one atomically, use
/// -swapInDisposable: instead.
///
/// Disposing of the receiver will also dispose of the current disposable set for
/// this property, then set the property to nil. If any new disposable is set
/// after the receiver is disposed, it will be disposed immediately and this
/// property will remain set to nil.
@property (atomic, strong) KAGRACDisposable *disposable;

/// Creates a serial disposable which will wrap the given disposable.
///
/// disposable - The value to set for `disposable`. This may be nil.
///
/// Returns a KAGRACSerialDisposable, or nil if an error occurs.
+ (instancetype)serialDisposableWithDisposable:(KAGRACDisposable *)disposable;

/// Atomically swaps the receiver's `disposable` for `newDisposable`.
///
/// newDisposable - The new value for `disposable`. If the receiver has already
///                 been disposed, this disposable will be too, and `disposable`
///                 will remain set to nil. This argument may be nil.
///
/// Returns the previous value for the `disposable` property.
- (KAGRACDisposable *)swapInDisposable:(KAGRACDisposable *)newDisposable;

@end
