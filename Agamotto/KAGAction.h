//
//  KAGAction.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Typedef for a block that takes an NSError as its argument, signaling success or failure.
 
 @param error The error or nil
 */
typedef void(^KAGErrorBlock)(NSError * _Nullable error);
/**
 Typedef for a block that takes a KAGErrorBlock which the block should invoke upon completion of the async activity.
 
 @param completion The block to invoke when the activity is complete
 */
typedef void(^KAGAsynchronousBlock)(KAGErrorBlock completion);

/**
 KAGAction represents a repeatable action that can be assigned to various UI controls and executed when the user interacts with the control.
 */
@interface KAGAction : NSObject

/**
 Set and get whether the receiver is enabled. The value of this property affects whether execute invokes the async block provided on initialization.
 
 The default is NO.
 */
@property (assign,nonatomic,getter=isEnabled) BOOL enabled;
/**
 Get whether the receiver is executing the provided async block.
 
 The default is NO.
 */
@property (readonly,nonatomic,getter=isExecuting) BOOL executing;

/**
 Creates and returns an instance of the receiver with the provided *asynchronousBlock* which will be invoked whenever the execute method is called.
 
 @param asynchronousBlock The async block to invoke
 @return The initialized instance
 */
- (instancetype)initWithAsynchronousBlock:(KAGAsynchronousBlock)asynchronousBlock NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Add an execution observer with the provided *completion* block that will be invoked whenever the *asynchronousBlock* provided above finishes executing. The observer can act on the provided error if necessary.
 
 @param observer The execution observer
 @param completion The block to invoke each time execution finishes
 */
- (void)addExecutionObserver:(id)observer completion:(KAGErrorBlock)completion;
/**
 Remove an execution observer. This does not need to be called on dealloc, the receiver hold weak references to all execution observers.
 
 @param observer The execution observer
 */
- (void)removeExecutionObserver:(id)observer;

/**
 Invoke the provided *asynchronousBlock* and notify all execution observers when the blocks completion block is invoked.
 */
- (void)execute;

@end

NS_ASSUME_NONNULL_END
