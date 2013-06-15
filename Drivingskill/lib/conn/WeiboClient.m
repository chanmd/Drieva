//
//  WeiboClient.m
//  WeiboFon
//
//  Created by kaz on 7/13/08.
//  Copyright naan studio 2008. All rights reserved.
//

#import "WeiboClient.h"
#import "StringUtil.h"
#import "JSON.h"


@implementation WeiboClient

@synthesize request;
@synthesize context;
@synthesize hasError;
@synthesize errorMessage;
@synthesize errorDetail;

- (id)initWithTarget:(id)aDelegate action:(SEL)anAction
{
    [super initWithDelegate:aDelegate];
    action = anAction;
    hasError = false;
    return self;
}

- (void)dealloc
{
    [errorMessage release];
    [errorDetail release];
    [super dealloc];
}



- (NSString*) nameValString: (NSDictionary*) dict {
	NSArray* keys = [dict allKeys];
	NSString* result = [NSString string];
	int i;
	for (i = 0; i < [keys count]; i++) {
        result = [result stringByAppendingString:
                  [@"--" stringByAppendingString:
                   [TWITTERFON_FORM_BOUNDARY stringByAppendingString:
                    [@"\r\nContent-Disposition: form-data; name=\"" stringByAppendingString:
                     [[keys objectAtIndex: i] stringByAppendingString:
                      [@"\"\r\n\r\n" stringByAppendingString:
                       [[dict valueForKey: [keys objectAtIndex: i]] stringByAppendingString: @"\r\n"]]]]]]];
	}
	
	return result;
}

- (NSString *)_encodeString:(NSString *)string
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
																		   (CFStringRef)string, 
																		   NULL, 
																		   (CFStringRef)@";/?:@&=$+{}<>,",
																		   kCFStringEncodingUTF8);
    return [result autorelease];
}


- (NSString *)_queryStringWithBase:(NSString *)base parameters:(NSDictionary *)params prefixed:(BOOL)prefixed
{
    // Append base if specified.
    NSMutableString *str = [NSMutableString stringWithCapacity:0];
    if (base) {
        [str appendString:base];
    }
    
    // Append each name-value pair.
    if (params) {
        int i;
        NSArray *names = [params allKeys];
        for (i = 0; i < [names count]; i++) {
            if (i == 0 && prefixed) {
                [str appendString:@"?"];
            } else if (i > 0) {
                [str appendString:@"&"];
            }
            NSString *name = [names objectAtIndex:i];
            [str appendString:[NSString stringWithFormat:@"%@=%@", 
							   name, [self _encodeString:[params objectForKey:name]]]];
        }
    }
    
    return str;
}


- (NSString *)getURL:(NSString *)path 
	 queryParameters:(NSMutableDictionary*)params {
    NSString* fullPath = [NSString stringWithFormat:@"%@://%@/%@", 
						  (_secureConnection) ? @"https" : @"http",
						  API_DOMAIN, path];
	if (params) {
        fullPath = [self _queryStringWithBase:fullPath parameters:params prefixed:YES];
    }
//    NSLog(@"%@",fullPath);
	return fullPath;
}

#pragma mark -
#pragma mark REST API methods
#pragma mark -

#pragma mark Status methods


- (void)getPublicTimeline
{
    NSString *path = [NSString stringWithFormat:@"statuses/public_timeline.%@", API_FORMAT];
	[super get:[self getURL:path queryParameters:nil]];
}

#pragma mark -
#pragma mark Comments

- (void)putdata:(NSString *)data
{
    
}

- (void)timeline:(int)ps pageNum:(int)pn pageType:(int)type
{
    NSString *path = [NSString stringWithFormat:@"topicAction_getNewTopicForPhone.%@", API_FORMAT];
	
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (pn > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", pn] forKey:@"pageNum"];
    }
    if (ps > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", ps] forKey:@"pageSize"];
    }
    if (type > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", type] forKey:@"type"];
    }
	[super get:[self getURL:path queryParameters:params]];
}

