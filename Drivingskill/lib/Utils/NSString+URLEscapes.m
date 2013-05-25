//
//  NSString+URLEscapes.m
//  url_schema_convertor
//
//  Created by Doors.Du on 11-4-14.
//  Copyright 2011 Doors Studio. All rights reserved.
//

#import "NSString+URLEscapes.h"

#define UE_DEBUG    0       //  0: No logs in console
                            // !0: Some useful logs will be printed in console

// I can't find a better way to convert a hexadecimal string to an integer.
// So I impelement the two functions below. If you find, please tell me.
int HexCharToInt(const char c)
{
    if (c >= '0' && c <= '9')
    {
        return (c - '0');
    }
    else if (c >= 'a' && c <= 'f')
    {
        return (c - 'a' + 10);
    }
    else if (c >= 'A' && c <= 'F')
    {
        return (c - 'A' + 10);
    }
    else
    {
        return 0;
    }
}

int HexStringToInt(const char *hex)
{
    int ret = 0;
    
    if (NULL != hex)
    {
        int base    = 1;
        int ind     = strlen(hex) - 1;
        
        while (ind >= 0)
        {
            ret += base * HexCharToInt(hex[ind--]);
            base *= 0x10;   // 10(hex) = 16(dec)
        }
    }
    
#if UE_DEBUG
    NSLog(@"HexStringToInt: %s -> %d", hex, ret);
#endif
    
    return ret;
}

@implementation NSString (URLEscapes)

- (NSString *)escapedURLString
{
    NSString *ret   = self;
    char *src       = (char *)[self UTF8String];
    
    if (NULL != src)
    {
        NSMutableString *tmp = [NSMutableString string];
        int ind              = 0;
        
        while (ind < strlen(src))   // NOTE: if src is NULL, strlen() will crash.
        {
            // The characters which are not ASCII code and the signals such as 
            // ';', ':', '#' and so on should be converted to percent escape codes
            // when they are used as url arguments.
            // You can find official references from 
            // http://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/NSURL_Class/Reference/Reference.html
            if (src[ind] < 0
                || (' ' == src[ind]
                    || ':' == src[ind]
                    || '/' == src[ind]
                    || '%' == src[ind]
                    || '#' == src[ind]
                    || ';' == src[ind]
                    || '@' == src[ind]))
            {
#if UE_DEBUG
                NSLog(@"escapedURLString: src[%d] = %d", ind, src[ind]);
#endif
                
                [tmp appendFormat:@"%%%X", (unsigned char)src[ind++]];
            }
            else 
            {
                [tmp appendFormat:@"%c", src[ind++]];
            }
        }
        
        ret = tmp;
        
#if UE_DEBUG
        NSLog(@"Escaped string = %@", tmp);
#endif
    }
    
    return ret;
}

- (NSString *)originalURLString
{
    NSString *ret = self;
    
    const char *src = [self UTF8String];
    
    if (NULL != src)
    {
        int src_len     = strlen(src);
        char *tmp       = (char *)malloc(src_len + 1);
        char word[3]    = {0};
        unsigned char c = 0;
        int ind         = 0;
        
        bzero(tmp, src_len + 1);    // initialize tmp
        
        while (ind < src_len)
        {
            if ('%' == src[ind])
            {
                bzero(word, 3);
                
                word[0] = src[ind + 1];
                word[1] = src[ind + 2];
                
                c = (char)HexStringToInt(word);
                
#if UE_DEBUG
                NSLog(@"originalURLString: c = %d", c);
#endif
                
                sprintf(tmp, "%s%c", tmp, c);
                
                ind += 3;   // NOTE: the length of a escape code is 3, e.g. "%E6"
            }
            else 
            {
                sprintf(tmp, "%s%c", tmp, src[ind++]);
            }
        }
        
        ret = [NSString stringWithUTF8String:tmp];
        
#if UE_DEBUG
        NSLog(@"Original string = %@", ret);
#endif
        
        free(tmp);  // DO NOT forget to free tmp
    }
    
    return ret;
}

@end
