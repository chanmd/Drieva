//
//  HomeViewController.m
//  Drivingskill
//
//  Created by Man Tung on 12/5/12.
//  Copyright (c) 2012 Man Tung. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "Scores.h"
#import "Temp.h"
#import "TempData.h"
#import "JSON.h"
#import "NSDictionaryAdditions.h"
#import "NSString+URLEscapes.h"
#import "PlotViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ScoresViewController.h"
#import "SettingViewController.h"
#import "UserTermViewController.h"
#import "UMFeedbackViewController.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>


@interface HomeViewController ()

@end

@implementation HomeViewController
//@synthesize plotStripX, plotStripY, plotStripZ;
@synthesize motionManager;
@synthesize managedObjectContext;


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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"scoresbutton", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(scoreViewAction)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"morebutton", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(MoreViewAction)];
    
    
    
    [MTStatusBarOverlay sharedInstance].animation = MTStatusBarOverlayAnimationShrink;
    // MTStatusBarOverlayAnimationShrink
    [MTStatusBarOverlay sharedInstance].detailViewMode = MTDetailViewModeHistory;
    // enable automatic history-tracking and show in detail-view
    [MTStatusBarOverlay sharedInstance].delegate = self;
    
    msgLabel = [[UILabel alloc] init];
    [msgLabel setFrame:CGRectMake(10, 150, 300, 100)];
    [msgLabel setFont:[UIFont fontWithName:FONT_NAME size:35]];
    [msgLabel setTextAlignment:UITextAlignmentCenter];
    [self.view addSubview:msgLabel];
    
    descriptionLabel = [[UILabel alloc] init];
    [descriptionLabel setFrame:CGRectMake(5, 5, 310, 200)];
    [descriptionLabel setBackgroundColor:[UIColor clearColor]];
    [descriptionLabel setTextAlignment:UITextAlignmentCenter];
    [self.view addSubview:descriptionLabel];
    
    [self performSelector:@selector(confrimuseme) withObject:nil afterDelay:1];
    
    [self recordMotionData];
    
}

- (void)showstartbutton
{
    startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startButton setFrame:CGRectMake(10, 300, 300, 50)];
    [startButton setTitle:NSLocalizedString(@"startbutton", @"") forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(presentPlotView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startButton];
    
    [self turnontermallow];
    
}

- (BOOL)usertermallow
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSUInteger userid = [def integerForKey:USERTERMALLOW];
    if (userid) {
        return YES;
    } else {
        return NO;
    }
}

- (void)turnontermallow
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:1 forKey:USERTERMALLOW];
    [def synchronize];
}


- (BOOL)connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

#pragma mark - motion

- (void)recordMotionData
{
    motionManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedMotionManager];
    
    if ([motionManager isDeviceMotionAvailable] == YES) {
        [motionManager setDeviceMotionUpdateInterval:1];
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
            double yaw = deviceMotion.attitude.yaw;
            double pitch = deviceMotion.attitude.pitch;
            double roll = deviceMotion.attitude.roll;
//            NSLog(@"%lf_______%lf_______%lf", yaw, pitch, roll);
            [self ishorizontal:yaw Pitch:pitch Roll:roll];
            
        }];
    }
}

- (void)ishorizontal:(double)yaw Pitch:(double)pitch Roll:(double)roll
{
//    double unsignedyaw = fabs(yaw);
    double unsignedpitch = fabs(pitch);
    double unsignedroll = fabs(roll);
    
    double unreachable = 0.12;
    
    if (unsignedroll > unreachable || unsignedpitch > unreachable) {
        [descriptionLabel setTextColor:[UIColor redColor]];
        [descriptionLabel setFont:[UIFont fontWithName:FONT_NAME size:26]];
        [descriptionLabel setText:NSLocalizedString(@"descriptionno", @"")];
        ishorizon = NO;
    } else {
        [descriptionLabel setTextColor:[UIColor greenColor]];
        [descriptionLabel setFont:[UIFont fontWithName:FONT_NAME size:26]];
        [descriptionLabel setText:NSLocalizedString(@"descriptionyes", @"")];
        ishorizon = YES;
    }
}


#pragma mark
#pragma mark - actions

- (void)usertermviewPresent
{
    UserTermViewController * usertermvc = [[UserTermViewController alloc] init];
    usertermvc.finishTarget = self;
    usertermvc.finishAction = @selector(showstartbutton);
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:usertermvc];
    [self.navigationController presentModalViewController:nav animated:YES];
    [nav release];
    [usertermvc release];
}

