//
//  msgView.h
//  Instanote
//
//  Created by Man Tung on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface msgView : UIView
{
    UILabel * msgLabel;
}

- (void)show;

- (void)setText:(NSString *)msg;

@end
