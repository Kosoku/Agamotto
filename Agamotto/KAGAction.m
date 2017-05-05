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

@interface KAGAction ()
@property (copy,nonatomic) KAGAsynchronousBlock asynchronousBlock;
@property (strong,nonatomic) NSMapTable *executionObserversToCompletionBlocks;
@end

@implementation KAGAction

- (instancetype)initWithAsynchronousBlock:(KAGAsynchronousBlock)asynchronousBlock {
    if (!(self = [super init]))
        return nil;
    
    _asynchronousBlock = [asynchronousBlock copy];
    _executionObserversToCompletionBlocks = [NSMapTable weakToStrongObjectsMapTable];
    
    return self;
}

- (void)addExecutionObserver:(id)observer completion:(dispatch_block_t)completion {
    [self.executionObserversToCompletionBlocks setObject:completion forKey:observer];
}

- (void)execute {
    if (!self.isEnabled) {
        return;
    }
    
    [self setEnabled:NO];
    
    self.asynchronousBlock(^{
        for (dispatch_block_t block in self.executionObserversToCompletionBlocks.objectEnumerator) {
            block();
        }
        
        [self setEnabled:YES];
    });
}

@end
