<p align="center" >
  <img src="https://raw.github.com/WBANetworking/WBANetworking/assets/WBANetworking-logo.png" alt="WBANetworking" title="WBANetworking">
</p>

[![Build Status](https://travis-ci.org/WBANetworking/WBANetworking.svg)](https://travis-ci.org/WBANetworking/WBANetworking)

WBANetworking is a delightful networking library for iOS and Mac OS X. It's built on top of the [Foundation URL Loading System](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html), extending the powerful high-level networking abstractions built into Cocoa. It has a modular architecture with well-designed, feature-rich APIs that are a joy to use.

Perhaps the most important feature of all, however, is the amazing community of developers who use and contribute to WBANetworking every day. WBANetworking powers some of the most popular and critically-acclaimed apps on the iPhone, iPad, and Mac.

Choose WBANetworking for your next project, or migrate over your existing projects—you'll be happy you did!

## How To Get Started

- [Download WBANetworking](https://github.com/WBANetworking/WBANetworking/archive/master.zip) and try out the included Mac and iPhone example apps
- Read the ["Getting Started" guide](https://github.com/WBANetworking/WBANetworking/wiki/Getting-Started-with-WBANetworking), [FAQ](https://github.com/WBANetworking/WBANetworking/wiki/WBANetworking-FAQ), or [other articles on the Wiki](https://github.com/WBANetworking/WBANetworking/wiki)
- Check out the [documentation](http://cocoadocs.org/docsets/WBANetworking/) for a comprehensive look at all of the APIs available in WBANetworking
- Read the [WBANetworking 2.0 Migration Guide](https://github.com/WBANetworking/WBANetworking/wiki/WBANetworking-2.0-Migration-Guide) for an overview of the architectural changes from 1.0.

## Communication

- If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/WBANetworking). (Tag 'WBANetworking')
- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/WBANetworking).
- If you **found a bug**, _and can provide steps to reliably reproduce it_, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like WBANetworking in your projects. See the ["Getting Started" guide for more information](https://github.com/WBANetworking/WBANetworking/wiki/Getting-Started-with-WBANetworking).

#### Podfile

```ruby
platform :ios, '7.0'
pod "WBANetworking", "~> 2.0"
```

## Requirements

| WBANetworking Version | Minimum iOS Target  | Minimum OS X Target  |                                   Notes                                   |
|:--------------------:|:---------------------------:|:----------------------------:|:-------------------------------------------------------------------------:|
|          2.x         |            iOS 6            |           OS X 10.8          | Xcode 5 is required. `NSURLSession` subspec requires iOS 7 or OS X 10.9. |
|          [1.x](https://github.com/WBANetworking/WBANetworking/tree/1.x)         |            iOS 5            |         Mac OS X 10.7        |                                                                           |
|        [0.10.x](https://github.com/WBANetworking/WBANetworking/tree/0.10.x)        |            iOS 4            |         Mac OS X 10.6        |                                                                           |

(OS X projects must support [64-bit with modern Cocoa runtime](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtVersionsPlatforms.html)).

> Programming in Swift? Try [Alamofire](https://github.com/Alamofire/Alamofire) for a more conventional set of APIs.

## Architecture

### NSURLConnection

- `WBAURLConnectionOperation`
- `WBAHTTPRequestOperation`
- `WBAHTTPRequestOperationManager`

### NSURLSession _(iOS 7 / Mac OS X 10.9)_

- `WBAURLSessionManager`
- `WBAHTTPSessionManager`

### Serialization

* `<WBAURLRequestSerialization>`
  - `WBAHTTPRequestSerializer`
  - `WBAJSONRequestSerializer`
  - `WBAPropertyListRequestSerializer`
* `<WBAURLResponseSerialization>`
  - `WBAHTTPResponseSerializer`
  - `WBAJSONResponseSerializer`
  - `WBAXMLParserResponseSerializer`
  - `WBAXMLDocumentResponseSerializer` _(Mac OS X)_
  - `WBAPropertyListResponseSerializer`
  - `WBAImageResponseSerializer`
  - `WBACompoundResponseSerializer`

### Additional Functionality

- `WBASecurityPolicy`
- `WBANetworkReachabilityManager`

## Usage

### HTTP Request Operation Manager

`WBAHTTPRequestOperationManager` encapsulates the common patterns of communicating with a web application over HTTP, including request creation, response serialization, network reachability monitoring, and security, as well as request operation management.

#### `GET` Request

```objective-c
WBAHTTPRequestOperationManager *manager = [WBAHTTPRequestOperationManager manager];
[manager GET:@"http://example.com/resources.json" parameters:nil success:^(WBAHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"JSON: %@", responseObject);
} failure:^(WBAHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error: %@", error);
}];
```

#### `POST` URL-Form-Encoded Request

```objective-c
WBAHTTPRequestOperationManager *manager = [WBAHTTPRequestOperationManager manager];
NSDictionary *parameters = @{@"foo": @"bar"};
[manager POST:@"http://example.com/resources.json" parameters:parameters success:^(WBAHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"JSON: %@", responseObject);
} failure:^(WBAHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error: %@", error);
}];
```

#### `POST` Multi-Part Request

```objective-c
WBAHTTPRequestOperationManager *manager = [WBAHTTPRequestOperationManager manager];
NSDictionary *parameters = @{@"foo": @"bar"};
NSURL *filePath = [NSURL fileURLWithPath:@"file://path/to/image.png"];
[manager POST:@"http://example.com/resources.json" parameters:parameters constructingBodyWithBlock:^(id<WBAMultipartFormData> formData) {
    [formData appendPartWithFileURL:filePath name:@"image" error:nil];
} success:^(WBAHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"Success: %@", responseObject);
} failure:^(WBAHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error: %@", error);
}];
```

---

### WBAURLSessionManager

`WBAURLSessionManager` creates and manages an `NSURLSession` object based on a specified `NSURLSessionConfiguration` object, which conforms to `<NSURLSessionTaskDelegate>`, `<NSURLSessionDataDelegate>`, `<NSURLSessionDownloadDelegate>`, and `<NSURLSessionDelegate>`.

#### Creating a Download Task

```objective-c
NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
WBAURLSessionManager *manager = [[WBAURLSessionManager alloc] initWithSessionConfiguration:configuration];

NSURL *URL = [NSURL URLWithString:@"http://example.com/download.zip"];
NSURLRequest *request = [NSURLRequest requestWithURL:URL];

NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
} completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
    NSLog(@"File downloaded to: %@", filePath);
}];
[downloadTask resume];
```

#### Creating an Upload Task

```objective-c
NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
WBAURLSessionManager *manager = [[WBAURLSessionManager alloc] initWithSessionConfiguration:configuration];

NSURL *URL = [NSURL URLWithString:@"http://example.com/upload"];
NSURLRequest *request = [NSURLRequest requestWithURL:URL];

NSURL *filePath = [NSURL fileURLWithPath:@"file://path/to/image.png"];
NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
        NSLog(@"Error: %@", error);
    } else {
        NSLog(@"Success: %@ %@", response, responseObject);
    }
}];
[uploadTask resume];
```

#### Creating an Upload Task for a Multi-Part Request, with Progress

```objective-c
NSMutableURLRequest *request = [[WBAHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://example.com/upload" parameters:nil constructingBodyWithBlock:^(id<WBAMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:@"file://path/to/image.jpg"] name:@"file" fileName:@"filename.jpg" mimeType:@"image/jpeg" error:nil];
    } error:nil];

WBAURLSessionManager *manager = [[WBAURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
NSProgress *progress = nil;

NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
        NSLog(@"Error: %@", error);
    } else {
        NSLog(@"%@ %@", response, responseObject);
    }
}];

[uploadTask resume];
```

#### Creating a Data Task

```objective-c
NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
WBAURLSessionManager *manager = [[WBAURLSessionManager alloc] initWithSessionConfiguration:configuration];

NSURL *URL = [NSURL URLWithString:@"http://example.com/upload"];
NSURLRequest *request = [NSURLRequest requestWithURL:URL];

NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
        NSLog(@"Error: %@", error);
    } else {
        NSLog(@"%@ %@", response, responseObject);
    }
}];
[dataTask resume];
```

---

### Request Serialization

Request serializers create requests from URL strings, encoding parameters as either a query string or HTTP body.

```objective-c
NSString *URLString = @"http://example.com";
NSDictionary *parameters = @{@"foo": @"bar", @"baz": @[@1, @2, @3]};
```

#### Query String Parameter Encoding

```objective-c
[[WBAHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:URLString parameters:parameters error:nil];
```

    GET http://example.com?foo=bar&baz[]=1&baz[]=2&baz[]=3

#### URL Form Parameter Encoding

```objective-c
[[WBAHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:URLString parameters:parameters];
```

    POST http://example.com/
    Content-Type: application/x-www-form-urlencoded

    foo=bar&baz[]=1&baz[]=2&baz[]=3

#### JSON Parameter Encoding

```objective-c
[[WBAJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:URLString parameters:parameters];
```

    POST http://example.com/
    Content-Type: application/json

    {"foo": "bar", "baz": [1,2,3]}

---

### Network Reachability Manager

`WBANetworkReachabilityManager` monitors the reachability of domains, and addresses for both WWAN and WiFi network interfaces.

**Network reachability is a diagnostic tool that can be used to understand why a request might have failed. It should not be used to determine whether or not to make a request.**

#### Shared Network Reachability

```objective-c
[[WBANetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(WBANetworkReachabilityStatus status) {
    NSLog(@"Reachability: %@", WBAStringFromNetworkReachabilityStatus(status));
}];
```

#### HTTP Manager Reachability

```objective-c
NSURL *baseURL = [NSURL URLWithString:@"http://example.com/"];
WBAHTTPRequestOperationManager *manager = [[WBAHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];

NSOperationQueue *operationQueue = manager.operationQueue;
[manager.reachabilityManager setReachabilityStatusChangeBlock:^(WBANetworkReachabilityStatus status) {
    switch (status) {
        case WBANetworkReachabilityStatusReachableViaWWAN:
        case WBANetworkReachabilityStatusReachableViaWiFi:
            [operationQueue setSuspended:NO];
            break;
        case WBANetworkReachabilityStatusNotReachable:
        default:
            [operationQueue setSuspended:YES];
            break;
    }
}];

[manager.reachabilityManager startMonitoring];
```

---

### Security Policy

`WBASecurityPolicy` evaluates server trust against pinned X.509 certificates and public keys over secure connections.

Adding pinned SSL certificates to your app helps prevent man-in-the-middle attacks and other vulnerabilities. Applications dealing with sensitive customer data or financial information are strongly encouraged to route all communication over an HTTPS connection with SSL pinning configured and enabled.

#### Allowing Invalid SSL Certificates

```objective-c
WBAHTTPRequestOperationManager *manager = [WBAHTTPRequestOperationManager manager];
manager.securityPolicy.allowInvalidCertificates = YES; // not recommended for production
```

---

### WBAHTTPRequestOperation

`WBAHTTPRequestOperation` is a subclass of `WBAURLConnectionOperation` for requests using the HTTP or HTTPS protocols. It encapsulates the concept of acceptable status codes and content types, which determine the success or failure of a request.

Although `WBAHTTPRequestOperationManager` is usually the best way to go about making requests, `WBAHTTPRequestOperation` can be used by itself.

#### `GET` with `WBAHTTPRequestOperation`

```objective-c
NSURL *URL = [NSURL URLWithString:@"http://example.com/resources/123.json"];
NSURLRequest *request = [NSURLRequest requestWithURL:URL];
WBAHTTPRequestOperation *op = [[WBAHTTPRequestOperation alloc] initWithRequest:request];
op.responseSerializer = [WBAJSONResponseSerializer serializer];
[op setCompletionBlockWithSuccess:^(WBAHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"JSON: %@", responseObject);
} failure:^(WBAHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error: %@", error);
}];
[[NSOperationQueue mainQueue] addOperation:op];
```

#### Batch of Operations

```objective-c
NSMutableArray *mutableOperations = [NSMutableArray array];
for (NSURL *fileURL in filesToUpload) {
    NSURLRequest *request = [[WBAHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://example.com/upload" parameters:nil constructingBodyWithBlock:^(id<WBAMultipartFormData> formData) {
        [formData appendPartWithFileURL:fileURL name:@"images[]" error:nil];
    }];

    WBAHTTPRequestOperation *operation = [[WBAHTTPRequestOperation alloc] initWithRequest:request];

    [mutableOperations addObject:operation];
}

NSArray *operations = [WBAURLConnectionOperation batchOfRequestOperations:@[...] progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
    NSLog(@"%lu of %lu complete", numberOfFinishedOperations, totalNumberOfOperations);
} completionBlock:^(NSArray *operations) {
    NSLog(@"All operations in batch complete");
}];
[[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
```

## Unit Tests

WBANetworking includes a suite of unit tests within the Tests subdirectory. In order to run the unit tests, you must install the testing dependencies via [CocoaPods](http://cocoapods.org/):

    $ cd Tests
    $ pod install

Once testing dependencies are installed, you can execute the test suite via the 'iOS Tests' and 'OS X Tests' schemes within Xcode.

### Running Tests from the Command Line

Tests can also be run from the command line or within a continuous integration environment. The [`xcpretty`](https://github.com/mneorr/xcpretty) utility needs to be installed before running the tests from the command line:

    $ gem install xcpretty

Once `xcpretty` is installed, you can execute the suite via `rake test`.

## Credits

WBANetworking was originally created by [Scott Raymond](https://github.com/sco/) and [Mattt Thompson](https://github.com/mattt/) in the development of [Gowalla for iPhone](http://en.wikipedia.org/wiki/Gowalla).

WBANetworking's logo was designed by [Alan Defibaugh](http://www.alandefibaugh.com/).

And most of all, thanks to WBANetworking's [growing list of contributors](https://github.com/WBANetworking/WBANetworking/contributors).

## Contact

Follow WBANetworking on Twitter ([@WBANetworking](https://twitter.com/WBANetworking))

### Maintainers

- [Mattt Thompson](http://github.com/mattt) ([@mattt](https://twitter.com/mattt))

## License

WBANetworking is available under the MIT license. See the LICENSE file for more info.
