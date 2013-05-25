//
//  HomeViewController.h
//  Drivingskill
//
//  Created by Man Tung on 12/5/12.
//  Copyright (c) 2012 Man Tung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "F3PlotStrip.h"
#import "MTStatusBarOverlay.h"
#import "msgView.h"

@interface HomeViewController : UIViewController <MTStatusBarOverlayDelegate>
{
    CMMotionManager *motionManager;
    
//    F3PlotStrip * plotStripX;
//    F3PlotStrip * plotStripY;
//    F3PlotStrip * plotStripZ;
    
    UIButton * startButton;
    UILabel * descriptionLabel;
    BOOL ishorizon;
    
    NSURLConnection*    connection;
	NSMutableData*      buf;
    int                 statusCode;
    BOOL _secureConnection;
    
    NSArray *uploadArrayNeedFlag;
    
//    msgView *msgview;
    UILabel *msgLabel;
    
@private
    NSManagedObjectContext *managedObjectContext;

}

//@property (nonatomic, retain) F3PlotStrip *plotStripX;
//@property (nonatomic, retain) F3PlotStrip *plotStripY;
//@property (nonatomic, retain) F3PlotStrip *plotStripZ;
@property (readonly)CMMotionManager *motionManager;
@property (nonatomic, retain)NSManagedObjectContext *managedObjectContext;


@end