- (void)addComment:(NSString *)topicid userId:(int)userid commentContent:(NSString *)content Source:(int)source
{
    NSString *path = [NSString stringWithFormat:@"topicAction_insertCommentForPhone.%@", API_FORMAT];
    
    NSMutableString *postBody = [[NSMutableString alloc] init];
    [postBody appendFormat:@"tid=%@", topicid];
    [postBody appendFormat:@"&userId=%d", userid];
    [postBody appendFormat:@"&source=%d", source];
    [postBody appendFormat:@"&comcontent=%@", [content encodeAsURIComponent]];
    NSLog(@"%@", postBody);
    [self post:[self getURL:path queryParameters:nil] body:postBody];
}

- (void)addCommentGreat:(NSString *)commentId userId:(int)userid Great:(int)great
{
    
}


- (void)topicCommnet:(NSString *)tid pageNum:(int)pn pageSize:(int)ps
{
    NSString *path = [NSString stringWithFormat:@"topicAction_getComForPhone.%@", API_FORMAT];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	[params setObject:[NSString stringWithFormat:@"%@", tid] forKey:@"tid"];
    if (pn > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", pn] forKey:@"pageNum"];
    }
    if (ps > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", ps] forKey:@"pageSize"];
    }
	[super get:[self getURL:path queryParameters:params]];
}

- (void)login:(NSString *)email pwd:(NSString *)password
{
    NSString *path = [NSString stringWithFormat:@"userInfoAction_ajaxLoginForPhone.%@", API_FORMAT];
    
    NSMutableString *postBody = [[NSMutableString alloc] init];
    [postBody appendFormat:@"email=%@", email];
    [postBody appendFormat:@"&pwd=%@", password];
    [self post:[self getURL:path queryParameters:nil] body:postBody];
}

- (void)forgot:(NSString *)email
{
    NSString *path = [NSString stringWithFormat:@"userInfoAction_ajaxForgetSendEmail.%@", API_FORMAT];
    NSMutableString *postBody = [[NSMutableString alloc] init];
    [postBody appendFormat:@"instance.email=%@", email];
    [self post:[self getURL:path queryParameters:nil] body:postBody];
}

- (void)reguser:(NSString *)email pwd:(NSString *)password
{
    NSString *path = [NSString stringWithFormat:@"userInfoAction_regLogin.%@", API_FORMAT];
    NSMutableString *postBody = [[NSMutableString alloc] init];
    [postBody appendFormat:@"email=%@", email];
    [postBody appendFormat:@"&pwd=%@", password];
    [self post:[self getURL:path queryParameters:nil] body:postBody];
}


