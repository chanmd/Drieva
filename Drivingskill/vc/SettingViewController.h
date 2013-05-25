//
//  SettingViewController.h
//  Instanote
//
//  Created by CMD on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMFeedback.h"

@interface SettingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UMFeedbackDataDelegate> {
    UITableView * mTableView;
    UMFeedback *umFeedback;
}

@end
