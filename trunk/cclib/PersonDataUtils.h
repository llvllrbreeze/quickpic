#import <AddressBookUI/AddressBookUI.h>
#import <Foundation/Foundation.h>


@interface PersonDataUtils : NSObject {

}

+ (NSString *)displayAddress:(NSDictionary *)addressData;
+ (NSString *)displayCompanyInfo:(NSDictionary *)personData;
+ (NSString *)displayName:(NSDictionary *)personData;
+ (NSDictionary *)personDataFromAddressBookPersonRecord:(ABRecordRef)person;

@end
