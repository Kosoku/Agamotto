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
#import "NSObject+KAGRACKVOWrapper.h"
#import "KAGRACCompoundDisposable.h"

#import <objc/runtime.h>

@interface KAGNotificationWrapper : NSObject
@property (weak,nonatomic) id target;
@property (copy,nonatomic) KAGNotificationObserverBlock block;

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter notificationName:(NSNotificationName)notificationName object:(id)object block:(KAGNotificationObserverBlock)block;

- (void)stopObserving;
@end

@implementation KAGNotificationWrapper

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter notificationName:(NSNotificationName)notificationName object:(id)object block:(KAGNotificationObserverBlock)block {
    if (!(self = [super init]))
        return nil;
    
    _block = [block copy];
    
    [notificationCenter addObserver:self selector:@selector(_observeNotification:) name:notificationName object:object];
    
    return self;
}

- (void)stopObserving; {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_observeNotification:(NSNotification *)note {
    self.block(note);
}
        
@end

@interface NSObject (KAGPrivateExtensions)
@property (readonly,nonatomic) NSMutableSet *_KAG_notificationWrappers;
@end

@implementation NSObject (KAGPrivateExtensions)

- (NSMutableSet *)_KAG_notificationWrappers {
    NSMutableSet *retval = objc_getAssociatedObject(self, _cmd);
    if (retval == nil) {
        retval = [[NSMutableSet alloc] init];
        
        objc_setAssociatedObject(self, _cmd, retval, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return retval;
}

@end

@interface KAGRACDisposable (KAGExtensionsPrivate) <KAGObserver>
@property (readwrite,copy,nonatomic) NSSet<NSString *> *observingKeyPaths;
@property (readwrite,copy,nonatomic) NSNotificationName observingNotificationName;
@end

@implementation KAGRACDisposable (KAGExtensionsPrivate)

static void *kKAG_ObservingKeyPathsKey = &kKAG_ObservingKeyPathsKey;

@dynamic observingKeyPaths;
- (NSSet<NSString *> *)observingKeyPaths {
    return objc_getAssociatedObject(self, kKAG_ObservingKeyPathsKey);
}
- (void)setObservingKeyPaths:(NSSet<NSString *> *)observingKeyPaths {
    objc_setAssociatedObject(self, kKAG_ObservingKeyPathsKey, observingKeyPaths, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

static void *kKAG_ObservingNotificationNameKey = &kKAG_ObservingNotificationNameKey;

@dynamic observingNotificationName;
- (NSNotificationName)observingNotificationName {
    return objc_getAssociatedObject(self, kKAG_ObservingNotificationNameKey);
}
- (void)setObservingNotificationName:(NSNotificationName)observingNotificationName {
    objc_setAssociatedObject(self, kKAG_ObservingNotificationNameKey, observingNotificationName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)stopObserving {
    [self dispose];
}

@end

@implementation NSObject (KAGExtensions)

+ (id<KAGObserver>)KAG_observeTarget:(NSObject *)target forKeyPaths:(id<NSFastEnumeration>)keyPaths options:(NSKeyValueObservingOptions)options block:(KAGKVOObserverBlock)block; {
    NSMutableSet *uniqueKeyPaths = [[NSMutableSet alloc] init];
    
    for (NSString *keyPath in keyPaths) {
        [uniqueKeyPaths addObject:keyPath];
    }
    
    NSMutableArray *disposables = [[NSMutableArray alloc] init];
    
    for (NSString *keyPath in uniqueKeyPaths) {
        KAGRACDisposable *disposable = [target rac_observeKeyPath:keyPath options:options observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
            block(keyPath, value, change);
        }];
        
        [disposables addObject:disposable];
    }
    
    KAGRACCompoundDisposable *retval = [KAGRACCompoundDisposable compoundDisposableWithDisposables:disposables];
    
    [retval setObservingKeyPaths:uniqueKeyPaths];
    
    return retval;
}

- (id<KAGObserver>)KAG_addObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(KAGKVOObserverBlock)block {
    return [self KAG_addObserverForKeyPaths:@[keyPath] options:options block:block];
}
- (id<KAGObserver>)KAG_addObserverForKeyPaths:(id<NSFastEnumeration>)keyPaths options:(NSKeyValueObservingOptions)options block:(KAGKVOObserverBlock)block; {
    return [self.class KAG_observeTarget:self forKeyPaths:keyPaths options:options block:block];
}

- (id<KAGObserver>)KAG_addObserverForNotificationName:(NSNotificationName)notificationName object:(id)object block:(KAGNotificationObserverBlock)block {
    return [self KAG_addObserverToNotificationCenter:nil notificationName:notificationName object:object block:block];
}
- (id<KAGObserver>)KAG_addObserverToNotificationCenter:(NSNotificationCenter *)notificationCenter notificationName:(NSNotificationName)notificationName object:(id)object block:(KAGNotificationObserverBlock)block {
    if (notificationCenter == nil) {
        notificationCenter = [NSNotificationCenter defaultCenter];
    }
    
    KAGNotificationWrapper *wrapper = [[KAGNotificationWrapper alloc] initWithNotificationCenter:notificationCenter notificationName:notificationName object:object block:block];
    
    NSMutableSet *wrappers = self._KAG_notificationWrappers;
    
    @synchronized(wrappers) {
        [wrappers addObject:wrapper];
    }
    
    KAGRACDisposable *retval = [KAGRACDisposable disposableWithBlock:^{
        [wrapper stopObserving];
        
        @synchronized(wrappers) {
            [wrappers removeObject:wrapper];
        }
    }];
    
    [retval setObservingNotificationName:notificationName];
    
    return retval;
}

@end
