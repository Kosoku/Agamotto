//
//  NSObject+KAGExtensions.m
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

#import "NSObject+KAGExtensions.h"
#import "NSObject+RACKVOWrapper.h"
#import "RACCompoundDisposable.h"

@interface RACDisposable (KAGExtensionsPrivate) <KAGObserver>

@end

@implementation RACDisposable (KAGExtensionsPrivate)

- (void)stopObserving {
    [self dispose];
}

@end

@implementation NSObject (KAGExtensions)

+ (id<KAGObserver>)KAG_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(KAGObserverBlock)block; {
    return [self KAG_addObserver:observer forKeyPath:keyPath options:0 block:block];
}
+ (id<KAGObserver>)KAG_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(KAGObserverBlock)block; {
    return [self KAG_addObserver:observer forKeyPaths:@[keyPath] options:options block:block];
}
+ (id<KAGObserver>)KAG_addObserver:(NSObject *)observer forKeyPaths:(id<NSFastEnumeration>)keyPaths options:(NSKeyValueObservingOptions)options block:(KAGObserverBlock)block; {
    NSMutableArray *disposables = [[NSMutableArray alloc] init];
    
    for (NSString *keyPath in keyPaths) {
        RACDisposable *disposable = [observer rac_observeKeyPath:keyPath options:options observer:observer block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
            block(keyPath, value, change);
        }];
        
        [disposables addObject:disposable];
    }
    
    return [RACCompoundDisposable compoundDisposableWithDisposables:disposables];
}

- (id<KAGObserver>)KAG_addObserverForKeyPath:(NSString *)keyPath block:(KAGObserverBlock)block; {
    return [self KAG_addObserverForKeyPath:keyPath options:0 block:block];
}
- (id<KAGObserver>)KAG_addObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(KAGObserverBlock)block; {
    return [self KAG_addObserverForKeyPaths:@[keyPath] options:options block:block];
}
- (id<KAGObserver>)KAG_addObserverForKeyPaths:(id<NSFastEnumeration>)keyPaths options:(NSKeyValueObservingOptions)options block:(KAGObserverBlock)block; {
    return [self.class KAG_addObserver:self forKeyPaths:keyPaths options:options block:block];
}

@end
