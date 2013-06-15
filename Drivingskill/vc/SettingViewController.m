//
//  SettingViewController.m
//  Instanote
//
//  Created by CMD on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"


@implementation SettingViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"moretitle", @"");
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!mTableView) {
        
        mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)
                                                  style:UITableViewStyleGrouped];
        mTableView.delegate = self;
        mTableView.dataSource = self;
        [mTableView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:mTableView];
    }
    //主流程开始
    [mTableView reloadData];
    
    [self initUmengFeedback];
    
}

- (void)initUmengFeedback
{
    umFeedback = [UMFeedback sharedInstance];
    [umFeedback setAppkey:UMENG_APPKEY delegate:self];
}

/**生成列表表格 Height**/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{  
    return 40;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    switch (section) {
//        case 0: {
//            return @"Account";
//        } break;
//        case 1: {
//            return @"About Us";
//        } break;
//        default: {
//            return @"";
//        } break;
//    }
//}

/**生成列表表格**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell"];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"settingCell"] autorelease];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:16];
        cell.textLabel.textColor = [UIColor blackColor];
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"hello";
                break;
            case 1:
                cell.textLabel.text = @"About Us";
                break;
            case 2:
                cell.textLabel.text = @"Feed Back";
                break;
            case 3:
                cell.textLabel.text = @"Rate on App Store";
                cell.textLabel.backgroundColor = [UIColor redColor];
                break;
            default:
                break;
        }
        
    }
    return cell;
    
}
/**表格点击事件处理,查微博的详细信息**/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [mTableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self userinfoAction];
            break;
        case 1:
            [self aboutusAction];
            break;
        case 2:
            [self feedbackAction];
            break;
        case 3:
            [self signoutAction];
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = NO;
}

- (void)dealloc
{
    [super dealloc];
    [mTableView release];
    umFeedback.delegate = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [mTableView release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark tableviewcelldidselect methods
- (void)userinfoAction
{
    
}

- (void)feedbackAction
{
    
}

- (void)aboutusAction
{
    
}
- (void)signoutAction
{
    
}

@end
