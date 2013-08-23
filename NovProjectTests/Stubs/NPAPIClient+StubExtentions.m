//
//  NPAPIClient+StubExtentions.m
//  NovProject
//
//  Created by Tony DiPasquale on 8/20/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NPAPIClient+StubExtentions.h"
#import "NSString+Extensions.h"

@implementation NPAPIClient (StubExtentions)

+ (void)stubRequestWithPath:(NSString *)path andHTTPMethod:(NSString *)method
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.HTTPMethod isEqualToString:method] && [request.URL.path containsString:path];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFile:[NSString stringWithFormat:@"%@.json", path] contentType:@"text/json" responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];
}

+ (void)removeLastRequestHandler
{
    [OHHTTPStubs removeLastRequestHandler];
}

@end
