//
//  TempData.m
//  myX
//
//  Created by Man Tung on 11/2/12.
//  Copyright (c) 2012 Man Tung Chan. All rights reserved.
//

#import "TempData.h"

static NSMutableString * tempdata;

@implementation TempData

+ (NSMutableString *)getTempString
{
    return tempdata;
}

+ (void)setTempString:(NSString *)string
{
    if (!tempdata) {
        tempdata = [[NSMutableString alloc] init];
    }
    [tempdata appendFormat:@"%@", string];
}

+ (void)clearTempString
{
    [tempdata setString:@""];
}

@end
