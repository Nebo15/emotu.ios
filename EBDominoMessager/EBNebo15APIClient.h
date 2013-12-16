#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface EBNebo15APIClient : AFHTTPRequestOperationManager

+ (EBNebo15APIClient *)sharedClient;

- (void)registerWithPhoneNumber:(NSString *)phoneNumber withCompletion:(void(^)(BOOL))completion;
- (void)confirmRegistrationWithSMSCode:(NSString *)smsCode phoneNumber:(NSString *)phoneNumber withCompletion:(void(^)(BOOL))completion;
- (void)getUserListWithCompletion:(void(^)(BOOL, NSArray*))completion;

@end
