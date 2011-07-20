#import "NSArray+cliqcliq.h"


@implementation NSArray (cliqcliq)


- (NSMutableArray *)shuffle {
  return [self shuffle:[self count]];
}


- (NSMutableArray *)shuffle:(int)maxValues {
  int count = [self count];
  maxValues = MIN(count, maxValues);

  NSMutableArray *output = [NSMutableArray arrayWithCapacity:maxValues];
  
  BOOL used[count];
  memset(used, 0, sizeof(BOOL) * maxValues);
  
  int numUsed = 0;
  while (numUsed < maxValues) {
    int randomIndex;
    do {
      randomIndex = random() % count;
    } while (used[randomIndex]);
    
    [output addObject:[self objectAtIndex:randomIndex]];
    used[randomIndex] = YES;
    numUsed++;
  }

  return output;
}


@end
