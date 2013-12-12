//
//  DMConversationViewController.h
//  iPhoneXMPP
//
//  Created by Evgen Bakumenko on 12/12/13.
//
//

#import "JSMessagesViewController.h"
@class XMPPStream;

@interface DMConversationViewController : JSMessagesViewController

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *timestamps;
@property (strong, nonatomic) NSMutableArray *subtitles;
@property (strong, nonatomic) NSDictionary *avatars;

@end