- (void)presentPlotView
{
    if (![self connectedToNetwork]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"connectionfailtitle", nil)
                              message:NSLocalizedString(@"connectionfailmessage", nil)
                              delegate:nil cancelButtonTitle:NSLocalizedString(@"connectionfaildone", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }else if (!ishorizon) {
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"horizontalfailtitle", nil)
                              message:nil
                              delegate:nil cancelButtonTitle:NSLocalizedString(@"connectionfaildone", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        
    } else {
        PlotViewController * plotviewcontroller = [[PlotViewController alloc] init];
        plotviewcontroller.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        plotviewcontroller.finishTarget = self;
        plotviewcontroller.finishAction = @selector(timerFiredPut);
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:plotviewcontroller];
        [self.navigationController presentModalViewController:nav animated:YES];
        [nav release];
        [plotviewcontroller release];
    }
}

- (void)MoreViewAction
{
//    SettingViewController *moreviewcontroller = [[SettingViewController alloc] init];
//    [self.navigationController pushViewController:moreviewcontroller animated:YES];
//    [moreviewcontroller release];
    
    UMFeedbackViewController *feedbackViewController = [[UMFeedbackViewController alloc] initWithNibName:@"UMFeedbackViewController" bundle:nil];
    feedbackViewController.appkey = UMENG_APPKEY;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:feedbackViewController];
    [self presentModalViewController:navigationController animated:YES];
    
    
}

- (void)scoreViewAction
{
    ScoresViewController *scoreviewcontroller = [[ScoresViewController alloc] init];
//    scoreviewcontroller.managedObjectContext = self.managedObjectContext;
    [self.navigationController pushViewController:scoreviewcontroller animated:NO];
}

/*
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
 
 */

- (void)confrimuseme
{
    if (![self usertermallow]) {
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"usertermTitle", @"") message:NSLocalizedString(@"usertermMessage", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"usertermNotAllow", @"") otherButtonTitles:NSLocalizedString(@"usertermOK", @""), nil];
//        [alert show];
        [self usertermviewPresent];
        
    } else {
        [self showstartbutton];
    }
}

//- (void)modalView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    switch (buttonIndex) {
//        case 0:
//            [self showrestartbutton];
//            break;
//        case 1:
//            [self showstartbutton];
//            [self turnontermallow];
//            break;
//    }
//    [alertView release];
//}


- (void)timerFiredPut
{
    [[MTStatusBarOverlay sharedInstance] postMessage:NSLocalizedString(@"uploading", @"")];
    [MTStatusBarOverlay sharedInstance].progress = 0.5;
    
    NSMutableString *data = [NSMutableString stringWithCapacity:0];
    NSArray * array = [self fetchTempWithUpload:NO];
    if ([array count] > 0) {
        for (int i = 0; i < [array count]; i ++) {
            Temp *temp = [array objectAtIndex:i];
            [data appendFormat:@"%@", temp.content];
        }
    }
    NSString *file = [data originalURLString];
    //    NSMutableString *param = [[NSMutableString alloc] initWithCapacity:0];
    //    [param appendFormat:@"--%@\r\n", TWITTERFON_FORM_BOUNDARY];
    //[param appendFormat:@"Content-Disposition: form-data; name=\"pic\";filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"];
    //    NSString *footer = [NSString stringWithFormat:@"\r\n--%@--\r\n", TWITTERFON_FORM_BOUNDARY];
    
    NSMutableData *datas = [NSMutableData data];
    //    [datas appendData:[param dataUsingEncoding:NSUTF8StringEncoding]];
    [datas appendData:[file dataUsingEncoding:NSUTF8StringEncoding]];
    //    [datas appendData:[footer dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString * path = [NSString stringWithFormat:@"score.%@", API_FORMAT];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if ([self uid]) {
        [params setObject:[NSString stringWithFormat:@"%@", [self uid]] forKey:@"uid"];
    }
    [self put:[self getURL:path queryParameters:params] data:datas];
    
}

#pragma mark
#pragma mark - connection delegate