- (void)getComments:(long long)statusId 
	 startingAtPage:(int)page 
			  count:(int)count
{
	
	NSString *path = [NSString stringWithFormat:@"statuses/comments.%@", API_FORMAT];
	
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	[params setObject:[NSString stringWithFormat:@"%lld", statusId] forKey:@"id"];
    if (page > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    if (count > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    }
	[super get:[self getURL:path queryParameters:params]];
}

- (void)getFriends:(long long)userId 
	 cursor:(int)cursor 
			  count:(int)count
{
	
	NSString *path = [NSString stringWithFormat:@"statuses/friends.%@", API_FORMAT];
	
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	[params setObject:[NSString stringWithFormat:@"%lld", userId] forKey:@"user_id"];
	[params setObject:[NSString stringWithFormat:@"%d", cursor] forKey:@"cursor"];
    if (count > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    }
	[super get:[self getURL:path queryParameters:params]];
}


- (void)getFollowers:(long long)userId 
			cursor:(int)cursor 
			 count:(int)count
{
	
	NSString *path = [NSString stringWithFormat:@"statuses/followers.%@", API_FORMAT];
	
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	[params setObject:[NSString stringWithFormat:@"%lld", userId] forKey:@"user_id"];
	[params setObject:[NSString stringWithFormat:@"%d", cursor] forKey:@"cursor"];
    if (count > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    }
	[super get:[self getURL:path queryParameters:params]];
}

- (void)getUser:(NSString *)userId
{
	
    NSString *path = [NSString stringWithFormat:@"users/show.%@", API_FORMAT];
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	[params setObject:[NSString stringWithFormat:@"%@", userId] forKey:@"user_id"];
	[super get:[self getURL:path queryParameters:params]];
}

- (void)getUserByScreenName:(NSString *)screenName {
	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	[params setObject:[NSString stringWithFormat:@"%@", screenName] forKey:@"screen_name"];
	
    NSString *path = [NSString stringWithFormat:@"users/show.%@", API_FORMAT];
	[super get:[self getURL:path queryParameters:params]];
}

- (void)getFriendship:(long long)userId {
	//friendships/show.xml?target_id=10503
    NSString *path = [NSString stringWithFormat:@"friendships/show.%@", API_FORMAT];
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	[params setObject:[NSString stringWithFormat:@"%lld", userId] forKey:@"target_id"];
	[super get:[self getURL:path queryParameters:params]];
}

- (void)follow:(long long)userId {
	///friendships/create.xml?user_id=1401881
    NSString *path = [NSString stringWithFormat:@"friendships/create.%@", API_FORMAT];
	NSString *postString = [NSString stringWithFormat:@"user_id=%lld",userId];
    [self post:[self getURL:path queryParameters:nil]
		  body:postString];
	
}

- (void)unfollow:(long long)userId {
	///friendships/destroy.xml?user_id=1401881
    NSString *path = [NSString stringWithFormat:@"friendships/destroy.%@", API_FORMAT];
	NSString *postString = [NSString stringWithFormat:@"user_id=%lld",userId];
    [self post:[self getURL:path queryParameters:nil]
		  body:postString];
}

- (void)getStatus:(long long)statusID
{
    
    NSString *path = [NSString stringWithFormat:@"statuses/show/:%lld.%@", statusID,API_FORMAT];
    [super get:[self getURL:path queryParameters:nil]];
}


- (void)post:(NSString*)tweet
{
	
    NSString *path = [NSString stringWithFormat:@"statuses/update.%@", API_FORMAT];
    NSString *postString = [NSString stringWithFormat:@"status=%@",
                            [tweet encodeAsURIComponent]];
	
    [self post:[self getURL:path queryParameters:nil]
		  body:postString];
}


- (void)upload:(NSData*)jpeg status:(NSString *)status
{
	
	NSString *path = [NSString stringWithFormat:@"statuses/upload.%@", API_FORMAT];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
						 status, @"status",
                         nil];
    
    NSString *param = [self nameValString:dic];
    NSString *footer = [NSString stringWithFormat:@"\r\n--%@--\r\n", TWITTERFON_FORM_BOUNDARY];
    
    param = [param stringByAppendingString:[NSString stringWithFormat:@"--%@\r\n", TWITTERFON_FORM_BOUNDARY]];
    param = [param stringByAppendingString:@"Content-Disposition: form-data; name=\"pic\";filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"];
//    NSLog(@"jpeg size: %d", [jpeg length]);
	
    NSMutableData *data = [NSMutableData data];
    [data appendData:[param dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:jpeg];
    [data appendData:[footer dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	[params setObject:status forKey:@"status"];
	//[params setObject:[NSString stringWithFormat:@"%@", statusId] forKey:@"source"];

    [self post:[self getURL:path queryParameters:params] data:data];
}


//是否在转发的同时发表评论。0表示不发表评论，1表示发表评论给当前微博，2表示发表评论给原微博，3是1、2都发表。默认为0。
- (void)repost:(long long)statusId
		 tweet:(NSString*)tweet
         iscomment:(int)commentstatus {
	
    NSString *path = [NSString stringWithFormat:@"statuses/repost.%@", API_FORMAT];
    NSMutableString * postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"id=%lld&status=%@",
							statusId,
                            [tweet encodeAsURIComponent]];
	if (commentstatus > 0) {
        [postString appendFormat:@"&is_comment=%d", commentstatus];
    }
    [self post:[self getURL:path queryParameters:nil]
		  body:[NSString stringWithString:postString]];
    
    //[postString release];
}

//1：回复中不自动加入“回复@用户名”，0：回复中自动加入“回复@用户名”.默认为0.  without_mention  int
//当评论一条转发微博时，是否评论给原微博。0:不评论给原微博。1：评论给原微博。默认0. comment_ori  int 
- (void)comment:(long long)statusId
	  commentId:(long long)commentId
		 comment:(NSString*)comment
            withoutmention:(int)mention
                commentori:(int)committoori {
	
    NSString *path = [NSString stringWithFormat:@"statuses/comment.%@", API_FORMAT];
    NSMutableString * postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"id=%lld&comment=%@",
                  statusId,
                  [comment encodeAsURIComponent]];
	if (commentId) {
		[postString appendFormat:@"&cid=%lld", commentId];
	}
    if (mention > 0) {
        [postString appendFormat:@"&without_mention=%d", mention];
    }
    if (committoori > 0) {
        [postString appendFormat:@"&comment_ori=%d", committoori];
    }
	
    [self post:[self getURL:path queryParameters:nil]
		  body:[NSString stringWithString:postString]];
    
    //[postString release];
}


- (void)reply:(long long)commentId comment:(NSString *)commentContent statusId:(long long)statusid withoutMention:(int)withoutmention
{
    
    NSString *path = [NSString stringWithFormat:@"statuses/reply.%@", API_FORMAT];
    NSMutableString * postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"id=%lld&comment=%@",
     statusid,
     [commentContent encodeAsURIComponent]];
	if (commentId) {
		[postString appendFormat:@"&cid=%lld", commentId];
	}
    if (withoutmention > 0) {
        [postString appendFormat:@"&without_mention=%d", withoutmention];
    }
    [self post:[self getURL:path queryParameters:nil]
		  body:[NSString stringWithString:postString]];
}

