# Introduction #

Quickpic is available for iPhone and iPod Touch! Quickpic has two main functions: 1.) letting you quickly email photos from your camera, photo library, and Flickr and 2.) providing support for websites that ask you to upload images and movies.

If you're interested in the technical details of integrating Quickpic with your iPhone web app, jump down to the Web App Integration section below.

The following details are intended to serve as a basic user's manual and FAQ. If you don't find what you're looking for, shoot us an email. It usually just takes us a couple hours to respond.

# Advanced Notes #

If you're writing a full-screen iPhone web application, accessing custom URL schemes via Javascript is not currently supported in full-screen mode for web applications on the iPhone (reason unknown). You can still use a static URL to access such URLs however. This is less than ideal. However, if you implement a cookie-based solution (or something similar) where you ask the user to install Quickpic or confirm installation, then, once they have confirmed, you can simply provide a link such as <a href='vquickpic://?...'>Launch Quickpic</a>, rather than using the usual example code.

# Python/Django Example Code #

The following Python/Django example is more advanced than the PHP example and uses some custom functions and classes that you should consider to be black boxes. The functionality of these can likely be guessed at, but for clarity sake, the most import custom class is EncodableResponse, which converts data into plist, json, and other formats. In the case of success, this returns the standard PLIST response, as described in the section "Handling Uploads", below.

```
def upload_quickpic(request):
  from cjson import decode
  from cliqcliq_com.speed_dial_www.util import process_image
  from cliqcliq_com.util.http import EncodableResponse, HttpResponseException, unquote_unicode_url
  from cliqcliq_com.util.request import get_param
  from django.http import HttpResponseRedirect

  try:
    context = __get_context_parts(get_param(request, 'context', required=True))
  except HttpResponseException, e:
    return EncodableResponse({'success': False, 'errormsg': 'Missing context'})

  try:
    process_image(context['guid'], request.FILES['upload_file'])
  except Exception, e:
    return EncodableResponse({'success': False, 'errormsg': 'Unable to store image'})

  contacts = get_param(request, 'contacts')
  if contacts:
    contact = decode(contacts)[0]
    context['name'] = __contact_display_name(contact)
    context['tel'] = NON_DIGITS_RE.sub('', contact['selected-field-value'])

  name = unquote_unicode_url(context['name'])
  __create_or_update_icon_reference_value(guid=context['guid'], name=name, tel=context['tel'])

  return EncodableResponse({'success': True})
```

# PHP Example Code #

The following is sample code for handling the upload of a single image file via Quickpic. It is a very basic example that takes the uploaded file and stores it in an "uploads" directory. Because Quickpic always uploads images using names like "quickpic.jpg", this isn't good practice in general, but coming up with another namespace is outside the scope of this example.

```
<?php
    header('Content-Type: application/x-plist');
    $file = $_FILES['upload_file'];
    move_uploaded_file($file['tmp_name'], 'uploads/' . $file['name']);
?>

<?php
    echo '<?xml version="1.0" encoding="UTF-8"?>';
?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>success</key>
<true/>
</dict>
</plist>
```

# The User Interface #

(Updated for 1.3)

Clicking on Quickpic from the iPhone/iPod Touch home screen launches a very simple application with just a few main buttons. These buttons let you access your camera, photo library, or Flickr. There are also buttons for adjusting application settings and composing the email, when you're done selecting photos. Working with the camera and photo library is essentially the same experience you would have with any other application. However, the addition of Flickr support makes things more interesting. When you launch Quickpic by clicking on a link in Safari, you may see a "cancel" button in the top left (takes you back to Safari) and a "done" button in the top right (uploads your selections).

Flickr has an amazing collection of incredibly interesting photos taken by thousands of photographers. Quickpic provides an easy way to browse through the publicly available photos on Flickr, including searching for specific themes.

Try clicking on the Flickr button. Within a few seconds, an array of photos should appear. These are the Flickr photos sorted by "interestingness" (a common Flickr term). You can page through up to 160 photos using the arrows at the bottom. If you need to find something else, use the search box towards the top of the screen. You can enter something like "San Francisco Trolleys", for example.

Once you've selected a few photos or videos, press the compose button in the top right. Quickpic presents you with a screen to email your selections.

As of Quickpic 1.3, the Settings screen now includes a "developer mode" option, which provides additional feedback to developers. In particular, if the proper plist response isn't received, an alert is displayed. In addition, the iPhone Configuration Utility or Xcode can be used to view the actual response in the console log.

# Web App Integration #

(Updated for 1.3)

The iPhone and iPod Touch currently don't support file uploads or access to the address book API from Mobile Safari. Still, there are a number of situations where these things could be useful. Quickpic provides a convenient solution for web applications that need this type of support, for uploading photos and video and/or choosing contacts. Even though most users won't have Quickpic already installed, it's simple to check and allow them to install the application.

Integration into your web application is as simple as adding a link and a small bit of JavaScript. Here's an example:

