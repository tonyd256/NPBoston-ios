//
//  NPAPIClient.m
//  NPBoston
//
//  Created by Tony DiPasquale on 4/28/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPAPIClient.h"
#import "NPAppSession.h"
#import "NPUtils.h"
#import "NPWorkout.h"
#import "NPAnalytics.h"
#import "NPUser.h"

static NSString * const kAPIBaseURL = @"https://shielded-sea-7944.herokuapp.com/api/v1/";

@implementation NPAPIClient

+ (NPAPIClient *)sharedClient
{
    static NPAPIClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[NPAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURL]];
    });
    return client;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) return nil;

    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];

    return self;
}

#pragma mark - Overridden methods

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    if (![NPAppSession sharedSession].token) {
        return [super requestWithMethod:method path:path parameters:parameters];
    } else {
        return [super requestWithMethod:method path:[path stringByAppendingFormat:@"?token=%@", [NPAppSession sharedSession].token] parameters:parameters];
    }
}

#pragma mark - API calls

- (void)fetchWorkoutTypesWithSuccessBlock:(NPCollectionSuccessBlock)block
{
    [[NPAnalytics sharedAnalytics] track:@"workout types request attempted"];

    [self getPath:@"workout_types" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSArray *types = [responseObject objectForKey:@"data"];
        block(types);

        [[NPAnalytics sharedAnalytics] track:@"workout types request succeeded"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [NPUtils reportError:error WithMessage:@"workout types request failed" FromOperation:(AFJSONRequestOperation *)operation];
    }];
}

- (void)fetchWorkoutsForLocation:(NSString *)location withSuccessBlock:(NPCollectionSuccessBlock)block
{
    [[NPAnalytics sharedAnalytics] track:@"workouts request attempted"];
    [self getPath:@"workouts" parameters:@{@"location": location} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *data = [responseObject valueForKey:@"data"];
        NSMutableArray *workouts = [[NSMutableArray alloc] initWithCapacity:data.count];

        for (id object in data) {
            [workouts addObject:[NPWorkout workoutWithObject:object]];
        }

        [[NPAnalytics sharedAnalytics] track:@"workouts request succeeded"];
        block([NSArray arrayWithArray:workouts]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSString *msg = [NPUtils reportError:error WithMessage:@"workouts request failed" FromOperation:(AFJSONRequestOperation *)operation];
//        [[[UIAlertView alloc] initWithTitle:@"Error Occured" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)fetchUserForFacebookAccessToken:(NSString *)accessToken withSuccessBlock:(NPAuthenticationSuccessBlock)block failureBlock:(NPAuthenticationFailBlock)failure
{
    [[NPAnalytics sharedAnalytics] track:@"login attempted facebook"];
    [self postPath:@"users/facebook" parameters:@{@"access_token": accessToken}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NPUser *user = [NPUser userWithObject:[responseObject objectForKey:@"data"]];

             NSString *token = [[responseObject objectForKey:@"data"] valueForKey:@"token"];

             [[NPAnalytics sharedAnalytics] track:@"login succeeded facebook"];
             block(user, token);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             NSString *msg = [NPUtils reportError:error WithMessage:@"login failed facebook" FromOperation:(AFJSONRequestOperation *)operation];
//
//             [[[UIAlertView alloc] initWithTitle:@"Error Occured" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
             failure(error);
         }];
}

- (void)authenticateUserWithParameters:(NSDictionary *)parameters withSuccessBlock:(NPAuthenticationSuccessBlock)success failureBlock:(NPAuthenticationFailBlock)failure
{
    [[NPAnalytics sharedAnalytics] track:@"login attempted"];
    [[NPAPIClient sharedClient] postPath:@"users/login" parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NPUser *user = [NPUser userWithObject:[responseObject valueForKey:@"data"]];
             NSString *token = [[responseObject objectForKey:@"data"] valueForKey:@"token"];
             [[NPAnalytics sharedAnalytics] track:@"login succeeded"];
             success(user, token);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             NSString *msg = [NPUtils reportError:error WithMessage:@"login failed" FromOperation:(AFJSONRequestOperation *)operation];
//             [SVProgressHUD dismiss];
//
//             [[[UIAlertView alloc] initWithTitle:@"Error Occured" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
             failure(error);
         }];
}

- (void)createUserWithParameters:(NSDictionary *)parameters withSuccessBlock:(NPAuthenticationSuccessBlock)success failureBlock:(NPAuthenticationFailBlock)failure
{
    [[NPAnalytics sharedAnalytics] track:@"signup attempted"];
    [[NPAPIClient sharedClient] postPath:@"users" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NPUser *user = [NPUser userWithObject:[responseObject valueForKey:@"data"]];
         NSString *token = [[responseObject objectForKey:@"data"] valueForKey:@"token"];
         [[NPAnalytics sharedAnalytics] track:@"signup succeeded"];
         success(user, token);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//         NSString *msg = [NPUtils reportError:error WithMessage:@"signup failed" FromOperation:(AFJSONRequestOperation *)operation];
//         [SVProgressHUD dismiss];
//         
//         [[[UIAlertView alloc] initWithTitle:@"Error Occured" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         failure(error);
     }];
}

@end
