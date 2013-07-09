//
//  ReposityKitTests.m
//  ReposityKitTests
//
//  Created by Duc Ngo on 6/27/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import "ReposityKitTests.h"

int ddLogLevel = LOG_LEVEL_INFO;

@implementation ReposityKitTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    RPKUnitOfWork *unitOfWork = [[RPKUnitOfWork alloc] init];
    [[unitOfWork repositoryFor:[ELVideo class]] find:@"title=Google" onSuccess:^(NSArray *results, BOOL isCachedResults) {
        if(!isCachedResults){
            DDLogCInfo(@"No cached");
            for (ELVideo* obj in results) {
                NSLog(@"%@",obj.title);
            }
        }
        else
        {
            DDLogCInfo(@"Cached");
            for (ELVideo* obj in results) {
                NSLog(@"%@",obj.title);
            }
        }
    } onFailure:^(NSError *error) {
        DDLogCInfo(@"Failre");
    }];

    STFail(@"Unit tests are not implemented yet in ReposityKitTests");
}

@end
