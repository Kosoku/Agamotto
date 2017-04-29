//
//  ViewController.m
//  AgamottoDemo-iOS
//
//  Created by William Towe on 3/9/17.
//  Copyright © 2017 Kosoku Interactive, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "ViewController.h"

#import <Agamotto/Agamotto.h>

@interface SubModel : NSObject
@property (copy,nonatomic) NSString *subtext;
@end

@implementation SubModel
@end

@interface Model : NSObject
@property (copy,nonatomic) NSString *text;
@property (strong,nonatomic) SubModel *submodel;
@end

@implementation Model
- (instancetype)init {
    if (!(self = [super init]))
        return nil;
    
    _submodel = [[SubModel alloc] init];
    
    return self;
}

- (void)setText:(NSString *)text {
    _text = [text copy];
    
    [self.submodel setSubtext:_text.uppercaseString];
}
@end

@interface ViewController ()
@property (weak,nonatomic) IBOutlet UITextField *textField;
@property (weak,nonatomic) IBOutlet UIButton *button;

@property (strong,nonatomic) Model *model;
@property (strong,nonatomic) id<KAGObserver> observer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setModel:[[Model alloc] init]];
    
    [self.textField addTarget:self action:@selector(_textFieldAction:) forControlEvents:UIControlEventEditingChanged];
    [self.button addTarget:self action:@selector(_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.observer = [self KAG_addObserverForKeyPaths:@[@"model.text",@"model.submodel.subtext"] options:NSKeyValueObservingOptionInitial block:^(NSString *keyPath, id value, NSDictionary<NSKeyValueChangeKey,id> *change) {
        NSLog(@"keyPath: %@ value: %@",keyPath,value);
    }];
    
    [self KAG_addObserverForNotificationName:UIDeviceOrientationDidChangeNotification object:nil block:^(NSNotification * _Nonnull notification) {
        NSLog(@"orientation %@",@(UIDevice.currentDevice.orientation));
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
    [self.model setSubmodel:[[SubModel alloc] init]];
}

@end
