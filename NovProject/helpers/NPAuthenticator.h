//
//  NPAuthenticator.h
//  NovProject
//
//  Created by Tony DiPasquale on 8/30/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

@interface NPAuthenticator : NSObject

+ (void)createUserWithName:(NSString *)name email:(NSString *)email password:(NSString *)password location:(NSString *)location gender:(NSString *)gender;
+ (void)authenticateUserWithEmail:(NSString *)email andPassword:(NSString *)password;
+ (void)authenticateUserWithFacebookAccessToken:(NSString *)accessToken;

@end
