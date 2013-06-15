//
//  Connection.m
//  TwitterFon
//
//  Created by kaz on 7/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "URLConnection.h"
#import "StringUtil.h"
#import "DebugUtils.h"

@implementation URLConnection

@synthesize buf;
@synthesize statusCode;
@synthesize requestURL;

- (id)initWithDelegate:(id)aDelegate
{
	self = [super init];
	delegate = aDelegate;
    statusCode = 0;
	return self;
}

- (void)dealloc
{
    [requestURL release];
	[connection release];
	[buf release];
	[super dealloc];
}


- (void)get:(NSString*)aURL
{
    [connection release];
	[buf release];
    statusCode = 0;
    
    self.requestURL = aURL;
    
    NSString *URL = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aURL, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
    [URL autorelease];
	NSURL *finalURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", 
											URL,
											([URL rangeOfString:@"?"].location != NSNotFound) ? @"&" : @"?"]];
	
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

-(void)post:(NSString*)aURL body:(NSString*)body
{
    [connection release];
	[buf release];
    statusCode = 0;
    
    self.requestURL = aURL;
    
    NSString *URL = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aURL, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
	[URL autorelease];
	NSURL *finalURL = [NSURL URLWithString:URL];
	NSMutableURLRequest* req;
	req = [NSMutableURLRequest requestWithURL:finalURL
                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                              timeoutInterval:NETWORK_TIMEOUT];
    [req setHTTPMethod:@"POST"];
    [req setHTTPShouldHandleCookies:NO];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    int contentLength = [body lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    [req setValue:[NSString stringWithFormat:@"%d", contentLength] forHTTPHeaderField:@"Content-Length"];
	NSString *finalBody = [NSString string];
	if (body) {
		finalBody = [finalBody stringByAppendingString:body];
	}
	[req setHTTPBody:[finalBody dataUsingEncoding:NSUTF8StringEncoding]];
	
	buf = [[NSMutableData data] retain];
	connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)post:(NSString*)aURL data:(NSData*)data
{
    [connection release];
	[buf release];
    statusCode = 0;

    self.requestURL = aURL;

    NSString *URL = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aURL, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
    [URL autorelease];
	NSURL *finalURL = [NSURL URLWithString:URL];
	NSMutableURLRequest* req;
	req = [NSMutableURLRequest requestWithURL:finalURL
                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                              timeoutInterval:NETWORK_TIMEOUT];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", TWITTERFON_FORM_BOUNDARY];
    [req setHTTPShouldHandleCookies:NO];
    [req setHTTPMethod:@"POST"];
    [req setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [req setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:data];
	buf = [[NSMutableData data] retain];
	connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
//        NSLog(@"Response: %d", statusCode);
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
}

@end
