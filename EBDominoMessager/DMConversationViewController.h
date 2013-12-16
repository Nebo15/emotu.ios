//
//  DMConversationViewController.h
//  iPhoneXMPP
//
//  Created by Evgen Bakumenko on 12/12/13.
//
//

#import "JSMessagesViewController.h"
@class XMPPStream;
@class XMPPJID;
@class XMPPRosterCoreDataStorage;

@interface DMConversationViewController : JSMessagesViewController

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *timestamps;
@property (strong, nonatomic) NSMutableArray *subtitles;
@property (strong, nonatomic) NSMutableDictionary *avatars;

@property (strong, nonatomic) NSString *jid;
@property (strong, nonatomic) XMPPStream *xmppStream;
@property (strong, nonatomic) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext_roster;

@end
