#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "XMPPFramework.h"


@class DMConversationViewController;

extern NSString * const kNotificationNewMessageReceived;


@interface iPhoneXMPPAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) DMConversationViewController *conversationVC;

@end
