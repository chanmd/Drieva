//
//  UILabel+Extensions.m
//  Two1Cake
//
//  Created by CMD on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UILabel+Extensions.h"

@implementation UILabel (Extensions)

- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
    self.lineBreakMode = UILineBreakModeWordWrap;
    self.numberOfLines = 0;
    [self sizeToFit];
}

@end
