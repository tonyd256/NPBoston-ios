//
//  NPAPIClient.m
//  NPBoston
//
//  Created by Tony DiPasquale on 4/28/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPAPIClient.h"

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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"token"]) {
        self.token = [defaults objectForKey:@"token"];
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"token"];
    [defaults synchronize];
}

@end
