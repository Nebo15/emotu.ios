//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSMessagesViewController
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import "JSBubbleMessageCell.h"

#import "JSAvatarImageFactory.h"
#import "UIColor+JSMessagesView.h"

static const CGFloat kJSLabelPadding = 5.0f;
static const CGFloat kJSTimeStampLabelHeight = 15.0f;
static const CGFloat kJSSubtitleLabelHeight = 15.0f;
static const NSUInteger kSmileCollectionViewTag = 101;


@interface JSBubbleMessageCell()<UICollectionViewDataSource, UICollectionViewDelegate>

- (void)setup;
- (void)configureTimestampLabel;
- (void)configureAvatarImageView:(UIImageView *)imageView forMessageType:(JSBubbleMessageType)type;
- (void)configureSubtitleLabelForMessageType:(JSBubbleMessageType)type;

- (void)configureWithType:(JSBubbleMessageType)type
          bubbleImageView:(UIImageView *)bubbleImageView
                timestamp:(BOOL)hasTimestamp
                   avatar:(BOOL)hasAvatar
				 subtitle:(BOOL)hasSubtitle
                  message:(NSString *)message;

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress;

- (void)handleMenuWillHideNotification:(NSNotification *)notification;
- (void)handleMenuWillShowNotification:(NSNotification *)notification;

@end



@implementation JSBubbleMessageCell

#pragma mark - Setup

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    
    self.imageView.image = nil;
    self.imageView.hidden = YES;
    self.textLabel.text = nil;
    self.textLabel.hidden = YES;
    self.detailTextLabel.text = nil;
    self.detailTextLabel.hidden = YES;
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(handleLongPressGesture:)];
    [recognizer setMinimumPressDuration:0.4f];
    [self addGestureRecognizer:recognizer];
}

- (void)configureTimestampLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kJSLabelPadding,
                                                               kJSLabelPadding,
                                                               self.contentView.frame.size.width - (kJSLabelPadding * 2.0f),
                                                               kJSTimeStampLabelHeight)];
    label.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor js_messagesTimestampColorClassic];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    label.font = [UIFont boldSystemFontOfSize:12.0f];
    
    [self.contentView addSubview:label];
    [self.contentView bringSubviewToFront:label];
    _timestampLabel = label;
}

- (void)configureAvatarImageView:(UIImageView *)imageView forMessageType:(JSBubbleMessageType)type
{
    CGFloat avatarX = 0.5f;
    if(type == JSBubbleMessageTypeOutgoing) {
        avatarX = (self.contentView.frame.size.width - kJSAvatarImageSize);
    }
    
    CGFloat avatarY = self.contentView.frame.size.height - kJSAvatarImageSize;
    if(_subtitleLabel) {
        avatarY -= kJSSubtitleLabelHeight;
    }
    
    imageView.frame = CGRectMake(avatarX, avatarY, kJSAvatarImageSize, kJSAvatarImageSize);
    imageView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin
                                         | UIViewAutoresizingFlexibleLeftMargin
                                         | UIViewAutoresizingFlexibleRightMargin);
    
    [self.contentView addSubview:imageView];
    _avatarImageView = imageView;
}

- (void)configureSubtitleLabelForMessageType:(JSBubbleMessageType)type
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = (type == JSBubbleMessageTypeOutgoing) ? NSTextAlignmentRight : NSTextAlignmentLeft;
    label.textColor = [UIColor js_messagesTimestampColorClassic];
    label.font = [UIFont systemFontOfSize:12.5f];
    
    [self.contentView addSubview:label];
    _subtitleLabel = label;
}

- (void)configureWithType:(JSBubbleMessageType)type
          bubbleImageView:(UIImageView *)bubbleImageView
                timestamp:(BOOL)hasTimestamp
                   avatar:(BOOL)hasAvatar
				 subtitle:(BOOL)hasSubtitle
{
    CGFloat bubbleY = 0.0f;
    CGFloat bubbleX = 0.0f;
    
    CGFloat offsetX = 0.0f;
    
    if(hasTimestamp) {
        [self configureTimestampLabel];
        bubbleY = 14.0f;
    }
    
    if(hasSubtitle) {
		[self configureSubtitleLabelForMessageType:type];
	}
    
    if(hasAvatar) {
        offsetX = 4.0f;
        bubbleX = kJSAvatarImageSize;
        if(type == JSBubbleMessageTypeOutgoing) {
            offsetX = kJSAvatarImageSize - 4.0f;
        }
        
        [self configureAvatarImageView:[[UIImageView alloc] init] forMessageType:type];
    }
    
    CGRect frame = CGRectMake(bubbleX - offsetX,
                              bubbleY,
                              self.contentView.frame.size.width - bubbleX,
                              self.contentView.frame.size.height - _timestampLabel.frame.size.height - _subtitleLabel.frame.size.height);
    
    JSBubbleView *bubbleView = [[JSBubbleView alloc] initWithFrame:frame
                                                        bubbleType:type
                                                   bubbleImageView:bubbleImageView];
    
    bubbleView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                    | UIViewAutoresizingFlexibleHeight
                                    | UIViewAutoresizingFlexibleBottomMargin);
    
    [self.contentView addSubview:bubbleView];
    [self.contentView sendSubviewToBack:bubbleView];
    _bubbleView = bubbleView;
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithBubbleType:(JSBubbleMessageType)type
                   bubbleImageView:(UIImageView *)bubbleImageView
                      hasTimestamp:(BOOL)hasTimestamp
                         hasAvatar:(BOOL)hasAvatar
                       hasSubtitle:(BOOL)hasSubtitle
                   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        [self configureWithType:type
                bubbleImageView:bubbleImageView
                      timestamp:hasTimestamp
                         avatar:hasAvatar
                       subtitle:hasSubtitle];
    }
    return self;
}

