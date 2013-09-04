#import "NPDateFormatter.h"
#import "NSDate+Fixture.h"

SPEC_BEGIN(NPDateFormatterSpec)

describe(@"NPDateFormatter", ^{

    it(@"should format an NSDate to a string", ^{
        NSString *returnedDateString = [[NPDateFormatter sharedFormatter].displayFormatter stringFromDate:[NSDate dateFixture]];
        // this isn't going to work on any time zone except EST ... also might break during day light savings
        [[returnedDateString should] equal:@"Fri - Jul 12, 2013 - 10:55AM"];
    });

    it(@"should create an NSDate object from a string", ^{
        NSDate *date = [[NPDateFormatter sharedFormatter].serverFormatter dateFromString:[[NSDate dateStringFixture] substringToIndex:16]];
        [[date should] equal:[NSDate dateFixture]];
    });
});

SPEC_END
