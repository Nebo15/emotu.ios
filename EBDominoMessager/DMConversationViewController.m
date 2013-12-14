//
//  DMConversationViewController.m
//  iPhoneXMPP
//
//  Created by Evgen Bakumenko on 12/12/13.
//
//

#import "DMConversationViewController.h"
#import "XMPPStream.h"
#import "XMPPMessage.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "EBAppDelegate.h"
#import "EBUserListViewController.h"
#import "WUDemoKeyboardBuilder.h"
#import "WUEmoticonsKeyboardKeyItemGroup.h"

#define kSubtitleJobs @"Jobs"
#define kSubtitleWoz @"Steve Wozniak"
#define kSubtitleCook @"Mr. Cook"

@interface DMConversationViewController ()<JSMessagesViewDataSource, JSMessagesViewDelegate, XMPPStreamDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray *smilesKeys;
@property (nonatomic, strong) UICollectionView *smilesCollectionView;

@end

@implementation DMConversationViewController

- (void)viewDidLoad
{
    self.delegate = self;
    self.dataSource = self;
    [super viewDidLoad];
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    
    self.title = @"Messages";
    
    self.messageInputView.textView.placeHolder = @"New Message";
    
    [self.messageInputView.textView becomeFirstResponder];
    self.messageInputView.textView.delegate = self;
    self.messageInputView.textView.textColor = [UIColor clearColor];
    
    [self.messageInputView.textView switchToEmoticonsKeyboard:[WUDemoKeyboardBuilder sharedEmoticonsKeyboard]];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.messages = [NSMutableArray array];
    
    self.timestamps = [NSMutableArray array];
    
    self.subtitles = [NSMutableArray array];
    
    self.smilesKeys = [NSMutableArray array];
    
    self.avatars = [NSMutableDictionary dictionaryWithDictionary:@{kSubtitleJobs: [JSAvatarImageFactory avatarImageNamed:@"demo-avatar-jobs" croppedToCircle:YES],
                                                                   kSubtitleWoz: [JSAvatarImageFactory avatarImageNamed:@"demo-avatar-woz" croppedToCircle:YES]}];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(30, 30)];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, MIN(240, [_smilesKeys count] * 33), (([_smilesKeys count] / 8) + 1) * 34 ) collectionViewLayout:flowLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"myCell"];
    collectionView.backgroundColor = [UIColor clearColor];
    
    [self.messageInputView.textView addSubview:collectionView];
    
    _smilesCollectionView = collectionView;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - Messages view delegate: REQUIRED

- (void)didSendText:(NSString *)text
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:text];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:[_jid full]];
    [message addChild:body];
    
    [_xmppStream sendElement:message];
    
    [self.messages addObject:message];
    
    [self.timestamps addObject:[NSDate date]];
    
    [JSMessageSoundEffect playMessageReceivedSound];
        
    [self.subtitles addObject:kSubtitleJobs];

    [self finishSend];
    [self scrollToBottomAnimated:YES];
    
    [_smilesKeys removeAllObjects];
    
    [_smilesCollectionView reloadData];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[[(NSXMLElement *)_messages[indexPath.row] attributeForName:@"to"] stringValue] isEqualToString:[_jid full]] ? JSBubbleMessageTypeOutgoing : JSBubbleMessageTypeIncoming;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *bubbleUmageView;
    switch (type) {
        case JSBubbleMessageTypeIncoming:
            bubbleUmageView = [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                       color:[UIColor js_bubbleLightGrayColor]];
            break;
        case JSBubbleMessageTypeOutgoing:
            bubbleUmageView = [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                       color:[UIColor js_bubbleBlueColor]];
            break;
    }
        return bubbleUmageView;
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyEveryThree;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyAll;
}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyAll;
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages view delegate: OPTIONAL

//
//  *** Implement to customize cell further
//
- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
        
        if([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
            NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
            [attrs setValue:[UIColor blueColor] forKey:UITextAttributeTextColor];
            
            cell.bubbleView.textView.linkTextAttributes = attrs;
        }
    }
    else
    {
        cell.bubbleView.textView.textColor = [UIColor grayColor];

    }
    
    if(cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
    
    if(cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
    }
}

//  *** Required if using `JSMessagesViewTimestampPolicyCustom`
//
//  - (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
//

//  *** Implement to use a custom send button
//
//  The button's frame is set automatically for you
////  - (UIButton *)sendButtonForInputView
//

//  *** Implement to prevent auto-scrolling when message is added
//
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

#pragma mark - Messages view data source: REQUIRED

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[(NSXMLElement *)self.messages[indexPath.row] childAtIndex:0] stringValue];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.timestamps)[indexPath.row];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *subtitle = (self.subtitles)[indexPath.row];
    UIImage *image = (self.avatars)[subtitle];
    return [[UIImageView alloc] initWithImage:image];
}

- (NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.subtitles)[indexPath.row];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	//DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
	// A simple example of inbound message handling.
    
	if ([message isChatMessageWithBody])
	{
		XMPPUserCoreDataStorageObject *user = [_xmppRosterStorage userForJID:[message from]
		                                                         xmppStream:_xmppStream
                                                      managedObjectContext:_managedObjectContext_roster];
		[self.messages addObject:message];
        
        [self.timestamps addObject:[NSDate date]];
        
        
        [JSMessageSoundEffect playMessageReceivedSound];
        
        [self.subtitles addObject:user.nickname];
        [self.avatars setObject:user.photo?user.photo:[JSAvatarImageFactory avatarImageNamed:@"demo-avatar-woz" croppedToCircle:YES] forKey:user.nickname];
        
        [self finishSend];
        [self scrollToBottomAnimated:YES];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (text.length == 0 && [_smilesKeys count] > 0) {
        NSRange lastSmile = [textView.text rangeOfString:[NSString stringWithFormat:@"[%@]",_smilesKeys.lastObject] options:NSBackwardsSearch];
        
        if(lastSmile.location != NSNotFound) {
            textView.text = [textView.text stringByReplacingCharactersInRange:lastSmile
                                               withString: @""];
        }
        [_smilesKeys removeLastObject];
        if ([_smilesKeys count] == 0) {
            textView.text = nil;
            self.messageInputView.sendButton.enabled = NO;
        }
    }
    else if(text.length > 0)
    {
        textView.text = [NSString stringWithFormat:@"%@%@",textView.text,text];
        text = [text stringByReplacingOccurrencesOfString:@"[" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"]" withString:@""];
        [_smilesKeys addObject:text];
        self.messageInputView.sendButton.enabled = YES;
    }
    [_smilesCollectionView setFrame:CGRectMake(0, 0, MIN(240, [_smilesKeys count] * 33), (([_smilesKeys count] / 8) + 1) * 34 )];
    [_smilesCollectionView reloadData];
    return NO;
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_smilesKeys count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"myCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_smilesKeys[indexPath.row]]];
    [cell addSubview:image];
    
    return cell;
}

@end
