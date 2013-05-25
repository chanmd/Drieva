//
//  TempData.h
//  myX
//
//  Created by Man Tung on 11/2/12.
//  Copyright (c) 2012 Man Tung Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TempData : NSObject

+ (NSMutableString *)getTempString;

+ (void)setTempString:(NSString *)string;

+ (void)clearTempString;

@end
