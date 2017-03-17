//
//  NSObject+RACDeallocating.h
//  ReactiveCocoa
//
//  Created by Kazuo Koga on 2013/03/15.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KAGRACCompoundDisposable;
@class KAGRACDisposable;

@interface NSObject (KAGRACDeallocating)

/// The compound disposable which will be disposed of when the receiver is
/// deallocated.
@property (atomic, readonly, strong) KAGRACCompoundDisposable *rac_deallocDisposable;

@end