- (void)sendDirectMessage:(NSString*)text 
		  to:(long long)recipientedId
{
	
    NSString *path = [NSString stringWithFormat:@"direct_messages/new.%@", API_FORMAT];
    
    NSString *postString = [NSString stringWithFormat:@"text=%@&user_id=%lld"
							, [text encodeAsURIComponent], recipientedId];
    
    [self post:[self getURL:path queryParameters:nil] body:postString];
    
}



- (void)authError
{
    self.errorMessage = @"Authentication Failed";
    self.errorDetail  = @"Wrong username/Email and password combination.";   
    if ([delegate retainCount] > 0 && [delegate respondsToSelector:action]) {
        [delegate performSelector:action withObject:self withObject:nil];    
    }
}

- (void)URLConnectionDidFailWithError:(NSError*)error
{
    hasError = true;
    if (error.code ==  NSURLErrorUserCancelledAuthentication) {
        statusCode = 401;
        [self authError];
    }
    else {
        self.errorMessage = @"Connection Failed";
        self.errorDetail  = [error localizedDescription];
        if ([delegate retainCount] > 0 && [delegate respondsToSelector:action]) {
            [delegate performSelector:action withObject:self withObject:nil];
        }   
    }
    [self autorelease];
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0) {
//        NSLog(@"Authentication Challenge");
        NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
        NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
        NSURLCredential* cred = [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
    } else {
//        NSLog(@"Failed auth (%d times)", [challenge previousFailureCount]);
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    hasError = true;
    [self authError];
    [self autorelease];
}

- (void)URLConnectionDidFinishLoading:(NSString*)content
{
    switch (statusCode) {
        case 401: // Not Authorized: either you need to provide authentication credentials, or the credentials provided aren't valid.
            hasError = true;
            [self authError];
            goto out;
            
        case 304: // Not Modified: there was no new data to return.
            if ([delegate retainCount] > 0 && [delegate respondsToSelector:action]) {
                [delegate performSelector:action withObject:self withObject:nil];
            }
            goto out;
            
        case 400: // Bad Request: your request is invalid, and we'll return an error message that tells you why. This is the status code returned if you've exceeded the rate limit
        case 200: // OK: everything went awesome.
        case 403: // Forbidden: we understand your request, but are refusing to fulfill it.  An accompanying error message should explain why.
            break;
                
        case 404: // Not Found: either you're requesting an invalid URI or the resource in question doesn't exist (ex: no such user). 
        case 500: // Internal Server Error: we did something wrong.  Please post to the group about it and the Weibo team will investigate.
        case 502: // Bad Gateway: returned if Weibo is down or being upgraded.
        case 503: // Service Unavailable: the Weibo servers are up, but are overloaded with requests.  Try again later.
        default:
        {
            hasError = true;
            self.errorMessage = @"Server responded with an error";
            self.errorDetail  = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
            if ([delegate retainCount] > 0 && [delegate respondsToSelector:action]) {
                [delegate performSelector:action withObject:self withObject:nil];
            }
            goto out;
        }
    }
#if 0
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathStr;
    if (request == 0) {
        pathStr = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"friends_timeline.json"];
    }
    else if (request == 1) {
        pathStr = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"replies.json"];
    }
    else if (request == 2) {
        pathStr = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"direct_messages.json"];
    }
    if (request <= 2) {
        NSData *data = [fileManager contentsAtPath:pathStr];
        content = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    }
