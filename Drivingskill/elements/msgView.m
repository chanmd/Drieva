//
//  msgView.m
//  Instanote
//
//  Created by Man Tung on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "msgView.h"
#import <QuartzCore/QuartzCore.h>

@implementation msgView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor darkGrayColor]];
        [self setAlpha:0.9];
        [[self layer] setCornerRadius:5.f];
        
        if (!msgLabel) {
            msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 22)];
            [msgLabel setBackgroundColor:[UIColor clearColor]];
            [msgLabel setFont:[UIFont fontWithName:FONT_NAME size:16]];
            [self addSubview:msgLabel];
            [self setHidden:YES];
        }
    }
    return self;
}

- (void)setText:(NSString *)msg
{
    [msgLabel setText:msg];
    [msgLabel setTextAlignment:UITextAlignmentCenter];
}

- (void)show
{
    [self setHidden:NO];
    [self performSelector:@selector(hidden) withObject:nil afterDelay:2.f];
}

- (void)hidden
{
    [self setHidden:YES];
}

- (void)dealloc
{
    [super dealloc];
    [msgLabel release];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
