## Agamotto

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](http://img.shields.io/cocoapods/v/Agamotto.svg)](http://cocoapods.org/?q=Agamotto)
[![Platform](http://img.shields.io/cocoapods/p/Agamotto.svg)]()
[![License](http://img.shields.io/cocoapods/l/Agamotto.svg)](https://github.com/Kosoku/Agamotto/blob/master/license.txt)

*Agamotto* is an iOS/macOS/tvOS/watchOS framework that provides block based extensions to KVO and `NSNotificationCenter`. It handles tearing down the observer upon deallocation. It is based on part of the [ReactiveCocoa Objective-C framework](https://github.com/ReactiveCocoa/ReactiveObjC).

### Installation

You can install *Agamotto* using [cocoapods](https://cocoapods.org/), [Carthage](https://github.com/Carthage/Carthage), or as a framework.

### Usage

You **must** do the `weakSelf`/`strongSelf` dance for any blocks passed to the observing methods. Otherwise a retain cycle will be introduced.

It is not required in the notification observing example because `self` is not called within the block.

```objc
#import <Agamotto/Agamotto.h>

static NSNotificationName const kTextDidChangeNotification = @"kTextDidChangeNotification";

@interface MyObject : NSObject
@property (copy) NSString *text;

- (void)foo;
@end

@implementation MyObject

- (instancetype)init {
	if (!(self = [super init]))
		return nil;
	
	__weak __typeof__(self) weakSelf = self;
	[self KAG_addObserverForKeyPath:@"text" options:0 block:^(NSString *keyPath, id _Nullable value, NSDictionary<NSKeyValueChangeKey, id> *change){
		__strong __typeof__(weakSelf) strongSelf = weakSelf;
		
		[self foo];
	}];
	
	[self KAG_addObserverToNotificationCenter:nil notificationName:kTextDidChangeNotification object:self block:^(NSNotification *notification){
		NSLog(@"notification %@",notification);
	}];
	
	return self;
}

- (void)foo {
	NSLog(@"text %@",self.text);
}

- (void)setText:(NSString *)text {
	_text = [text copy];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kTextDidChangeNotification object:self];
}

@end
```