-(void)put:(NSString *)aUrl data:(NSData *)data
{
    [connection release];
	[buf release];
    statusCode = 0;
    NSString *URL = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aUrl, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
	[URL autorelease];
	NSURL *finalURL = [NSURL URLWithString:URL];
	NSMutableURLRequest* req;
	
    req = [NSMutableURLRequest requestWithURL:finalURL
                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                              timeoutInterval:NETWORK_TIMEOUT];
    
    //text/html；charset=utf-8
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", TWITTERFON_FORM_BOUNDARY];
    [req setHTTPShouldHandleCookies:NO];
    [req setHTTPMethod:@"PUT"];
    [req setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [req setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    [req setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [req setHTTPBody:data];
	
	buf = [[NSMutableData data] retain];
	connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}



- (void)get:(NSString*)aURL
{
    [connection release];
	[buf release];
    statusCode = 0;
    
    
    NSString *URL = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aURL, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
    [URL autorelease];
	NSURL *finalURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",URL]];
	
	NSMutableURLRequest* req;
    req = [NSMutableURLRequest requestWithURL:finalURL
                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                              timeoutInterval:NETWORK_TIMEOUT];
    [req setHTTPShouldHandleCookies:NO];
	/*
     NSDictionary *dic = [req allHTTPHeaderFields];
     for (NSString *key in [dic allKeys]) {
     NSLog(@"key:%@, value:%@", key, [dic objectForKey:key]);
     }
	 */
 	buf = [[NSMutableData data] retain];
	connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (NSString *)getURL:(NSString *)path
	 queryParameters:(NSMutableDictionary*)params {
    NSString* fullPath = [NSString stringWithFormat:@"%@://%@/%@",
						  (_secureConnection) ? @"https" : @"http",
						  API_DOMAIN, path];
	if (params) {
        fullPath = [self _queryStringWithBase:fullPath parameters:params prefixed:YES];
    }
	return fullPath;
}

- (NSString *)_queryStringWithBase:(NSString *)base parameters:(NSDictionary *)params prefixed:(BOOL)prefixed
{
    // Append base if specified.
    NSMutableString *str = [NSMutableString stringWithCapacity:0];
    if (base) {
        [str appendString:base];
    }
    
    // Append each name-value pair.
    if (params) {
        int i;
        NSArray *names = [params allKeys];
        for (i = 0; i < [names count]; i++) {
            if (i == 0 && prefixed) {
                [str appendString:@"?"]; 
            } else if (i > 0) {
                [str appendString:@"&"];
            }
            NSString *name = [names objectAtIndex:i];
            [str appendString:[NSString stringWithFormat:@"%@=%@",
							   name, [params objectForKey:name]]];
        }
    }
    return str;
}

- (NSString *)_encodeString:(NSString *)string
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
																		   (CFStringRef)string,
																		   NULL,
																		   (CFStringRef)@";/?:@&=$+{}<>,",
																		   kCFStringEncodingUTF8);
    return [result autorelease];
}


- (void)cancel
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (connection) {
        [connection cancel];
        [connection autorelease];
        connection = nil;
    }
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse
{
    NSHTTPURLResponse *resp = (NSHTTPURLResponse*)aResponse;
    if (resp) {
        statusCode = resp.statusCode;
        if (statusCode == 200) {
            [self updateTempWithUploady];
        }
    }
	[buf setLength:0];
}

- (void)connection:(NSURLConnection *)aConn didReceiveData:(NSData *)data
{
	[buf appendData:data];
}

- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	[connection autorelease];
	connection = nil;
	[buf autorelease];
	buf = nil;
    
    //    NSString* msg = [NSString stringWithFormat:@"Error: %@ %@",
    //                     [error localizedDescription],
    //                     [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]];
    //
    //    NSLog(@"Connection failed: %@", msg);
    
    [self URLConnectionDidFailWithError:error];
    
}


- (void)URLConnectionDidFailWithError:(NSError*)error
{
    // To be implemented in subclass
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString* s = [[[NSString alloc] initWithData:buf encoding:NSUTF8StringEncoding] autorelease];
    
    [self URLConnectionDidFinishLoading:s];
	
    
    [connection autorelease];
    connection = nil;
    [buf autorelease];
    buf = nil;
}

- (void)URLConnectionDidFinishLoading:(NSString*)content
{
    // To be implemented in subclass
    if (content) {
        NSObject *obj = [content JSONValue];
        NSDictionary * dic = (NSDictionary *)obj;
        int userid = [dic getIntValueForKey:@"uid" defaultValue:0];
        [self setuid:userid];
        NSArray * array = [dic objectForKey:@"score"];
        for (NSDictionary * dicc in array) {
            if (![dicc isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            //            NSString *name = [dicc getStringValueForKey:@"name" defaultValue:@"nothing"];
            int score = [dicc getIntValueForKey:@"score" defaultValue:0];
            [self addScore:score];
            //            NSLog(@"%d", score);
            [msgLabel setText:[NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"scorename", @""), score]];
            
            [[MTStatusBarOverlay sharedInstance] postImmediateFinishMessage:NSLocalizedString(@"finishupload", @"") duration:2.0 animated:YES];
            [MTStatusBarOverlay sharedInstance].progress = 1.0;
        }
        
    }

}


#pragma mark- fetch data

- (NSNumber *)uid
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def objectForKey:@"uid"];
}

