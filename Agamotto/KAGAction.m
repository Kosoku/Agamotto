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
@property (copy,nonatomic) KAGAsynchronousValueErrorBlock asynchronousBlock;
@property (strong,nonatomic) NSMapTable<id, KAGErrorBlock> *executionObserversToCompletionBlocks;
@property (strong,nonatomic) NSMapTable<id, KAGValueErrorBlock> *executionValueObserversToCompletionBlocks;
@end

@implementation KAGAction

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
    if (!(self = [super init]))
        return nil;
    
    _enabled = YES;
    _asynchronousBlock = [valueErrorBlock copy];
    _executionObserversToCompletionBlocks = [NSMapTable weakToStrongObjectsMapTable];
    _executionValueObserversToCompletionBlocks = [NSMapTable weakToStrongObjectsMapTable];
    
    return self;
}

- (void)addExecutionObserver:(id)observer completion:(KAGErrorBlock)completion {
    [self.executionObserversToCompletionBlocks setObject:completion forKey:observer];
}
- (void)addExecutionValueObserver:(id)observer completion:(KAGValueErrorBlock)completion {
    [self.executionValueObserversToCompletionBlocks setObject:completion forKey:observer];
}
- (void)removeExecutionObserver:(id)observer {
    [self.executionObserversToCompletionBlocks removeObjectForKey:observer];
    [self.executionValueObserversToCompletionBlocks removeObjectForKey:observer];
}

- (void)execute {
    if (!self.isEnabled || self.isExecuting) {
        return;
    }
    
    [self setEnabled:NO];
    [self setExecuting:YES];
    
    self.asynchronousBlock(^(id value, NSError *error){
        for (KAGErrorBlock block in self.executionObserversToCompletionBlocks.objectEnumerator) {
            block(error);
        }
        for (KAGValueErrorBlock block in self.executionValueObserversToCompletionBlocks.objectEnumerator) {
            block(value,error);
        }
        
        [self setExecuting:NO];
        [self setEnabled:YES];
    });
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled == enabled) {
        return;
    }
    
    [self willChangeValueForKey:@kstKeypath(self,enabled)];
    
    _enabled = enabled;
    
    [self didChangeValueForKey:@kstKeypath(self,enabled)];
}

@end
