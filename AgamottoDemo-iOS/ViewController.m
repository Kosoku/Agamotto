//
//  ViewController.m
//  AgamottoDemo-iOS
//
//  Created by William Towe on 3/9/17.
//  Copyright © 2017 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "ViewController.h"

#import <Agamotto/Agamotto.h>

@interface Model : NSObject
@property (copy,nonatomic) NSString *text;
@end

@implementation Model
@end

@interface ViewController ()
@property (weak,nonatomic) IBOutlet UITextField *textField;
@property (weak,nonatomic) IBOutlet UIButton *button;

@property (strong,nonatomic) Model *model;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setModel:[[Model alloc] init]];
    
    [self.textField addTarget:self action:@selector(_textFieldAction:) forControlEvents:UIControlEventEditingChanged];
    [self.button addTarget:self action:@selector(_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self KAG_addObserverForKeyPath:@"model.text" block:^(id value, NSDictionary<NSKeyValueChangeKey,id> *change) {
        NSLog(@"text: %@",value);
    }];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.textField.isFirstResponder) {
        [self.textField becomeFirstResponder];
    }
}

- (IBAction)_textFieldAction:(id)sender {
    [self.model setText:self.textField.text];
}
- (IBAction)_buttonAction:(id)sender {
    [self setModel:[[Model alloc] init]];
}

@end
