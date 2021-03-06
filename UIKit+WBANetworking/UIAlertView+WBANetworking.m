// UIAlertView+WBANetworking.m
//
// Copyright (c) 2013-2015 WBANetworking (http://WBANetworking.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIAlertView+WBANetworking.h"

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

#import "WBAURLConnectionOperation.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#import "WBAURLSessionManager.h"
#endif

static void WBAGetAlertViewTitleAndMessageFromError(NSError *error, NSString * __autoreleasing *title, NSString * __autoreleasing *message) {
    if (error.localizedDescription && (error.localizedRecoverySuggestion || error.localizedFailureReason)) {
        *title = error.localizedDescription;

        if (error.localizedRecoverySuggestion) {
            *message = error.localizedRecoverySuggestion;
        } else {
            *message = error.localizedFailureReason;
        }
    } else if (error.localizedDescription) {
        *title = NSLocalizedStringFromTable(@"Error", @"WBANetworking", @"Fallback Error Description");
        *message = error.localizedDescription;
    } else {
        *title = NSLocalizedStringFromTable(@"Error", @"WBANetworking", @"Fallback Error Description");
        *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ Error: %ld", @"WBANetworking", @"Fallback Error Failure Reason Format"), error.domain, (long)error.code];
    }
}

@implementation UIAlertView (WBANetworking)

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
+ (void)showAlertViewForTaskWithErrorOnCompletion:(NSURLSessionTask *)task
                                         delegate:(id)delegate
{
    [self showAlertViewForTaskWithErrorOnCompletion:task delegate:delegate cancelButtonTitle:NSLocalizedStringFromTable(@"Dismiss", @"WBANetworking", @"UIAlertView Cancel Button Title") otherButtonTitles:nil, nil];
}

+ (void)showAlertViewForTaskWithErrorOnCompletion:(NSURLSessionTask *)task
                                         delegate:(id)delegate
                                cancelButtonTitle:(NSString *)cancelButtonTitle
                                otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list otherTitleList;
    va_start(otherTitleList, otherButtonTitles);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil, nil];
    for(NSString *otherTitle = otherButtonTitles; otherTitle != nil; otherTitle = va_arg(otherTitleList, NSString *)){
        [alertView addButtonWithTitle:otherTitle];
    }
    va_end(otherTitleList);
    __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:WBANetworkingTaskDidCompleteNotification object:task queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {

        NSError *error = notification.userInfo[WBANetworkingTaskDidCompleteErrorKey];
        if (error) {
            NSString *title, *message;
            WBAGetAlertViewTitleAndMessageFromError(error, &title, &message);

            [alertView setTitle:title];
            [alertView setMessage:message];
            [alertView show];
        }

        [[NSNotificationCenter defaultCenter] removeObserver:observer name:WBANetworkingTaskDidCompleteNotification object:notification.object];
    }];
}
#endif

#pragma mark -

+ (void)showAlertViewForRequestOperationWithErrorOnCompletion:(WBAURLConnectionOperation *)operation
                                                     delegate:(id)delegate
{
    [self showAlertViewForRequestOperationWithErrorOnCompletion:operation delegate:delegate cancelButtonTitle:NSLocalizedStringFromTable(@"Dismiss", @"WBANetworking", @"UIAlertView Cancel Button Title") otherButtonTitles:nil, nil];
}

+ (void)showAlertViewForRequestOperationWithErrorOnCompletion:(WBAURLConnectionOperation *)operation
                                                     delegate:(id)delegate
                                            cancelButtonTitle:(NSString *)cancelButtonTitle
                                            otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list otherTitleList;
    va_start(otherTitleList, otherButtonTitles);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil, nil];
    for(NSString *otherTitle = otherButtonTitles; otherTitle != nil; otherTitle = va_arg(otherTitleList, NSString *)){
        [alertView addButtonWithTitle:otherTitle];
    }
    va_end(otherTitleList);
    __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:WBANetworkingOperationDidFinishNotification object:operation queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {

        if (notification.object && [notification.object isKindOfClass:[WBAURLConnectionOperation class]]) {
            NSError *error = [(WBAURLConnectionOperation *)notification.object error];
            if (error) {
                NSString *title, *message;
                WBAGetAlertViewTitleAndMessageFromError(error, &title, &message);

                [alertView setTitle:title];
                [alertView setMessage:message];
                [alertView show];
            }
        }

        [[NSNotificationCenter defaultCenter] removeObserver:observer name:WBANetworkingOperationDidFinishNotification object:notification.object];
    }];
}

@end

#endif
