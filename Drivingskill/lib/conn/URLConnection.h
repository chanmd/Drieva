#import <Foundation/Foundation.h>

@interface URLConnection : NSObject
{
	id                  delegate;
    NSString*           requestURL;
	NSURLConnection*    connection;
	NSMutableData*      buf;
    int                 statusCode;
}

@property (nonatomic, readonly) NSMutableData* buf;
@property (nonatomic, assign) int statusCode;
@property (nonatomic, copy) NSString* requestURL;

- (id)initWithDelegate:(id)delegate;
- (void)get:(NSString*)URL;
- (void)post:(NSString*)aURL body:(NSString*)body;
- (void)post:(NSString*)aURL data:(NSData*)data;
- (void)cancel;

- (void)URLConnectionDidFailWithError:(NSError*)error;
- (void)URLConnectionDidFinishLoading:(NSString*)content;

@end
