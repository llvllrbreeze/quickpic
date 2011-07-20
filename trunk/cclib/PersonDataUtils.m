#import "PersonDataUtils.h"

#import "NSDictionary+cliqcliq.h"


#define ObjOrNull(val) (val ? val : [NSNull null])


@implementation PersonDataUtils


+ (NSString *)displayAddress:(NSDictionary *)addressData {
  NSString *street = [addressData valueForKey:@"Street" defaultValue:nil];
  NSString *city = [addressData valueForKey:@"City" defaultValue:nil];
  NSString *state = [addressData valueForKey:@"State" defaultValue:nil];
  NSString *zip = [addressData valueForKey:@"ZIP" defaultValue:nil];
  NSString *country = [addressData valueForKey:@"Country" defaultValue:nil];
  
  NSMutableArray *addressLines = [NSMutableArray arrayWithCapacity:3];
  if (street) {
    [addressLines addObject:street];
  }
  
  if (city || state || zip) {
    NSString *cityState = city;
    if (city && state) {
      cityState = [NSString stringWithFormat:@"%@, %@", city, state];
    } else if (state) {
      cityState = state;
    }

    NSString *line = cityState;
    if (cityState && zip) {
      line = [NSString stringWithFormat:@"%@ %@", cityState, zip];
    } else if (zip) {
      line = zip;
    }
    
    if (line) {
      [addressLines addObject:line];
    }
  }
  
  if (country) {
    [addressLines addObject:country];
  }

  return [addressLines componentsJoinedByString:@"\n"];
}


+ (NSString *)displayCompanyInfo:(NSDictionary *)personData {
  NSDictionary *occupationData = [personData valueForKey:@"occupation"];
  NSString *organization = [occupationData valueForKey:@"organization" defaultValue:nil];
  NSString *jobTitle = [occupationData valueForKey:@"title" defaultValue:nil];

  if (jobTitle && organization) {
    return [NSString stringWithFormat:@"%@\n%@", jobTitle, organization];
  } else if (jobTitle) {
    return jobTitle;
  } else if (organization) {
    return organization;
  } else {
    return @"";
  }
}


+ (NSString *)displayName:(NSDictionary *)personData {
  NSDictionary *nameData = [personData valueForKey:@"name"];

  NSMutableArray *nameParts = [NSMutableArray array];
  NSString *namePart;
  if (namePart = [nameData valueForKey:@"prefix" defaultValue:nil]) {
    [nameParts addObject:namePart];
  }
  if (namePart = [nameData valueForKey:@"first" defaultValue:nil]) {
    [nameParts addObject:namePart];
  }
  if (namePart = [nameData valueForKey:@"middle" defaultValue:nil]) {
    [nameParts addObject:namePart];
  }
  if (namePart = [nameData valueForKey:@"last" defaultValue:nil]) {
    [nameParts addObject:namePart];
  }
  if (namePart = [nameData valueForKey:@"suffix" defaultValue:nil]) {
    [nameParts addObject:namePart];
  }

  return [nameParts componentsJoinedByString:@" "];
}


// TODO(westphal): There is probably a memory-leak here with ABRecordCopyValue.  Look into this.
+ (NSDictionary *)personDataFromAddressBookPersonRecord:(ABRecordRef)person {
  NSMutableDictionary *personData = [NSMutableDictionary dictionary];
  
  [personData setValue:[NSNumber numberWithInt:ABRecordGetRecordID(person)] forKey:@"id"];
  
  id firstName = ObjOrNull((id) ABRecordCopyValue(person, kABPersonFirstNameProperty));
  id middleName = ObjOrNull((id) ABRecordCopyValue(person, kABPersonMiddleNameProperty));
  id lastName = ObjOrNull((id) ABRecordCopyValue(person, kABPersonLastNameProperty));
  id nickname = ObjOrNull((id) ABRecordCopyValue(person, kABPersonNicknameProperty));
  id prefix = ObjOrNull((id) ABRecordCopyValue(person, kABPersonPrefixProperty));
  id suffix = ObjOrNull((id) ABRecordCopyValue(person, kABPersonSuffixProperty));

  [personData setValue:[NSDictionary dictionaryWithObjectsAndKeys:
                            firstName, @"first",
                            middleName, @"middle",
                            lastName, @"last",
                            nickname, @"nickname",
                            prefix, @"prefix",
                            suffix, @"suffix",
                            nil]
              forKey:@"name"];

  id organization = ObjOrNull((id) ABRecordCopyValue(person, kABPersonOrganizationProperty));
  id jobTitle = ObjOrNull((id) ABRecordCopyValue(person, kABPersonJobTitleProperty));
  id department = ObjOrNull((id) ABRecordCopyValue(person, kABPersonDepartmentProperty));

  [personData setValue:[NSDictionary dictionaryWithObjectsAndKeys:
                            organization, @"organization",
                            jobTitle, @"title",
                            department, @"department",
                            nil]
              forKey:@"occupation"];  

  ABMultiValueRef emailsData = ABRecordCopyValue(person, kABPersonEmailProperty);
  int numEmails = ABMultiValueGetCount(emailsData);
  NSMutableArray *emails = [NSMutableArray arrayWithCapacity:numEmails];
  for (int emailsIndex = 0; emailsIndex < numEmails; emailsIndex++) {
    id email = ObjOrNull((id) ABMultiValueCopyValueAtIndex(emailsData, emailsIndex));
    id emailType = ObjOrNull((id) ABAddressBookCopyLocalizedLabel(
        ABMultiValueCopyLabelAtIndex(emailsData, emailsIndex)));
    [emails addObject:[NSArray arrayWithObjects:email, emailType, nil]];
  }
  [personData setValue:emails forKey:@"email_addresses"];

  ABMultiValueRef addressData = ABRecordCopyValue(person, kABPersonAddressProperty);
  int numAddresses = ABMultiValueGetCount(addressData);
  NSMutableArray *addresses = [NSMutableArray arrayWithCapacity:numAddresses];
  for (int addressesIndex = 0; addressesIndex < numAddresses; addressesIndex++) {
    id address = ObjOrNull((id) ABMultiValueCopyValueAtIndex(addressData, addressesIndex));
    id addressType = ObjOrNull((id) ABAddressBookCopyLocalizedLabel(
        ABMultiValueCopyLabelAtIndex(addressData, addressesIndex)));
    [addresses addObject:[NSArray arrayWithObjects:address, addressType, nil]];
  }
  [personData setValue:addresses forKey:@"addresses"];

  ABMultiValueRef phonesData = ABRecordCopyValue(person, kABPersonPhoneProperty);
  int numPhones = ABMultiValueGetCount(phonesData);
  NSMutableArray *phones = [NSMutableArray arrayWithCapacity:numPhones];
  for (int phonesIndex = 0; phonesIndex < numPhones; phonesIndex++) {
    id phone = ObjOrNull((id) ABMultiValueCopyValueAtIndex(phonesData, phonesIndex));
    id phoneType = ObjOrNull((id) ABAddressBookCopyLocalizedLabel(
        ABMultiValueCopyLabelAtIndex(phonesData, phonesIndex)));
    [phones addObject:[NSArray arrayWithObjects:phone, phoneType, nil]];
  }
  [personData setValue:phones forKey:@"phone_numbers"];

  if (ABPersonHasImageData(person)) {
    UIImage *image = [UIImage imageWithData:(NSData *)ABPersonCopyImageData(person)];
    [personData setValue:image forKey:@"image"];
  }

  return personData;
}


@end