```
<script type="text/javascript">
  window.launchQuickpic = function() {
    var start = new Date();
    setTimeout(function() {
      if (new Date() - start > 2000) {
        return;
      }
      window.location = 'http://code.google.com/p/quickpic/wiki/Install';
    }, 1000);

    var getParams = ['action=http://www.yourcompany.com/upload/',
                     'continue=http://www.yourcompany.com/finished/',
                     'contact=0,1:email',
                     'images=1+',
                     'video=1+',
                     'context=ABCDEF0123456789',
                     'passcontext=1',
                     'maxsize=422',
                     'edit=1',
                     'v=1.2'];
    window.location = 'vquickpic://?' + getParams.join('&');
  };
</script>
<a href="javascript:launchQuickpic();">
    <img src="http://code.google.com/p/quickpic/logo?cct=1311146035" /></a>
```

When the user has the Quickpic native iPhone application installed, opening a URL that starts with "vquickpic://" launches the application (from 1.2 onward, the preferred protocol is "vquickpic" rather than "quickpic", because we added version checking support). You pass parameters to the application just as you would a normal http URL. In the example above, the "action" parameter specifies where to upload the selected image and contact information. "continue" specifies which URL to go to once the upload is complete (or if the user cancels). Following is a reference for supported parameters:

  * action - (required) the URL to which data is to be uploaded (see Handling Uploads below).
  * continue - (required) the URL to redirect to upon completion: either when image or movie has finished uploading, or when the user cancels the operation. The GET parameter "success=1" is passed if the user completed the upload, and "success=0" is passed otherwise.
  * contact - indicates whether or not the user should be prompted for contact information. There are several possibly values: "0" (do not prompt), "1" (require 1 contact), "0,1" (optionally allow the user to select a contact), "n+" (select at least n contacts) -- "0" by default. In addition, values "0,1" and "1" can optionally be suffixed with ":phone" or ":email" (e.g. "contact=0,1:phone") to indicate that a particular value should be selected. "contact=0,1:phone" means: allow the user to optionally select the phone number of a contact. In this case, all of the other contact information is returned along with the contact, but a special return parameter "selected-field-value" is added with the value of the selected phone number, in this case.
  * context - a value to pass to the action URL, generally to help maintain some form of session or context. The default value is empty.
  * cconly - whether or not only Creative Commons Flickr photos should be returned (photo library and camera options are included regardless). Choices are "0" (off) and "1" (on) -- off by default.
  * edit - user is given the opportunity to edit images and movies before posting. Choices are "0" (off) and "1" (on) -- off by default.
  * flickr - flickr menu option availability. Choices are "0" (off) and "1" (on) -- on by default.
  * images - the user can choose image files. Choices are "0" (off) and "1" (on) -- on by default. In 1.2, more choices have been added for this field: "0,1" and "n+", both of which behave similarly to their use with contacts. Note: that if both "images" and "video" have non-zero values, they should have the same values. The behavior otherwise is not well-defined.
  * maxsize - the maximum size image to upload. Images are automatically scaled, according to their aspect ratios, if they are larger. If a single number is specified, neither dimension can exceed the given value. If a comma-separated (width,height) value is specified, the image cannot be larger than the specified width or height.
  * passcontext - a value of "1" tells Quickpic to pass the context to the continue URL when it's opened -- "0" by default.
  * source - the default source to choose. Choices are "camera", "library", and "flickr". If this option is specified, the other options will still be available, they just won't appear by default. If the specified default source is unavailable (such as "camera" on an iPod Touch), this parameter will be ignored.
  * v - the required minimum version number of Quickpic. The user will see a popup warning and be taken to the app download page if they don't have the required version.
  * video - the user can choose movie files. Choices are "0" (off) and "1" (on) -- off by default.

## Handling Uploads ##

Uploads are sent using standard POST multipart/form-data encoding. The first uploaded file will have form name "upload\_file". Subsequent files will have names like "upload\_file\_2", "upload\_file\_3", and so on. The POST parameter "context" will have the same value as passed via the "context" GET parameter, when launching the native application. Three other POST parameters are also returned, but have non-empty values only when uploading Flickr content. These are "source\_author", "source\_id", and "source\_type". The "source\_author" parameter is a Flickr username, "source\_id" is the URL to the photo on Flickr, and "source\_type" will be "flickr". Some uses of images may require proper attribution.

If contact data is returned, the POST parameter "contacts" will be set and include a JSON-encoded array. This should be easily dealt with in server environment (see [Introducing JSON](http://www.json.org/) and the section towards the bottom of that page for language-specific tools). The data included in the contacts array is, for a single entry, as follows:

```
{'name': {
   'first': '...',
   'middle': '...',
   'last': '...',
   'prefix': '...',
   'suffix': '...',
   'nickname': '...'},
 'occupation': {
   'organization': '...',
   'title': '...',
   'department': '...'},
 'email_addresses': [
   ['email-address', 'email-address-type (e.g. home)'],
   ...],
 'addresses': [
   {'Street': '...',
    'City': '...',
    'State': '...',
    'ZIP': '...',
    'Country', '...',
    'CountryCode', '2-character-country-code'},
   ...],
 'phone_numbers': [
   ['phone-number', 'phone-number-type (e.g. work)'],
   ...],
 'selected-field-value': '... this field is only present if ":phone" or ":email" are used in the contact param'}
```

For version 1.2, return an HTTP 200 response with the following (content-type="application/x-plist"):

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>success</key>
<true/>
</dict>
</plist>
```