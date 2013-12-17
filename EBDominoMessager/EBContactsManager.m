//
//  EBContactsManager.m
//  EBDominoMessager
//
//  Created by Evgen Bakumenko on 12/17/13.
//  Copyright (c) 2013 Evgen Bakumenko. All rights reserved.
//
@import AddressBook;
#import "EBContactsManager.h"
#import "EBContact.h"

@implementation EBContactsManager

+ (EBContactsManager *)sharedManager
{
    static  EBContactsManager*_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[EBContactsManager alloc] init];
    });
    return _sharedManager;
}

- (NSArray *)getAllContacts
{
    
    CFErrorRef *error = nil;
    
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        
#ifdef DEBUG
        NSLog(@"Fetching contact info ----> ");
#endif
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];
        
        NSMutableArray *people = (__bridge_transfer NSMutableArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        for (int i = 0; i < nPeople; i++)
        {
            EBContact *contact = [EBContact new];
            
            ABRecordRef person = (__bridge ABRecordRef)(people[i]);//CFArrayGetValueAtIndex(allPeople, i);
            
            //get First Name and Last Name
            
            NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            
            NSString *lastName =  (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            if (!firstName) {
                firstName = @"";
            }
            if (!lastName) {
                lastName = @"";
            }
            
            contact.name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            
            // get contacts picture, if pic doesn't exists, show standart one
            
            NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(person);
            contact.image = [UIImage imageWithData:imgData];
            if (!contact.image) {
                contact.image = [UIImage imageNamed:@"NOIMG.png"];
            }
            //get Phone Numbers
            
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            
            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
                
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = (__bridge_transfer NSString *) phoneNumberRef;
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                [phoneNumbers addObject:phoneNumber];
                
                //NSLog(@"All numbers %@", phoneNumbers);
                
            }
            [contact setNumbers:phoneNumbers];
            
            //get Contact email
            
            NSMutableArray *contactEmails = [NSMutableArray new];
            ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
            
            for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
                CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                NSString *contactEmail = (__bridge_transfer NSString *)contactEmailRef;
                
                [contactEmails addObject:contactEmail];
                // NSLog(@"All emails are:%@", contactEmails);
                
            }
            
            [contact setEmails:contactEmails];
  
            [items addObject:contact];
            
#ifdef DEBUG
            //NSLog(@"Person is: %@", contacts.firstNames);
            //NSLog(@"Phones are: %@", contacts.numbers);
            //NSLog(@"Email is:%@", contacts.emails);
#endif
        }
        return items;

    } else {
#ifdef DEBUG
        NSLog(@"Cannot fetch Contacts :( ");        
#endif
        return NO;
    }
}

@end
