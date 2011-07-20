#import "CcMediaDataSourceBase.h"

#import "CcMediaPickerPlugin.h"


@interface CcFlickrPhotoDataSource : CcMediaDataSourceBase <CcMediaPickerPlugin,
                                                            NSXMLParserDelegate> {
@private
  BOOL creativeCommonsOnly;
  NSMutableArray *httpRequests;
  NSMutableDictionary *images;
  NSMutableArray *items;
  NSString *lastError;
  NSXMLParser *parser;
  BOOL parsingCompletedSuccessfully;
  NSString *query;
  NSMutableDictionary *sourceInfo;
}

@end
