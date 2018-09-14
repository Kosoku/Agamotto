//
//  UIBarButtonItem+KAGExtensions.h
//  Agamotto
//
//  Created by William Towe on 5/5/17.
//  Copyright © 2018 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class KAGAction;

@interface UIBarButtonItem (KAGExtensions)

/**
 Set and get the KAGAction instance associated with the receiver.
 
 @see KAGAction
 */
@property (strong,nonatomic,nullable) KAGAction *KAG_action;

/**
 Create and return a UIBarButtonItem with *image* and *style* and assign *action* to it.
 
 @param image The bar button item image
 @param style The bar button item style
 @param action The KAGAction for the bar button item
 @return The initialized bar button item
 */
+ (instancetype)KAG_barButtonItemWithImage:(nullable UIImage *)image style:(UIBarButtonItemStyle)style action:(KAGAction *)action;
/**
 Create and return a UIBarButtonItem with *title* and *style* and assign *action* to it.
 
 @param title The bar button item title
 @param style The bar button item style
 @param action The KAGAction for the bar button item
 @return The initialized bar button item
 */
+ (instancetype)KAG_barButtonItemWithTitle:(nullable NSString *)title style:(UIBarButtonItemStyle)style action:(KAGAction *)action;
/**
 Create and return a UIBarButtonItem with *systemItem* and assign *action* to it.
 
 @param systemItem The bar button system item
 @param action The KAGAction for the bar button item
 @return The initialized bar button item
 */
+ (instancetype)KAG_barButtonItemWithSystemItem:(UIBarButtonSystemItem)systemItem action:(KAGAction *)action;

@end

NS_ASSUME_NONNULL_END
