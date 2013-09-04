#import "NPResult+Fixture.h"

SPEC_BEGIN(NPResultSpec)

describe(@"NPResult model", ^{
    __block NSDictionary *resultJSON;
    
    beforeAll(^{
        resultJSON = [NPResult jsonFixture];
    });
    
    it(@"should create result model from JSON data", ^{
        NPResult *result = [NPResult resultWithObject:resultJSON];
        [[result.objectId should] equal:[resultJSON valueForKey:@"_id"]];
    });
});

SPEC_END
