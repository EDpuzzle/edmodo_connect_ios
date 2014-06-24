//
//  EMMockLoginViewController.m
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/16/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMObjects.h"
#import "EMMockLoginView.h"

#define EM_StandardButtonFontSizeRatio      0.6
#define EM_ButtonFontName                   @"Helvetica"

@interface EMMockLoginView ()
{
    EMIntegerResultBlock_t _successHandler;
    EMVoidResultBlock_t _cancelHandler;
    EMNSErrorBlock_t _errorHandler;
    UIScrollView* _containerView;
    CGFloat _buttonWidth;
    CGFloat _buttonHeight;
    CGFloat _fontSize;
    CGFloat _padX;
    
}
@end

@implementation EMMockLoginView {
}

- (id)initWithFrame:(CGRect)rect
          onSuccess:(EMIntegerResultBlock_t)successHandler
           onCancel:(EMVoidResultBlock_t)cancelHandler
            onError:(EMNSErrorBlock_t)errorHandler {
    self = [super initWithFrame:rect];
    if (self) {
        _successHandler = successHandler;
        _cancelHandler = cancelHandler;
        _errorHandler = errorHandler;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat shortEdge = MIN(screenRect.size.width, screenRect.size.height);
        
        _buttonWidth = (shortEdge * 0.5);
        _buttonHeight = (_buttonWidth * 0.15);
        _fontSize = _buttonHeight * EM_StandardButtonFontSizeRatio;
        _padX = (_buttonWidth * 0.5);
        
        
        [self __createWidgets];
    }
    return self;
}


- (void) __createWidgets
{
    self.backgroundColor = [UIColor whiteColor];
    
    _containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,
                                                                    self.frame.size.height)];
    
    [self addSubview:_containerView];
    
    EMMockDataStore* mockDataStore = [EMMockDataStore sharedInstance];
    
    int row = 0;
    
    
    NSArray* teachers = [mockDataStore getMockTeachers];
    for (NSDictionary* user in teachers) {
        [self __addLoginButton:user atRow:row++];
    }
    row++;
    
    NSArray* students = [mockDataStore getMockStudents];
    for (NSDictionary* user in students) {
        [self __addLoginButton:user atRow:row++];
    }
    row++;
    
    
    
    UIButton* quitButton = [self __addButton: @"Quit"
                                       atRow: row++];
    [quitButton addTarget:self action:@selector(__quitLogin:)
         forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:quitButton];
    
    _containerView.contentSize = CGSizeMake(self.frame.size.width,
                                            row * _buttonHeight);
}

-(UIButton *) __addButton: (NSString*) title
                    atRow:(NSInteger)row
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self __configureButton:button
                  withTitle:title
                      inRow:row];
    return button;
}

-(void) __addLoginButton:(NSDictionary*)userDict
                   atRow:(NSInteger)row
{
    EMUser* user = [[EMUser alloc] initFromOneAPIJson: userDict];
    
    UIButton* mockLoginButton = [self __addButton: [user getFullName]
                                            atRow:row];
    mockLoginButton.tag = [user.userID integerValue];
    [_containerView addSubview:mockLoginButton];
    [mockLoginButton addTarget:self action:@selector(__mockLogin:)
              forControlEvents:UIControlEventTouchUpInside];
}

- (void) __mockLogin: (id)sender
{
    UIButton* mockLoginButton = (UIButton*)sender;
    NSInteger userID = [mockLoginButton tag];
    self->_successHandler(userID);
}

-(void) __quitLogin:(id)sender
{
    _cancelHandler();
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)__configureButton: (UIButton *) button
                withTitle: (NSString *)title
                    inRow: (NSInteger)row
{
    button.frame = CGRectMake(_padX, _buttonHeight * row, _buttonWidth, _buttonHeight);
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:EM_ButtonFontName
                                             size:_fontSize];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
}

@end
