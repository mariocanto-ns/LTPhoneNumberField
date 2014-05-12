//
//  LTPhoneNumberField.m
//  PhoneNumberFieldDemo
//
//  Created by Colin Regan on 5/8/14.
//  Copyright (c) 2014 Lua Technologies, LLC. All rights reserved.
//

#import "LTPhoneNumberField.h"
#import <NBAsYouTypeFormatter.h>

static NSString *const defaultRegion = @"US";

@interface LTPhoneNumberField () <UITextFieldDelegate>

@property (nonatomic, strong) NBAsYouTypeFormatter *formatter;
@property (nonatomic, weak) id<UITextFieldDelegate> externalDelegate;

- (void)setup;

@end

@implementation LTPhoneNumberField

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.formatter = [[NBAsYouTypeFormatter alloc] initWithRegionCode:defaultRegion];
    super.delegate = self;
}

#pragma mark - Delegate overrides

- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    self.externalDelegate = delegate;
}

- (id<UITextFieldDelegate>)delegate
{
    return self.externalDelegate;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.externalDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [self.externalDelegate textFieldShouldBeginEditing:textField];
    } else {
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.externalDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.externalDelegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self.externalDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [self.externalDelegate textFieldShouldEndEditing:textField];
    } else {
        return YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.externalDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.externalDelegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL singleInsertAtEnd = (string.length == 1) && (range.location == textField.text.length);
    BOOL singleDeleteFromEnd = (string.length == 0) && (range.length == 1) && (range.location == textField.text.length - 1);

    BOOL shouldChange = NO;
    NSString *formattedNumber;
    NSString *prefix;
    NSRange formattedRange;
    if (singleInsertAtEnd) {
        formattedNumber = [self.formatter inputDigit:string];
        if ([formattedNumber hasSuffix:string]) {
            formattedRange = [formattedNumber rangeOfString:string options:(NSBackwardsSearch | NSAnchoredSearch)];
            prefix = [formattedNumber stringByReplacingCharactersInRange:formattedRange withString:@""];
            textField.text = prefix;
            shouldChange = YES;
        }
    } else if (singleDeleteFromEnd) {
        formattedNumber = [self.formatter removeLastDigit];
        NSString *removedCharacter = [textField.text substringWithRange:range];
        prefix = [formattedNumber stringByAppendingString:removedCharacter];
        formattedRange = [prefix rangeOfString:removedCharacter options:(NSBackwardsSearch | NSAnchoredSearch)];
        textField.text = prefix;
        shouldChange = YES;
    }
    
    if ([self.externalDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return shouldChange && [self.externalDelegate textField:textField shouldChangeCharactersInRange:formattedRange replacementString:string];
    } else {
        return shouldChange;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([self.externalDelegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [self.externalDelegate textFieldShouldClear:textField];
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.externalDelegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [self.externalDelegate textFieldShouldReturn:textField];
    } else {
        return YES;
    }
}

@end
