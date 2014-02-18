//
//  MBKeyboardRetriever.m
//
//  Created by Mo Bitar on 2/17/14.
//  Copyright (c) 2014 progenius. All rights reserved.
//

@protocol MBKeyboardInputViewDelegate <NSObject>

- (void)keyboardInputViewWillMoveToSuperview:(UIView *)superview;

@end

@interface MBKeyboardInputView : UIView

@property (nonatomic, weak) id<MBKeyboardInputViewDelegate> delegate;

@end

////////////////////////////////////////////////////////////////////////////

#import "MBKeyboardRetriever.h"

@interface MBKeyboardRetriever () <UITextFieldDelegate, MBKeyboardInputViewDelegate>

@property (nonatomic) UIView *keyboard;

@property (nonatomic) UITextField *textField;

@property (nonatomic) MBKeyboardInputView *inputView;

@end

@implementation MBKeyboardRetriever

+ (UIView *)keyboard
{
    return [[self sharedInstance] keyboard];
}

+ (instancetype)sharedInstance
{
    static MBKeyboardRetriever *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [MBKeyboardRetriever new];
    });
    return instance;
}

- (void)dealloc
{
    [self.keyboard removeObserver:self forKeyPath:@"frame"];
}

- (instancetype)init
{
    if(self = [super init]) {
        self.inputView = [MBKeyboardInputView new];
        self.inputView.delegate = self;
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        self.textField.inputAccessoryView = self.inputView;
        self.textField.delegate = self;
        UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
        [window addSubview:self.textField];
        
        [self registerForNotifications];
    }
    return self;
}

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppearNotification:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppearNotification:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappearNotification:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidDisappearNotification:)
                                                 name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardWillAppearNotification:(NSNotification *)notification
{
    if([self.delegate respondsToSelector:@selector(keyboardRetrieverKeyboardWillAppear:)]) {
        [self.delegate keyboardRetrieverKeyboardWillAppear:self.keyboard];
    }
}

- (void)keyboardDidAppearNotification:(NSNotification *)notification
{
    if([self.delegate respondsToSelector:@selector(keyboardRetrieverKeyboardDidAppear:)]) {
        [self.delegate keyboardRetrieverKeyboardDidAppear:self.keyboard];
    }
}

- (void)keyboardWillDisappearNotification:(NSNotification *)notification
{
    if([self.delegate respondsToSelector:@selector(keyboardRetrieverKeyboardWillDisappear:)]) {
        [self.delegate keyboardRetrieverKeyboardWillDisappear:self.keyboard];
    }
}

- (void)keyboardDidDisappearNotification:(NSNotification *)notification
{
    if([self.delegate respondsToSelector:@selector(keyboardRetrieverKeyboardDidDisappear:)]) {
        [self.delegate keyboardRetrieverKeyboardDidDisappear:self.keyboard];
    }
}

+ (void)retrieve
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self sharedInstance] textField] becomeFirstResponder];
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CGPoint origin = self.keyboard.frame.origin;
    
    if([self.delegate respondsToSelector:@selector(keyboardRetrieverKeyboardOriginDidChange:)])
        [self.delegate keyboardRetrieverKeyboardOriginDidChange:origin];
}

#pragma mark - MBKeyboardInputViewDelegate

- (void)keyboardInputViewWillMoveToSuperview:(UIView *)superview
{
    if(superview) {
        self.keyboard = superview;
        NSLog(@"Sucessfully retreived keyboard: %@", self.keyboard);
        [self.keyboard addObserver:self forKeyPath:@"frame" options:0 context:nil];
        [self.textField resignFirstResponder];
        [self.textField removeFromSuperview];
        self.textField = nil;
    }
}

@end


////////////////////////////////////////

@implementation MBKeyboardInputView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    [self.delegate keyboardInputViewWillMoveToSuperview:newSuperview];
}

@end


