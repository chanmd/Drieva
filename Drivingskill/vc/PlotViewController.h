//
//  PlotViewController.h
//  Drivingskill
//
//  Created by Man Tung on 12/13/12.
//  Copyright (c) 2012 Man Tung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "F3PlotStrip.h"

@interface PlotViewController : UIViewController
{
    CMMotionManager *motionManager;
    
    F3PlotStrip * plotStripX;
    F3PlotStrip * plotStripY;
    F3PlotStrip * plotStripZ;
    
    NSTimer *saveTimer;
    
@private
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) F3PlotStrip *plotStripX;
@property (nonatomic, retain) F3PlotStrip *plotStripY;
@property (nonatomic, retain) F3PlotStrip *plotStripZ;

@property (nonatomic,assign) id finishTarget;
@property (nonatomic,assign) SEL finishAction;

@property (readonly)CMMotionManager *motionManager;
@property (nonatomic, retain)NSManagedObjectContext *managedObjectContext;

- (void)recordUserAccelerometerData;
- (void)back;
- (void)sendandback;

@end
