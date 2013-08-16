#import "NPVerbal+Fixture.h"

SpecBegin(NPVerbal)

describe(@"NPVerbal model", ^{
    __block NSDictionary *verbalJSON;
    
    beforeAll(^{
        verbalJSON = [NPVerbal jsonFixture];
    });
    
    it(@"should create Verbal model from JSON data", ^{
        NPVerbal *verbal = [NPVerbal verbalWithObject:verbalJSON];
        expect(verbal.objectId).to.equal([verbalJSON valueForKey:@"_id"]);
    });
});

SpecEnd
