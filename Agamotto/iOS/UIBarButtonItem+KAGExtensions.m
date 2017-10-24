//
//  UIBarButtonItem+KAGExtensions.m
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

#import "UIBarButtonItem+KAGExtensions.h"
#import "KAGAction.h"
#import "NSObject+KAGExtensions.h"

#import <Stanley/KSTScopeMacros.h>

#import <objc/runtime.h>

static void *kKAGActionKey = &kKAGActionKey;
static void *kKAGEnabledKey = &kKAGEnabledKey;

@implementation UIBarButtonItem (KAGExtensions)

@dynamic KAG_action;
- (KAGAction *)KAG_action {
    return objc_getAssociatedObject(self, kKAGActionKey);
}
- (void)setKAG_action:(KAGAction *)KAG_action {
    objc_setAssociatedObject(self, kKAGActionKey, KAG_action, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    id<KAGObserver> observer = objc_getAssociatedObject(self, kKAGEnabledKey);
    
    [observer stopObserving];
    
    if (KAG_action == nil) {
        return;
    }
    
    kstWeakify(self);
    observer = [KAG_action KAG_addObserverForKeyPath:@kstKeypath(KAG_action,enabled) options:NSKeyValueObservingOptionInitial block:^(NSString * _Nonnull keyPath, id  _Nullable value, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        kstStrongify(self);
        [self setEnabled:KAG_action.isEnabled];
    }];
    
    objc_setAssociatedObject(self, kKAGEnabledKey, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setTarget:self];
    [self setAction:@selector(_KAG_executeAction:)];
}

- (IBAction)_KAG_executeAction:(id)sender {
    [self.KAG_action execute:sender];
}

@end
