//
//  NPErrorHandlerSpec.m
//  NovProject
//
//  Created by Tony DiPasquale on 9/6/13.
//  Copyright 2013 Tony DiPasquale. All rights reserved.
//

#import "NPErrorHandler.h"
#import "NPAnalytics.h"
#import "AFJSONRequestOperation.h"

SPEC_BEGIN(NPErrorHandlerSpec)

describe(@"NPErrorHandler", ^{
    __block NSError *error;
    __block id operationMock;
    __block NSDictionary *serverErrorJSON;

    beforeAll(^{
        error = [NSError errorWithDomain:NSPOSIXErrorDomain code:100 userInfo:@{NSLocalizedDescriptionKey: @"This is a test!"}];
        operationMock = [AFJSONRequestOperation mock];
        serverErrorJSON = @{@"error": @"This is a test error from the server"};
    });

    beforeEach(^{
        [operationMock stub:@selector(responseJSON) andReturn:serverErrorJSON];
    });

    it(@"should track the error in analytics", ^{
        [[[NPAnalytics should] receive] trackError:@"test" message:error.localizedDescription];
        [NPErrorHandler reportError:error withAnalyticsEvent:@"test" quiet:YES];
    });

    it(@"should use the server error message over the NSError message", ^{
        [[[NPAnalytics should] receive] trackError:@"test" message:serverErrorJSON[@"error"]];
        [NPErrorHandler reportError:error withAnalyticsEvent:@"test" fromOperation:operationMock quiet:YES];
    });
});

SPEC_END
