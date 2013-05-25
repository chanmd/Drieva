//
//  PlotViewController.m
//  Drivingskill
//
//  Created by Man Tung on 12/13/12.
//  Copyright (c) 2012 Man Tung. All rights reserved.
//

#import "PlotViewController.h"
#import "AppDelegate.h"
#import "Temp.h"
#import "TempData.h"

@interface PlotViewController ()

@end

@implementation PlotViewController
@synthesize plotStripX, plotStripY, plotStripZ;
@synthesize finishTarget,finishAction;
@synthesize motionManager;
@synthesize managedObjectContext;


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        if (!managedObjectContext) {
            managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        }
    }
    return self;
}

#pragma mark- fetch data

- (void)insertTempEntity:(NSString *)content
{
    Temp *temp = [NSEntityDescription insertNewObjectForEntityForName:@"Temp" inManagedObjectContext:managedObjectContext];
    NSDate *nowdate = [NSDate date];
    temp.creatTime = nowdate;
    temp.content = content;
    temp.isUpload = [NSNumber numberWithBool:NO];
    NSError * error = nil;
    if (![temp.managedObjectContext save:&error]) {
        NSLog(@"error when save %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark
#pragma mark - deviceMotion
- (void)recordUserAccelerometerData
{
    motionManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedMotionManager];
    
    if ([motionManager isDeviceMotionAvailable] == YES) {
        [motionManager setDeviceMotionUpdateInterval:MOTION_DEVICEMOTION_UPDATEINTERVAL];
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
            // userAcceleration
            CMRotationMatrix rotation;
            rotation = deviceMotion.attitude.rotationMatrix;
            
            double x1 = deviceMotion.userAcceleration.x * rotation.m11 + deviceMotion.userAcceleration.x * rotation.m21 + deviceMotion.userAcceleration.x * rotation.m31;
            double y1 = deviceMotion.userAcceleration.y * rotation.m12 + deviceMotion.userAcceleration.y * rotation.m22 + deviceMotion.userAcceleration.y * rotation.m32;
            double z1 = deviceMotion.userAcceleration.z * rotation.m13 + deviceMotion.userAcceleration.z * rotation.m23 + deviceMotion.userAcceleration.z * rotation.m33;
            
            plotStripX.value = x1;
            plotStripY.value = y1;
            plotStripZ.value = z1;
            [TempData setTempString:[NSString stringWithFormat:@"%lf\t%lf\t%lf\n", x1, y1, z1]];
//            NSLog(@"%lf\t%lf\t%lf", x1, y1, z1);
            
            
            //        double yaw = motion.attitude.yaw;
            //        double pitch = motion.attitude.pitch;
            //        double roll = motion.attitude.roll;
            
            //        double x1 = motion.userAcceleration.x * rotation.m11 + motion.userAcceleration.x * rotation.m12 + motion.userAcceleration.x * rotation.m13;
            //        double y1 = motion.userAcceleration.y * rotation.m21 + motion.userAcceleration.y * rotation.m22 + motion.userAcceleration.y * rotation.m23;
            //        double z1 = motion.userAcceleration.z * rotation.m31 + motion.userAcceleration.z * rotation.m32 + motion.userAcceleration.z * rotation.m33;
            
        }];
    }
}

- (void)initPageView
{
    
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"plottitle", @"");
    
    UILabel * labelX = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
    [labelX setText:NSLocalizedString(@"lableX", @"")];
    [self.view addSubview:labelX];
    [labelX release];
    plotStripX = [[F3PlotStrip alloc] initWithFrame:CGRectMake(10, 30, Plot_Width, Plot_Heigth)];
    plotStripX.lowerLimit = Plot_LowerLimit;
    plotStripX.upperLimit = Plot_UpperLimit;
    plotStripX.capacity = Plot_Capacity;
    plotStripX.lineColor = [UIColor greenColor];
    plotStripX.lineWidth = Plot_lineWidth;
    plotStripX.backgroundColor = [UIColor colorWithRed:0/255.f green:0/255.f blue:0/255.f alpha:1];
    plotStripX.showDot = NO;
