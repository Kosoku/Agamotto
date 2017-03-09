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

#import <objc/runtime.h>

@interface RACDisposable (KAGExtensionsPrivate) <KAGObserver>
@property (readwrite,copy,nonatomic) NSSet<NSString *> *observingKeyPaths;
@end

@implementation RACDisposable (KAGExtensionsPrivate)

static void *kKAG_ObservingKeyPathsKey = &kKAG_ObservingKeyPathsKey;

@dynamic observingKeyPaths;
- (NSSet<NSString *> *)observingKeyPaths {
    return objc_getAssociatedObject(self, kKAG_ObservingKeyPathsKey);
}
- (void)setObservingKeyPaths:(NSSet<NSString *> *)observingKeyPaths {
    objc_setAssociatedObject(self, kKAG_ObservingKeyPathsKey, observingKeyPaths, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)stopObserving {
    [self dispose];
}

@end

@implementation NSObject (KAGExtensions)

+ (id<KAGObserver>)KAG_observeTarget:(NSObject *)target forKeyPath:(NSString *)keyPath block:(KAGObserverBlock)block; {
    return [self KAG_observeTarget:target forKeyPath:keyPath options:0 block:block];
}
+ (id<KAGObserver>)KAG_observeTarget:(NSObject *)target forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(KAGObserverBlock)block; {
    return [self KAG_observeTarget:target forKeyPaths:@[keyPath] options:options block:block];
}
+ (id<KAGObserver>)KAG_observeTarget:(NSObject *)target forKeyPaths:(id<NSFastEnumeration>)keyPaths options:(NSKeyValueObservingOptions)options block:(KAGObserverBlock)block; {
    NSMutableSet *uniqueKeyPaths = [[NSMutableSet alloc] init];
    
    for (NSString *keyPath in keyPaths) {
        [uniqueKeyPaths addObject:keyPath];
    }
    
    NSMutableArray *disposables = [[NSMutableArray alloc] init];
    
    for (NSString *keyPath in uniqueKeyPaths) {
        RACDisposable *disposable = [target rac_observeKeyPath:keyPath options:options observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
            block(keyPath, value, change);
        }];
        
        [disposables addObject:disposable];
    }
    
    RACCompoundDisposable *retval = [RACCompoundDisposable compoundDisposableWithDisposables:disposables];
    
    [retval setObservingKeyPaths:uniqueKeyPaths];
    
    return retval;
}

- (id<KAGObserver>)KAG_addObserverForKeyPath:(NSString *)keyPath block:(KAGObserverBlock)block; {
    return [self KAG_addObserverForKeyPath:keyPath options:0 block:block];
}
- (id<KAGObserver>)KAG_addObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(KAGObserverBlock)block; {
    return [self KAG_addObserverForKeyPaths:@[keyPath] options:options block:block];
}
- (id<KAGObserver>)KAG_addObserverForKeyPaths:(id<NSFastEnumeration>)keyPaths options:(NSKeyValueObservingOptions)options block:(KAGObserverBlock)block; {
    return [self.class KAG_observeTarget:self forKeyPaths:keyPaths options:options block:block];
}

@end
