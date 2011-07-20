#ifdef USE_DEV_SETTINGS
  //#define DEBUG_HTTP_REQUESTS
  #define DEBUG_SQL_ERRORS
  //#define DEBUG_SQL_INSERT_STATEMENTS
  //#define DEBUG_SQL_SELECT_STATEMENTS
  //#define DEBUG_SQL_UPDATE_STATEMENTS
  //#define DEBUG_SLOW_DOWN_NETWORK_REQUESTS

  //#define DISABLE_LOCAL_CACHE

  // Beta ------------------------------------------------------------------------------------------
  #ifdef SERVER_BETA
    #define kSecureServerRootUrl @"https://beta.cliqcliq.com"
    #define kServerRootUrl @"http://beta.cliqcliq.com"
    #define kImagesServerRootUrl @"http://images.dev.cliqcliq.com.s3.amazonaws.com"
  #endif
  // Alpha -----------------------------------------------------------------------------------------
  #ifdef SERVER_ALPHA
    #define kSecureServerRootUrl @"https://alpha.cliqcliq.com"
    #define kServerRootUrl @"http://alpha.cliqcliq.com"
    #define kImagesServerRootUrl @"http://images.dev.cliqcliq.com.s3.amazonaws.com"
  #endif
  // Local -----------------------------------------------------------------------------------------
  #ifdef SERVER_LOCAL
    #define kSecureServerRootUrl @"http://localhost:8000"
    #define kServerRootUrl @"http://localhost:8000"
    #define kImagesServerRootUrl @"http://images.dev.cliqcliq.com.s3.amazonaws.com"
  #endif
#else
  // For a distribution build, always uses these settings!

  #define kSecureServerRootUrl @"https://iphone-apis-1.cliqcliq.com"
  #define kServerRootUrl @"http://iphone-apis-1.cliqcliq.com"
  #define kImagesServerRootUrl @"http://images.cliqcliq.com.s3.amazonaws.com"
#endif

#define FLICKR_API_KEY @"a6938fb5b892c17b5f30a1a3bb780b1e"

#define kIphoneKey @"1tZ1mYKBS3Ds3pA94JpMj8imA26EkCps"
#define kIphoneSecretKey @"mMzMfrK8E0SJ21nXIIgeeSfpuRJdxbq4"
