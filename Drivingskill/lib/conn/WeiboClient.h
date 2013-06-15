#import <UIKit/UIKit.h>
#import "URLConnection.h"


typedef enum {
    WEIBO_REQUEST_TIMELINE,
    WEIBO_REQUEST_REPLIES,
    WEIBO_REQUEST_MESSAGES,
    WEIBO_REQUEST_SENT,
    WEIBO_REQUEST_FAVORITE,
    WEIBO_REQUEST_DESTROY_FAVORITE,
    WEIBO_REQUEST_CREATE_FRIENDSHIP,
    WEIBO_REQUEST_DESTROY_FRIENDSHIP,
    WEIBO_REQUEST_FRIENDSHIP_EXISTS,
} RequestType;

@interface WeiboClient : URLConnection
{
    RequestType request;
    id          context;
    SEL         action;
    BOOL        hasError;
    NSString*   errorMessage;
    NSString*   errorDetail;
    BOOL _secureConnection;
}

@property(nonatomic, readonly) RequestType request;
@property(nonatomic, assign) id context;
@property(nonatomic, assign) BOOL hasError;
@property(nonatomic, copy) NSString* errorMessage;
@property(nonatomic, copy) NSString* errorDetail;

- (id)initWithTarget:(id)aDelegate action:(SEL)anAction;

- (void)addComment:(NSString *)topicid userId:(int)userid commentContent:(NSString *)content Source:(int)source;

- (void)addCommentGreat:(NSString *)commentId userId:(int)userid Great:(int)great;

- (void)topicCommnet:(NSString *)tid pageNum:(int)pn pageSize:(int)ps;

- (void)timeline:(int)ps pageNum:(int)pn pageType:(int)type;

- (void)login:(NSString *)email pwd:(NSString *)password;

- (void)forgot:(NSString *)email;

- (void)reguser:(NSString *)email pwd:(NSString *)password;


///////////end notices

- (void)alert;

@end
