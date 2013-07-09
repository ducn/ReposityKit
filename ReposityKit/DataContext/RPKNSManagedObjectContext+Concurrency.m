//
//  NSManagedObjectContext+Extend.m
//  ReposityKit
//
//  Created by Duc Ngo on 6/30/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import "RPKNSManagedObjectContext+Concurrency.h"

@implementation NSManagedObjectContext(Concurrency)
- (void)saveOnSuccess:(void(^)(void))successBlock onFailure:(void(^)(NSError*))failureBlock
{
    
}

- (void)callFetchRequest:(NSFetchRequest *)request onSuccess:(void (^)(NSArray *,BOOL))successBlock onFailure:(void (^)(NSError *))failureBlock
{

    // Call to get Cached data and return first
    NSManagedObjectContext *mainContext = self;
    NSManagedObjectContext *privateContext = mainContext.parentContext;
    NSError *error;
    [privateContext performBlock:^{
        
    }];
    
    // Perform fetch in private queue, this would be async with Main queue, so NON Blocking UI
    [privateContext performBlock:^{
        NSError *error;
                
        // This will invoke the Incremental Store class with action executeRequest...
        // and object will fetch from server
        NSFetchRequest *fetchRequestCopy = [request copy];
        [fetchRequestCopy setResultType:NSManagedObjectIDResultType];
        __block NSArray *fetchObjects = [privateContext executeFetchRequest:fetchRequestCopy error:&error];
        if (error) {
            failureBlock(error);
        }
        else{
            if (successBlock) {
                // Dispatch fetchObjects to Main Queue
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSManagedObjectContext *context = nil;
                    
                    if ([NSThread isMainThread]) {
                        context = mainContext;
                        
                    } else {
                        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                        [context setPersistentStoreCoordinator:[privateContext persistentStoreCoordinator]];
                    }
                    
                    // Now with each objects fetched from server which is a dictionary, we will retrive a managed object
                    // by fetching from local object which have the same primary key ID, then update with new values
                    // if it doesn't exist, we'll create new one
                    __block NSArray *managedObjectsToReturn = [fetchObjects map:^id(id item) {
                        NSManagedObject *objectFromCurrentContext = [context objectWithID:item];
                        [context refreshObject:objectFromCurrentContext mergeChanges:YES];
                        return objectFromCurrentContext;
                    }];
                    
                    successBlock(managedObjectsToReturn,FALSE);
                    
                });

            }
        }
    }];
}
@end
