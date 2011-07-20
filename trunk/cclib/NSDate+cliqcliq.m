#import "NSDate+cliqcliq.h"

#import "CcConstants.h"


@implementation NSDate (cliqcliq)


+ (NSString *)timeSinceTimestamp:(NSString *)timestampUtc {
  int year, month, day, hour, min, sec;
  sscanf([timestampUtc cStringUsingEncoding:NSUTF8StringEncoding],
         "%04d-%02d-%02d %02d:%02d:%02d",
         &year, &month, &day, &hour, &min, &sec);

  NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
  [components setYear:year];
  [components setMonth:month];
  [components setDay:day];
  [components setHour:hour];
  [components setMinute:min];
  [components setSecond:sec];
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  [gregorian setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
  NSDate *date = [gregorian dateFromComponents:components];

  NSTimeInterval secsSince = -[date timeIntervalSinceNow];

  if (secsSince < kTimeOneMinuteInSeconds) {
    return @"Less than a minute ago";
  } else if (secsSince < kTimeOneHourInSeconds) {
    int numMins = (int) (secsSince / kTimeOneMinuteInSeconds);
    NSString *format = numMins == 1 ? @"%d minute ago" : @"%d minutes ago";
    return [NSString stringWithFormat:format, numMins];
  } else if (secsSince < kTimeOneDayInSeconds) {
    int numHours = (int) (secsSince / kTimeOneHourInSeconds);
    NSString *format = numHours == 1 ? @"%d hour ago" : @"%d hours ago";
    return [NSString stringWithFormat:format, numHours];
  } else if (secsSince < kTimeThirtyDaysInSeconds) {
    int numDays = (int) (secsSince / kTimeOneDayInSeconds);
    NSString *format = numDays == 1 ? @"%d day ago" : @"%d days ago";
    return [NSString stringWithFormat:format, numDays];
  } else if (secsSince < kTimeSevenDaysInSeconds) {
    int numWeeks = (int) (secsSince / kTimeSevenDaysInSeconds);
    NSString *format = numWeeks == 1 ? @"%d week ago" : @"%d weeks ago";
    return [NSString stringWithFormat:format, numWeeks];
  } else {
    int numMonths = (int) (secsSince / kTimeThirtyDaysInSeconds);
    NSString *format = numMonths == 1 ? @"%d month ago" : @"%d months ago";
    return [NSString stringWithFormat:format, numMonths];
  }
}


@end
