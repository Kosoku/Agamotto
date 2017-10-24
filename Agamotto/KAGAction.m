//
//  KAGAction.m
//  Agamotto
//
//  Created by William Towe on 5/5/17.
//  Copyright © 2017 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "KAGAction.h"

#import <Stanley/KSTScopeMacros.h>

@interface KAGAction ()
@property (readwrite,nonatomic,getter=isExecuting) BOOL executing;
@property (copy,nonatomic) KAGAsynchronousSenderValueErrorBlock asynchronousBlock;
@property (strong,nonatomic) NSMapTable<id, KAGErrorBlock> *executionObserversToCompletionBlocks;
@property (strong,nonatomic) NSMapTable<id, KAGValueErrorBlock> *executionValueObserversToCompletionBlocks;
@property (strong,nonatomic) NSMapTable<id, dispatch_block_t> *willExecuteObserversToBlocks;
@end

@implementation KAGAction {
    BOOL _didChangeEnabledWhileExecuting;
}

+ (BOOL)automaticallyNotifiesObserversOfEnabled {
    return NO;
}

- (instancetype)initWithAsynchronousErrorBlock:(KAGAsynchronousErrorBlock)errorBlock {
    return [self initWithAsynchronousValueErrorBlock:^(KAGValueErrorBlock  _Nonnull completion) {
        errorBlock(^(NSError *error){
            completion(nil,error);
        });
    }];
}
- (instancetype)initWithAsynchronousValueErrorBlock:(KAGAsynchronousValueErrorBlock)valueErrorBlock {
    return [self initWithAsynchronousSenderValueErrorBlock:^(id  _Nullable sender, KAGValueErrorBlock  _Nonnull completion) {
        valueErrorBlock(^(id value, NSError *error){
            completion(value,error);
        });
    }];
}
- (instancetype)initWithAsynchronousSenderValueErrorBlock:(KAGAsynchronousSenderValueErrorBlock)senderValueErrorBlock {
    if (!(self = [super init]))
        return nil;
    
    _enabled = YES;
    _asynchronousBlock = [senderValueErrorBlock copy];
    _executionObserversToCompletionBlocks = [NSMapTable weakToStrongObjectsMapTable];
    _executionValueObserversToCompletionBlocks = [NSMapTable weakToStrongObjectsMapTable];
    _willExecuteObserversToBlocks = [NSMapTable weakToStrongObjectsMapTable];
    
    return self;
}

- (void)addExecutionObserver:(id)observer completion:(KAGErrorBlock)completion {
    [self addWillExecuteObserver:observer willExecuteBlock:nil completion:completion];
}
- (void)addExecutionValueObserver:(id)observer completion:(KAGValueErrorBlock)completion {
    [self addWillExecuteValueObserver:observer willExecuteBlock:nil completion:completion];
}
- (void)addWillExecuteObserver:(id)observer block:(dispatch_block_t)block {
    [self.willExecuteObserversToBlocks setObject:block forKey:observer];
}
- (void)addWillExecuteObserver:(id)observer willExecuteBlock:(dispatch_block_t)willExecuteBlock completion:(KAGErrorBlock)completion {
    if (willExecuteBlock != nil) {
        [self.willExecuteObserversToBlocks setObject:willExecuteBlock forKey:observer];
    }
    [self.executionObserversToCompletionBlocks setObject:completion forKey:observer];
}
- (void)addWillExecuteValueObserver:(id)observer willExecuteBlock:(dispatch_block_t)willExecuteBlock completion:(KAGValueErrorBlock)completion {
    if (willExecuteBlock != nil) {
        [self.willExecuteObserversToBlocks setObject:willExecuteBlock forKey:observer];
    }
    [self.executionValueObserversToCompletionBlocks setObject:completion forKey:observer];
}
- (void)removeExecutionObserver:(id)observer {
    [self.executionObserversToCompletionBlocks removeObjectForKey:observer];
    [self.executionValueObserversToCompletionBlocks removeObjectForKey:observer];
    [self.willExecuteObserversToBlocks removeObjectForKey:observer];
}

- (void)execute {
    [self execute:nil];
}
- (void)execute:(id)sender {
    if (!self.isEnabled ||
        self.isExecuting) {
        
        return;
    }
    
    [self setEnabled:NO];
    [self setExecuting:YES];
    
    _didChangeEnabledWhileExecuting = NO;
    
    for (dispatch_block_t block in self.willExecuteObserversToBlocks.objectEnumerator) {
        block();
    }
    
    self.asynchronousBlock(sender,^(id value, NSError *error){
        for (KAGErrorBlock block in self.executionObserversToCompletionBlocks.objectEnumerator) {
            block(error);
        }
        for (KAGValueErrorBlock block in self.executionValueObserversToCompletionBlocks.objectEnumerator) {
            block(value,error);
        }
        
        [self setExecuting:NO];
        
        if (!_didChangeEnabledWhileExecuting) {
            [self setEnabled:YES];
        }
    });
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled == enabled) {
        return;
    }
    
    [self willChangeValueForKey:@kstKeypath(self,enabled)];
    
    _enabled = enabled;
    
    if (self.isExecuting) {
        _didChangeEnabledWhileExecuting = YES;
    }
    
    [self didChangeValueForKey:@kstKeypath(self,enabled)];
}

@end
