//
//  EMCarouselView.h
//  ProtoComicApp
//
//  Created by Luca Prasso on 2/26/14.
//  Copyright (c) 2014 Luca Prasso Edmodo. All rights reserved.
//
// A view with a 'window' and an arrow on either side of the window.
// Takes an array of subviews.
// Only one subview is visible at a time.
// Clicking arrows or swiping cycles the subviews.


@protocol EMCarouselViewDelegate
// When user changes the current item in carousel (whether by swiping
// or button) call this with the index of the new view.
-(void)onViewChanged:(NSInteger)viewIndex;
@end


@interface EMCArouselView: UIView
// An array of UI Views.  They will be forcibly sized to fit inside the
// 'window' of the carousel view.
- (id)initWithViews:(NSArray*)views

- (void)setDelegate:(id<EMCarouselViewDelegate>)delegate;

- (void) setCurrentViewIndex:(NSInteger)index;

- (NSInteger) getCurrentViewIndex;


@end
