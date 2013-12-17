//
//  EBContact.h
//  EBDominoMessager
//
//  Created by Evgen Bakumenko on 12/17/13.
//  Copyright (c) 2013 Evgen Bakumenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBContact : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSArray *numbers;
@property (nonatomic, copy) NSArray *emails;
@property (nonatomic, copy) NSString *jid;

@end
