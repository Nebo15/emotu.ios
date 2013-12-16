#import "EBNebo15APIClient.h"

static NSString * const kEBNebo15APIBaseURLString = @"http://emotu.nebo15.me/";
static NSString * const kRegisterPath = @"?action=register";
static NSString * const kConfirmPath = @"?action=confirm";
static NSString * const kGetUserListPath = @"?action=list_users";

@interface EBNebo15APIClient()

@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;

@end

@implementation EBNebo15APIClient

+ (EBNebo15APIClient *)sharedClient {
    static EBNebo15APIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kEBNebo15APIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    _manager = [AFHTTPRequestOperationManager manager];
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    return self;
}

#pragma mark - Register

- (void)registerWithPhoneNumber:(NSString *)phoneNumber withCompletion:(void(^)(BOOL))completion
{
    [_manager POST:[NSString stringWithFormat:@"%@%@", kEBNebo15APIBaseURLString, kRegisterPath] parameters:@{@"number" : phoneNumber} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error.code == 3840? YES:NO);
    }];
}

- (void)confirmRegistrationWithSMSCode:(NSString *)smsCode phoneNumber:(NSString *)phoneNumber withCompletion:(void(^)(BOOL))completion
{
    [_manager POST:[NSString stringWithFormat:@"%@%@", kEBNebo15APIBaseURLString, kConfirmPath] parameters:@{@"number" : phoneNumber, @"code" : smsCode} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO);
    }];
}

#pragma mark - User list

- (void)getUserListWithCompletion:(void(^)(BOOL, NSArray*))completion
{
   // AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [_manager GET:[NSString stringWithFormat:@"%@%@", kEBNebo15APIBaseURLString, kGetUserListPath] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        NSArray* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              
                              options:kNilOptions 
                              error:&error];
        if (!error) {
            completion(YES, json);
        }
     //   completion(YES, [responseObject allValues]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
    }];
}

@end