//    plotStripX.baselineWidth = 1.0f;
    [self.view addSubview:plotStripX];
    
    
    UILabel * labelY = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, 300, 20)];
    [labelY setText:NSLocalizedString(@"lableY", @"")];
    [self.view addSubview:labelY];
    [labelY release];
    plotStripY = [[F3PlotStrip alloc] initWithFrame:CGRectMake(10, 165, Plot_Width, Plot_Heigth)];
    plotStripY.lowerLimit = Plot_LowerLimit;
    plotStripY.upperLimit = Plot_UpperLimit;
    plotStripY.capacity = Plot_Capacity;
    plotStripY.lineColor = [UIColor redColor];
    plotStripY.lineWidth = Plot_lineWidth;
    plotStripY.backgroundColor = [UIColor colorWithRed:0/255.f green:0/255.f blue:0/255.f alpha:1];
    plotStripY.showDot = NO;
//    plotStripY.baselineWidth = Plot_lineWidth;
    [self.view addSubview:plotStripY];
    
    UILabel * labelZ = [[UILabel alloc] initWithFrame:CGRectMake(10, 275, 300, 20)];
    [labelZ setText:NSLocalizedString(@"lableZ", @"")];
    [self.view addSubview:labelZ];
    [labelZ release];
    plotStripZ = [[F3PlotStrip alloc] initWithFrame:CGRectMake(10, 300, Plot_Width, Plot_Heigth)];
    plotStripZ.lowerLimit = Plot_LowerLimit;
    plotStripZ.upperLimit = Plot_UpperLimit;
    plotStripZ.capacity = Plot_Capacity;
    plotStripZ.lineColor = [UIColor blueColor];
    plotStripZ.lineWidth = Plot_lineWidth;
    plotStripZ.backgroundColor = [UIColor colorWithRed:0/255.f green:0/255.f blue:0/255.f alpha:1];
    plotStripZ.showDot = NO;
//    plotStripZ.baselineWidth = 1.0f;
//    plotStripZ.baselineColor = [UIColor grayColor];
    [self.view addSubview:plotStripZ];
    
}

#define TIMER_SAVE_FREQUENCY 10

- (void)startEvaluation
{
    [self recordUserAccelerometerData];
    [self stopTimer];
    saveTimer = [[NSTimer timerWithTimeInterval:TIMER_SAVE_FREQUENCY target:self selector:@selector(timerFiredSave) userInfo:nil repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:saveTimer forMode:NSDefaultRunLoopMode];
}

- (void)endEvaluation
{
    [self.motionManager stopDeviceMotionUpdates];
    [plotStripX clear];
    [plotStripY clear];
    [plotStripZ clear];
    
    [saveTimer invalidate];
    [saveTimer release];
    saveTimer = nil;
}

- (void)timerFiredSave
{
    NSString * data = [TempData getTempString];
    Temp *temp;
    temp = [NSEntityDescription insertNewObjectForEntityForName:@"Temp" inManagedObjectContext:self.managedObjectContext];
    temp.content = data;
    NSDate *now = [NSDate date];
    temp.creatTime = now;
    temp.isUpload = [NSNumber numberWithBool:NO];
    NSError *error = nil;
    if (![temp.managedObjectContext save:&error]) {
        NSLog(@"error when save %@, %@", error, [error userInfo]);
        abort();
    } else {
        [TempData clearTempString];
    }
}

#pragma mark
#pragma mark - lifecircle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [self initPageView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancelbutton", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"donebutton", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(sendandback)];
    
    [self startEvaluation];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(sendandback)];
    
}

- (void)back
{
    [self stopTimer];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sendandback
{
    [self stopTimer];
    [self dismissModalViewControllerAnimated:YES];
    if ([finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
        [finishTarget performSelector:finishAction  withObject:nil];
    }
}

- (void)stopTimer
{
    [saveTimer invalidate];
    [saveTimer release];
    saveTimer = nil;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [plotStripX release];
    [plotStripY release];
    [plotStripZ release];
    
    [saveTimer release];
    [managedObjectContext release];
    [motionManager release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self stopTimer];
    
}

- (void)dealloc
{
    [super dealloc];
    plotStripX = nil;
    plotStripY = nil;
    plotStripZ = nil;
    saveTimer = nil;
    managedObjectContext = nil;
    motionManager = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
