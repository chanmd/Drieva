//
//  BaseCell.h
//  Instanote
//
//  Created by Man Tung on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabel+Extensions.h"
#import "Scores.h"

@interface BaseCell : UITableViewCell
{
    UILabel * contentlabel;
    UILabel * timelabel;
    CGFloat cellheight;
    Scores * scores;
    @private
    NSDateFormatter *dateFormatter;
}

@property (nonatomic, retain)UILabel * contentlabel;
@property (nonatomic, retain)UILabel * timelabel;
@property (nonatomic, assign)CGFloat cellheight;
@property (nonatomic, retain)Scores * scores;
@property (nonatomic, readonly, retain) NSDateFormatter *dateFormatter;

@end
