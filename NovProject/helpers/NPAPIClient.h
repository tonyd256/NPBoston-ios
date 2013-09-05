//
//  NPAPIClient.h
//  NovProject
//
//  Created by Tony DiPasquale on 4/28/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

@class NPUser;

typedef void (^NPCollectionSuccessBlock)(NSArray *);
typedef void (^NPAuthenticationSuccessBlock)(NPUser *, NSString *);
typedef void (^NPAuthenticationFailBlock)(NSError *);

@interface NPAPIClient : AFHTTPClient

+ (NPAPIClient *)sharedClient;

- (void)fetchWorkoutTypesWithSuccessBlock:(NPCollectionSuccessBlock)block;
- (void)fetchWorkoutsForLocation:(NSString *)location withSuccessBlock:(NPCollectionSuccessBlock)block;
- (void)fetchUserForFacebookAccessToken:(NSString *)accessToken withSuccessBlock:(NPAuthenticationSuccessBlock)success failureBlock:(NPAuthenticationFailBlock)failure;
- (void)authenticateUserWithParameters:(NSDictionary *)parameters withSuccessBlock:(NPAuthenticationSuccessBlock)success failureBlock:(NPAuthenticationFailBlock)failure;
- (void)createUserWithParameters:(NSDictionary *)parameters withSuccessBlock:(NPAuthenticationSuccessBlock)success failureBlock:(NPAuthenticationFailBlock)failure;

@end
