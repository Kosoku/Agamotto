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
 Typedef for a block that takes a value and an NSError as its arguments, signaling success or failure.
 
 @param value The value or nil
 @param error The error or nil
 */
typedef void(^KAGValueErrorBlock)(id _Nullable value, NSError * _Nullable error);
/**
 Typedef for a block that takes a KAGErrorBlock which the block should invoke upon completion of the async activity.
 
 @param completion The block to invoke when the activity is complete
 */
typedef void(^KAGAsynchronousErrorBlock)(KAGErrorBlock completion);
/**
 Typedef for a block that takes a KAGValueErrorBlock which the block should invoke upon completion of the async activity.
 
 @param completion The block to invoke when the activity is complete
 */
typedef void(^KAGAsynchronousValueErrorBlock)(KAGValueErrorBlock completion);
/**
 Typedef for a block that takes a sender and a KAGValueErrorBlock which the block should invoke upon completion of the async activity.
 
 @param sender The sender of the async action, usually a UI control
 @param completion The block to invoke when the activity is complete
 */
typedef void(^KAGAsynchronousSenderValueErrorBlock)(id _Nullable sender, KAGValueErrorBlock completion);

/**
 KAGAction represents a repeatable action that can be assigned to various UI controls and executed when the user interacts with the control.
 */
@interface KAGAction : NSObject

/**
 Set and get whether the receiver is enabled. The value of this property affects whether execute invokes the async block provided on initialization.
 
 The default is YES.
 */
@property (assign,nonatomic,getter=isEnabled) BOOL enabled;
/**
 Get whether the receiver is executing the provided async block.
 
 The default is NO.
 */
@property (readonly,nonatomic,getter=isExecuting) BOOL executing;

/**
 Creates and returns an instance of the receiver with the provided *errorBlock* which will be invoked whenever the execute method is called.
 
 @param errorBlock The async block to invoke
 @return The initialized instance
 */
- (instancetype)initWithAsynchronousErrorBlock:(KAGAsynchronousErrorBlock)errorBlock;
/**
 Creates and returns an instance of the receiver with the provided *valueErrorBlock* which will be invoked whenever the execute method is called.
 
 @param valueErrorBlock The async block to invoke
 @return The initialized instance
 */
- (instancetype)initWithAsynchronousValueErrorBlock:(KAGAsynchronousValueErrorBlock)valueErrorBlock;
/**
 Creates and returns an instance of the receiver with the provided *senderValueErrorBlock* which will be invoked whenever the execute method is called.
 
 @param senderValueErrorBlock The async block to invoke
 @return The initialized instance
 */
- (instancetype)initWithAsynchronousSenderValueErrorBlock:(KAGAsynchronousSenderValueErrorBlock)senderValueErrorBlock NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Add an execution observer with the provided *completion* block that will be invoked whenever the *asynchronousBlock* provided above finishes executing. The observer can act on the provided error if necessary.
 
 @param observer The execution observer
 @param completion The block to invoke each time execution finishes
 */
- (void)addExecutionObserver:(id)observer completion:(KAGErrorBlock)completion;
/**
 Add an execution observer with the provided *completion* block that will be invoked whenever the *asynchronousBlock* provided above finishes executing. The observer can act on the provided value and error if necessary.
 
 @param observer The execution observer
 @param completion The block to invoke each time execution finishes
 */
- (void)addExecutionValueObserver:(id)observer completion:(KAGValueErrorBlock)completion;
/**
 Add an will execute observer will the provided *block* that will be invoked immediately before execution begins.
 
 @param observer The will execute observer
 @param block The will execute block
 */
- (void)addWillExecuteObserver:(id)observer block:(dispatch_block_t)block;
/**
 Add an execution observer with the provided *completion* block that will be invoked whenever the *asynchronousBlock* provided above finishes executing. Add an optional will execute block that will be invoked immediately before execution begins. The observer can act on the provided error if necessary.
 
 @param observer The execution observer
 @param willExecuteBlock The block to invoke before execution begins
 @param completion The block to invoke each time execution finishes
 */
- (void)addWillExecuteObserver:(id)observer willExecuteBlock:(nullable dispatch_block_t)willExecuteBlock completion:(KAGErrorBlock)completion;
/**
 Add an execution observer with the provided *completion* block that will be invoked whenever the *asynchronousBlock* provided above finishes executing. Add an optional will execute block that will be invoked immediately before execution begins. The observer can act on the provided value and error if necessary.
 
 @param observer The execution observer
 @param willExecuteBlock The block to invoke before execution begins
 @param completion The block to invoke each time execution finishes
 */
- (void)addWillExecuteValueObserver:(id)observer willExecuteBlock:(nullable dispatch_block_t)willExecuteBlock completion:(KAGValueErrorBlock)completion;
/**
 Remove an execution observer and will execute observer. This does not need to be called on dealloc, the receiver holds weak references to all execution observers.
 
 @param observer The execution observer
 */
- (void)removeExecutionObserver:(id)observer;

/**
 Calls execute:, passing nil.
 */
- (void)execute;
/**
 Invoke the provided *asynchronousBlock* and notify all execution observers when the blocks completion block is invoked.
 */
- (void)execute:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
