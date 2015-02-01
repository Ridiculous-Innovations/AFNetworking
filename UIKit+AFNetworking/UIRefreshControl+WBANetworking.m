// UIRefreshControl+WBANetworking.m
//
// Copyright (c) 2014 WBANetworking (http://WBANetworking.com)
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

#import "UIRefreshControl+WBANetworking.h"

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

#import "WBAHTTPRequestOperation.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#import "WBAURLSessionManager.h"
#endif

@implementation UIRefreshControl (WBANetworking)

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
- (void)setRefreshingWithStateOfTask:(NSURLSessionTask *)task {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter removeObserver:self name:WBANetworkingTaskDidResumeNotification object:nil];
    [notificationCenter removeObserver:self name:WBANetworkingTaskDidSuspendNotification object:nil];
    [notificationCenter removeObserver:self name:WBANetworkingTaskDidCompleteNotification object:nil];

    if (task) {
        if (task.state == NSURLSessionTaskStateRunning) {
            [self beginRefreshing];

            [notificationCenter addObserver:self selector:@selector(wba_beginRefreshing) name:WBANetworkingTaskDidResumeNotification object:task];
            [notificationCenter addObserver:self selector:@selector(wba_endRefreshing) name:WBANetworkingTaskDidCompleteNotification object:task];
            [notificationCenter addObserver:self selector:@selector(wba_endRefreshing) name:WBANetworkingTaskDidSuspendNotification object:task];
        } else {
            [self endRefreshing];
        }
    }
}
#endif

- (void)setRefreshingWithStateOfOperation:(WBAURLConnectionOperation *)operation {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter removeObserver:self name:WBANetworkingOperationDidStartNotification object:nil];
    [notificationCenter removeObserver:self name:WBANetworkingOperationDidFinishNotification object:nil];

    if (operation) {
        if (![operation isFinished]) {
            if ([operation isExecuting]) {
                [self beginRefreshing];
            } else {
                [self endRefreshing];
            }

            [notificationCenter addObserver:self selector:@selector(wba_beginRefreshing) name:WBANetworkingOperationDidStartNotification object:operation];
            [notificationCenter addObserver:self selector:@selector(wba_endRefreshing) name:WBANetworkingOperationDidFinishNotification object:operation];
        }
    }
}

#pragma mark -

- (void)wba_beginRefreshing {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self beginRefreshing];
    });
}

- (void)wba_endRefreshing {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

@end

#endif
