//
//  NPAuthenticator.h
//  NovProject
//
//  Created by Tony DiPasquale on 8/30/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

@interface NPAuthenticator : NSObject

+ (void)createUserWithDictionary:(NSDictionary *)parameters;
+ (void)authenticateUserWithEmail:(NSString *)email andPassword:(NSString *)password;
+ (void)authenticateUserWithFacebookAccessToken:(NSString *)accessToken;

@end
