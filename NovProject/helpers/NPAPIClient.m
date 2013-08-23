//
//  NPAPIClient.m
//  NPBoston
//
//  Created by Tony DiPasquale on 4/28/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPAPIClient.h"
#import "LUKeychainAccess.h"
#import "NPUtils.h"
#import "NPWorkout.h"
#import "NPAnalytics.h"

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

    NSString *token = [[LUKeychainAccess standardKeychainAccess] stringForKey:@"token"];
    if (token) {
        self.token = token;
    }

    return self;
}

#pragma mark - Overridden methods

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    if (!self.token) {
        return [super requestWithMethod:method path:path parameters:parameters];
    } else {
        return [super requestWithMethod:method path:[path stringByAppendingFormat:@"?token=%@", self.token] parameters:parameters];
    }
}

#pragma mark - Property assignment

- (void)setToken:(NSString *)token {
    _token = token;
    [[LUKeychainAccess standardKeychainAccess] setString:token forKey:@"token"];
}

- (void)fetchWorkoutTypesWithSuccessBlock:(void (^)(NSArray *))block
{
    [[NPAnalytics sharedAnalytics] trackEvent:@"workout types request attempted"];

    [self getPath:@"workout_types" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSArray *types = [responseObject objectForKey:@"data"];
        block(types);

        [[NPAnalytics sharedAnalytics] trackEvent:@"workout types request succeeded"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [NPUtils reportError:error WithMessage:@"workout types request failed" FromOperation:(AFJSONRequestOperation *)operation];
    }];
}

- (void)fetchWorkoutsForLocation:(NSString *)location withSuccessBlock:(void (^)(NSArray *))block
{
    [[NPAnalytics sharedAnalytics] trackEvent:@"workouts request attempted"];
    [self getPath:@"workouts" parameters:@{@"location": location} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *data = [responseObject valueForKey:@"data"];
        NSMutableArray *workouts = [[NSMutableArray alloc] initWithCapacity:data.count];

        for (id object in data) {
            [workouts addObject:[NPWorkout workoutWithObject:object]];
        }

        [[NPAnalytics sharedAnalytics] trackEvent:@"workouts request succeeded"];
        block([NSArray arrayWithArray:workouts]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSString *msg = [NPUtils reportError:error WithMessage:@"workouts request failed" FromOperation:(AFJSONRequestOperation *)operation];
//        [[[UIAlertView alloc] initWithTitle:@"Error Occured" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

@end
