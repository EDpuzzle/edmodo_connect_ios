//
//  EMMockLoginViewController.m
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/16/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMObjects.h"
#import "EMMockLoginViewController.h"

#define EM_StandardButtonFontSizeRatio      0.6
#define EM_ButtonFontName                   @"Helvetica"

@interface EMMockLoginViewController ()
{
    EMIntegerResultBlock_t _successHandler;
    EMVoidResultBlock_t _cancelHandler;
    EMNSErrorBlock_t _errorHandler;
}
@end

@implementation EMMockLoginViewController {
}

- (id)init:(EMIntegerResultBlock_t)successHandler
  onCancel:(EMVoidResultBlock_t)cancelHandler
   onError:(EMNSErrorBlock_t)errorHandler {
    self = [super init];
    if (self) {
        _successHandler = successHandler;
        _cancelHandler = cancelHandler;
        _errorHandler = errorHandler;
    }
    return self;
}

/*
 - (id)initWithMockDataStore:(EMMockDataStore *) mds
 andConfigDelegate:(id<EMDataStoreConfigDelegate>) delegate
 {
 self = [super init];
 if (self) {
 // Custom initialization
 mockDataStore = mds;
 configDelegate = delegate;
 
 }
 return self;
 }
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

-(BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    EMMockDataStore* mockDataStore = [EMMockDataStore sharedInstance];
    
    int row = 0;
    
    NSArray* teachers = [mockDataStore getMockTeachers];
    for (NSDictionary* user in teachers) {
        [self addLoginButton:user atRow:row++];
    }
    row++;
    
    NSArray* students = [mockDataStore getMockStudents];
    for (NSDictionary* user in students) {
        [self addLoginButton:user atRow:row++];
    }
    
    row++;
    
    UIButton* quitButton = [self addButton: @"Quit"
                                     atRow: row];
    [quitButton addTarget:self action:@selector(quitLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:quitButton];
}

-(UIButton *) addButton: (NSString*) title
                  atRow:(NSInteger)row
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self configureButton:button
                withTitle:title
                    inRow:row];
    return button;
}

-(void) addLoginButton:(NSDictionary*)userDict
                 atRow:(NSInteger)row
{
    EMUser* user = [[EMUser alloc] initFromOneAPIJson: userDict];
    
    UIButton* mockLoginButton = [self addButton: [user getFullName]
                                          atRow:row];
    mockLoginButton.tag = [user.userID integerValue];
    [self.view addSubview:mockLoginButton];
    [mockLoginButton addTarget:self action:@selector(mockLogin:)
              forControlEvents:UIControlEventTouchUpInside];
}

- (void) mockLogin: (id)sender
{
    UIButton* mockLoginButton = (UIButton*)sender;
    NSInteger userID = [mockLoginButton tag];
    self->_successHandler(userID);
}

-(void) quitLogin:(id)sender
{
    _cancelHandler();
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureButton: (UIButton *) button
              withTitle: (NSString *)title
                  inRow: (NSInteger)row
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat shortEdge = MIN(screenRect.size.width, screenRect.size.height);
    
    CGFloat buttonWidth = (shortEdge * 0.5);
    CGFloat buttonHeight = (buttonWidth * 0.2);
    CGFloat fontSize = buttonHeight * EM_StandardButtonFontSizeRatio;
    CGFloat padX = (buttonWidth * 0.5);
    
    button.frame = CGRectMake(padX, buttonHeight * row, buttonWidth, buttonHeight);
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:EM_ButtonFontName
                                             size:fontSize];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
}

- (void)configureButton:(UIButton *)button
              withTitle:(NSString *)title
{
    [button setTitle:title forState:UIControlStateNormal];
    
    button.titleLabel.font =
    [UIFont fontWithName:EM_ButtonFontName
                    size:button.frame.size.height * EM_StandardButtonFontSizeRatio];
    button.titleLabel.minimumScaleFactor = 0.1;
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor yellowColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
}

@end
