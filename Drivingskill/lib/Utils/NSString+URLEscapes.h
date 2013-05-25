//
//  NSString+URLEscapes.h
//  url_schema_convertor
//
//  Created by Doors.Du on 11-4-14.
//  Copyright 2011 Doors Studio. All rights reserved.
//

@interface NSString (URLEscapes)

/*!
 @method escapedURLString
 @result 
 An autorelease NSString object with all special characters being converted to
 percent escape codes.
 @discussion
 If you want to convert a url string, you should NOT send this message to a receiver
 with format "http://www.xxx.com/page.x?arg1=1&arg2=2" directly. Because that
 percent escape codes are only used in url request arguments.
 */
- (NSString *)escapedURLString;

/*!
 @method originalURLString
 @result 
 An autorelease NSString object with all escaped codes being converted to
 readable characters.
 @discussion
 DO NOT send this message to a receiver without escaped codes but within '%', such
 as "url%url". If you do this, you'll get an unexpected result.
 */
- (NSString *)originalURLString;

@end
