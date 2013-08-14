#import "NPResult+Fixture.h"

SpecBegin(NPResult)

describe(@"NPResult model", ^{
    __block NSDictionary *simpleResultJSON;
    __block NSDictionary *fullResultJSON;
    
    beforeAll(^{
        simpleResultJSON = [NPResult simpleJSONFixture];
        fullResultJSON = [NPResult fullJSONFixture];
    });
    
    it(@"should create result model from simple JSON data", ^{
        NPResult *result = [NPResult resultWithObject:simpleResultJSON];
        expect(result.objectId).to.equal([simpleResultJSON valueForKey:@"_id"]);
    });
    
    it(@"should create result model from full JSON data", ^{
        NPResult *result = [NPResult resultWithObject:fullResultJSON];
        expect(result.objectId).to.equal([fullResultJSON valueForKey:@"_id"]);
    });
});

SpecEnd