- (void)dealloc
{
    _bubbleView = nil;
    _timestampLabel = nil;
    _avatarImageView = nil;
    _subtitleLabel = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TableViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.bubbleView.textView.text = nil;
    self.timestampLabel.text = nil;
    self.avatarImageView = nil;
    self.subtitleLabel.text = nil;
   // self.elements = nil;
   // [self.smilesCollectionView reloadData];
    
}

- (void)setBackgroundColor:(UIColor *)color
{
    [super setBackgroundColor:color];
    [self.contentView setBackgroundColor:color];
    [self.bubbleView setBackgroundColor:color];
}

#pragma mark - Setters

- (void)setMessage:(NSString *)msg
{
    self.bubbleView.textView.text = [self genRandStringLength:[_elements count] *3];
    self.bubbleView.textView.hidden = YES;
}

- (void)setTimestamp:(NSDate *)date
{
    self.timestampLabel.text = [NSDateFormatter localizedStringFromDate:date
                                                              dateStyle:NSDateFormatterMediumStyle
                                                              timeStyle:NSDateFormatterShortStyle];
}

- (void)setAvatarImageView:(UIImageView *)imageView
{
    [_avatarImageView removeFromSuperview];
    _avatarImageView = nil;
    
    [self configureAvatarImageView:imageView forMessageType:[self messageType]];
}

- (void)setSubtitle:(NSString *)subtitle
{
	self.subtitleLabel.text = subtitle;
}

- (void)transformTextToSmiles:(NSString *)message
{
    [_smilesCollectionView removeFromSuperview];
    _smilesCollectionView = nil;
    
    _elements = [[message stringByReplacingOccurrencesOfString:@"[" withString:@""] componentsSeparatedByString:@"]"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(30, 30)];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, MIN(240, [_elements count] * 33), (([_elements count] / 8) + 1) * 34 ) collectionViewLayout:flowLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"myCell"];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.tag = kSmileCollectionViewTag;
    
    [self.bubbleView addSubview:collectionView];
    
    _smilesCollectionView = collectionView;
    
    CGRect collectionFrame = collectionView.frame;
    
    //align on top right
    CGFloat xPosition = CGRectGetWidth(self.bubbleView.frame) - CGRectGetWidth(collectionFrame);
    collectionFrame.origin = CGPointMake( self.messageType == JSBubbleMessageTypeOutgoing? ceil(xPosition) : 10.0, 10.0);
    collectionView.frame = collectionFrame;
    
    //autoresizing so it stays at top right (flexible left and flexible bottom margin)
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.bubbleView bringSubviewToFront:collectionView];
}

#pragma mark - Getters

- (JSBubbleMessageType)messageType
{
    return self.bubbleView.type;
}

#pragma mark - Class methods

+ (CGFloat)neededHeightForBubbleMessageCellWithText:(NSString *)text
                                          timestamp:(BOOL)hasTimestamp
                                             avatar:(BOOL)hasAvatar
                                           subtitle:(BOOL)hasSubtitle
{
    CGFloat timestampHeight = hasTimestamp ? kJSTimeStampLabelHeight : 0.0f;
    CGFloat avatarHeight = hasAvatar ? kJSAvatarImageSize : 0.0f;
	CGFloat subtitleHeight = hasSubtitle ? kJSSubtitleLabelHeight : 0.0f;
    
    CGFloat subviewHeights = timestampHeight + subtitleHeight + kJSLabelPadding;
    
    CGFloat bubbleHeight = [JSBubbleView neededHeightForText:text];
    
    return subviewHeights + MAX(avatarHeight, bubbleHeight);
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(self.subtitleLabel) {
        self.subtitleLabel.frame = CGRectMake(kJSLabelPadding,
                                              self.contentView.frame.size.height - kJSSubtitleLabelHeight,
                                              self.contentView.frame.size.width - (kJSLabelPadding * 2.0f),
                                              kJSSubtitleLabelHeight);
    }
}

#pragma mark - Copying

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.bubbleView.textView.text];
    [self resignFirstResponder];
}

#pragma mark - Gestures

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress
{
    if(longPress.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
        return;
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    CGRect targetRect = [self convertRect:[self.bubbleView bubbleFrame]
                                 fromView:self.bubbleView];
    
    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
    
    self.bubbleView.bubbleImageView.highlighted = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
    [menu setMenuVisible:YES animated:YES];
}

#pragma mark - Notifications

- (void)handleMenuWillHideNotification:(NSNotification *)notification
{
    self.bubbleView.bubbleImageView.highlighted = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillHideMenuNotification
                                                  object:nil];
}

- (void)handleMenuWillShowNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillHideNotification:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
}
#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_elements count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"myCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
     UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_elements[indexPath.row]]];
    [cell addSubview:image];

    return cell;
}

#pragma mark - Random String

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

-(NSString *)genRandStringLength:(int)len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}

@end