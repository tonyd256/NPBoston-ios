#import "NPUser+Fixture.h"

SPEC_BEGIN(NPUserSpec)

describe(@"NPUser model", ^{
    __block NSDictionary *userJSON;
    
    beforeAll(^{
        userJSON = [NPUser jsonFixture];
    });
    
    it(@"should create user model from JSON", ^{
        NPUser *user = [NPUser userWithObject:userJSON];
        [[user.objectId should] equal:[userJSON valueForKey:@"_id"]];
    });
});

SPEC_END
