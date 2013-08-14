#import "NPVerbal+Fixture.h"

SpecBegin(NPVerbal)

describe(@"NPVerbal model", ^{
    __block NSDictionary *simpleVerbalJSON;
    __block NSDictionary *fullVerbalJSON;
    
    beforeAll(^{
        simpleVerbalJSON = [NPVerbal simpleJSONFixture];
        fullVerbalJSON = [NPVerbal fullJSONFixture];
    });
    
    it(@"should create Verbal model from simple JSON data", ^{
        NPVerbal *verbal = [NPVerbal verbalWithObject:simpleVerbalJSON];
        expect(verbal.objectId).to.equal([simpleVerbalJSON valueForKey:@"_id"]);
    });
    
    it(@"should create Verbal model from full JSON data", ^{
        NPVerbal *verbal = [NPVerbal verbalWithObject:fullVerbalJSON];
        expect(verbal.objectId).to.equal([fullVerbalJSON valueForKey:@"_id"]);
    });
});

SpecEnd
