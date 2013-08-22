#import "NPDateFormatter.h"

SpecBegin(NPDateFormatter)

describe(@"NPDateFormatter", ^{
    __block NSString *dateString;
    __block NSDate *now;
    
    beforeAll(^{
        dateString = @"2013-07-12T14:55:16Z";
        now = [NSDate dateWithTimeIntervalSince1970:0];
    });
    
    it(@"should format an NSDate to a string", ^{
        NSString *returnedDateString = [[NPDateFormatter sharedFormatter].displayFormatter stringFromDate:now];
        // this isn't going to work on any time zone except EST ... also might break during day light savings
        expect(returnedDateString).to.equal(@"Wed - Dec 31, 1969 - 7:00PM");
    });
    
    it(@"should create an NSDate object from a string", ^{
        NSDate *date = [[NPDateFormatter sharedFormatter].serverFormatter dateFromString:[dateString substringToIndex:16]];
        
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setYear:2013];
        [comps setMonth:7];
        [comps setDay:12];
        [comps setHour:14];
        [comps setMinute:55];
        [comps setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        expect(date).to.equal([[NSCalendar currentCalendar] dateFromComponents:comps]);
    });
});

SpecEnd
