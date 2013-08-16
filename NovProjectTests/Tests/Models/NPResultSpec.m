#import "NPResult+Fixture.h"

SpecBegin(NPResult)

describe(@"NPResult model", ^{
    __block NSDictionary *resultJSON;
    
    beforeAll(^{
        resultJSON = [NPResult jsonFixture];
    });
    
    it(@"should create result model from JSON data", ^{
        NPResult *result = [NPResult resultWithObject:resultJSON];
        expect(result.objectId).to.equal([resultJSON valueForKey:@"_id"]);
    });
});

SpecEnd