#endif
    
    NSObject *obj = [content JSONValue];
    if (request == WEIBO_REQUEST_FRIENDSHIP_EXISTS) {
        NSRange r = [content rangeOfString:@"true" options:NSCaseInsensitiveSearch];
  	  	obj = [NSNumber numberWithBool:r.location != NSNotFound];
    }
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)obj;
        NSString *msg = [dic objectForKey:@"error"];
        if (msg) {
            hasError = true;
            self.errorMessage = @"Weibo Server Error";
            self.errorDetail  = msg;
        }
    }
    if ([delegate retainCount] > 0 && [delegate respondsToSelector:action]) {
        [delegate performSelector:action withObject:self withObject:obj];
    }
    
  out:
    [self autorelease];
}


- (void)getUserTimelineSinceID:(long long)sinceID UserID:(long long)userId maxID:(long long)maxId Count:(int)count Page:(int)page baseAPP:(int)baseApp Feature:(int)feature
{
    
    NSString *path = [NSString stringWithFormat:@"statuses/user_timeline.%@", API_FORMAT];
//	NSLog(@"_________:%i",userId);
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (sinceID > 0) {
        [params setObject:[NSString stringWithFormat:@"%lld", sinceID] forKey:@"since_id"];
    }
    if (maxId > 0) {
        [params setObject:[NSString stringWithFormat:@"%lld", maxId] forKey:@"max_id"];
    }
    if (page > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    if (count > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    }
    if (userId > 0) {
        [params setObject:[NSString stringWithFormat:@"%lld", userId] forKey:@"user_id"];
    }
    if (baseApp > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", baseApp] forKey:@"base_app"];
    }
    if (feature > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", feature] forKey:@"feature"];
    }
    
	[super get:[self getURL:path queryParameters:params]];
}

//notices methods above.

- (void)commenttomeSinceId:(long long)sinceId Max_ID:(long long)max_id Count:(int)count Page:(int)page Filter_by_author:(int)filterbyauthor Filter_by_source:(int)filterbysource
{
    
    NSString *path = [NSString stringWithFormat:@"statuses/comments_to_me.%@", API_FORMAT];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (sinceId > 0) {
        [params setObject:[NSString stringWithFormat:@"%lld", sinceId] forKey:@"since_id"];
    }
    if (max_id > 0) {
        [params setObject:[NSString stringWithFormat:@"%lld", max_id] forKey:@"max_id"];    
    }
    if (page > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    if (count > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    }
    if (filterbyauthor > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", filterbyauthor] forKey:@"filter_by_author"];
    }
    if (filterbysource > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", filterbysource] forKey:@"filter_by_source"];
    }
	[super get:[self getURL:path queryParameters:params]];
}


- (void)commentbymeSinceId:(long long)sinceId Max_ID:(long long)max_id Count:(int)count Page:(int)page Filter_by_source:(int)filterbysource
{
    
    NSString *path = [NSString stringWithFormat:@"comments/by_me.%@", API_FORMAT];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (sinceId > 0) {
        [params setObject:[NSString stringWithFormat:@"%lld", sinceId] forKey:@"since_id"];
    }
    if (max_id > 0) {
        [params setObject:[NSString stringWithFormat:@"%lld", max_id] forKey:@"max_id"];
    }
    if (page > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    if (count > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    }
    if (filterbysource > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", filterbysource] forKey:@"filter_by_source"];
    }
	[super get:[self getURL:path queryParameters:params]];
}



//ag type includes 1.comment and 2.@me and 3.private mail and 4.followscount
- (void)resetCountByType:(int)type
{
    
    NSString *path = [NSString stringWithFormat:@"statuses/unread.%@", API_FORMAT];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (type > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", type] forKey:@"type"];
    }
	[super get:[self getURL:path queryParameters:params]];
    
}

////end notice methods




- (void)alert
{
	UIAlertView *sAlert = [[[UIAlertView alloc] initWithTitle:errorMessage
                                        message:errorDetail
									   delegate:self
							  cancelButtonTitle:@"Close"
							  otherButtonTitles:nil] autorelease];
    [sAlert show];
}

- (void)cancel
{
    [super cancel];
}

@end
