//
//  UserTermViewController.m
//  Drivingskill
//
//  Created by Man Tung on 1/10/13.
//  Copyright (c) 2013 Man Tung. All rights reserved.
//

#import "UserTermViewController.h"
#import "UILabel+Extensions.h"

@interface UserTermViewController ()

@end

@implementation UserTermViewController
@synthesize finishAction,finishTarget;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"usertermtitle", nil);
	// Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"usertermdontagree", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"usertermagree", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(agree)];
    
    UIScrollView * scrollview  = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480 - 44.f)];
    UILabel * usertermlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    [usertermlabel setBackgroundColor:[UIColor clearColor]];
    [usertermlabel setText:NSLocalizedString(@"userterm", nil)];
    [usertermlabel setFont:[UIFont fontWithName:@"Arial" size:15]];
    [usertermlabel sizeToFitFixedWidth:320];
    [scrollview addSubview:usertermlabel];
    [usertermlabel release];
    
    float contentheight = usertermlabel.frame.size.height + 25;
    [scrollview setContentSize:CGSizeMake(310, contentheight)];
    [self.view addSubview:scrollview];
    [scrollview release];
    
    
}

- (void)agree
{
    [self dismissModalViewControllerAnimated:YES];
    if ([finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
        [finishTarget performSelector:finishAction  withObject:nil];
    }
}

- (void)back
{
//    [self dismissModalViewControllerAnimated:YES];
    [self exitApplication];
}

- (void)exitApplication
{
    [UIView beginAnimations:@"exitApplication" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationCurveEaseOut forView:self.view.window cache:NO];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    self.view.window.bounds = CGRectMake(0, 0, 0, 0);
    [UIView commitAnimations];
}
- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID compare:@"exitApplication"] == 0) {
        exit(0);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