- (void)setuid:(NSInteger)userid
{
    
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    if (![def objectForKey:@"uid"]) {
        [def setInteger:userid forKey:@"uid"];
        [def synchronize];
    }
}

- (void)addScore:(int)s
{
    Scores *score = [NSEntityDescription insertNewObjectForEntityForName:@"Scores" inManagedObjectContext:managedObjectContext];
    NSDate *nowdate = [NSDate date];
    score.createDate = nowdate;
    score.content =  [NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"scorename", @"") ,s];
    score.score = [NSNumber numberWithInt:s];
    NSError *error = nil;
    if (![score.managedObjectContext save:&error]) {
        NSLog(@"error when save %@, %@", error, [error userInfo]);
        abort();
    }
}

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

- (NSArray *)fetchTemp
{
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Temp" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray * array = [managedObjectContext executeFetchRequest:request error:&error];
    [entity release];
    [request release];
    return array;
}

- (NSArray *)fetchTempWithUpload:(BOOL)isupload
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Temp" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isUpload = %@", [NSNumber numberWithBool:isupload]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    uploadArrayNeedFlag = [[NSArray arrayWithArray:array] retain];
    [request release];
    
    return array;
}

- (void)updateTempWithUploady
{
    if (nil != uploadArrayNeedFlag && [uploadArrayNeedFlag count] > 0) {
        NSArray * array = [uploadArrayNeedFlag retain];
        for (int i = 0; i < [array count]; i ++) {
            Temp *temp;
            temp = [array objectAtIndex:i];
            temp.isUpload = [NSNumber numberWithBool:YES];
            NSError *error = nil;
            if (![temp.managedObjectContext save:&error]) {
                NSLog(@"error when save %@, %@", error, [error userInfo]);
                abort();
            }
        }//end loop
        
    }//array is not nil and count more than 0
}

- (void)printTemp
{
    NSArray * array = [self fetchTemp];
    if ([array count] > 0) {
        int i;
        for (i = 0; i <[array count]; i ++) {
            Temp * temp;
            temp = [array objectAtIndex:i];
            NSLog(@"%@", temp.content);
        }
    } else {
        NSLog(@"no export data");
    }
}

- (void)destoryTemp
{
    NSArray * array = [self fetchTemp];
    if ([array count] > 0) {
        for (NSManagedObject *obj in array) {
            [managedObjectContext deleteObject:obj];
            [managedObjectContext save:nil];
        }
        NSLog(@"clean up");
    } else {
        NSLog(@"no data");
    }
}

- (void)exportData
{
    NSLog(@"temp str %@", [TempData getTempString]);
}

- (void)destoryData
{
    NSArray * array = [self fetchTemp];
    if ([array count] > 0) {
        for (NSManagedObject *obj in array) {
            [managedObjectContext deleteObject:obj];
            [managedObjectContext save:nil];
        }
        NSLog(@"clean up");
    } else {
        NSLog(@"no data");
    }
    
}

#define LASTSYNCTIME @"lastsynctime"

- (NSDate *)getLastSyncTime:(BOOL)isSave
{
    NSDate *nowtime = [NSDate date];
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    NSDate * defLastSyncTime = [def objectForKey:LASTSYNCTIME];
    if (isSave) {
        [def setObject:nowtime forKey:LASTSYNCTIME];
        [def synchronize];
    }
    if (defLastSyncTime) {
        nowtime = defLastSyncTime;
    }
    return nowtime;
}


#pragma mark
#pragma mark - lifecircle

- (void)dealloc
{
    [super dealloc];
//    [msgview release];
    [msgLabel release];
    [managedObjectContext release];
    [connection release];
    [buf release];
    [uploadArrayNeedFlag release];
    [motionManager release];
    [descriptionLabel release];
    [motionManager release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    msgLabel = nil;
    managedObjectContext = nil;
    connection = nil;
    buf = nil;
    uploadArrayNeedFlag = nil;
    motionManager = nil;
    descriptionLabel = nil;
    motionManager = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
