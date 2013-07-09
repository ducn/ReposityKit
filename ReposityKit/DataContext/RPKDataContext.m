//
//  RPKDataContext.m
//  ReposityKit
//
//  Created by Duc Ngo on 6/30/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import "RPKDataContext.h"

@implementation RPKDataContext

// Setup persitence coordinator
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    if (_persistentStoreCoordinator == nil) {
        [NSPersistentStoreCoordinator registerStoreClass:[RPKIncrementalStore class] forStoreType:RPKIncrementalStoreType];
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSURL *sqlDBPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSError *error = nil;
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, self, RPKDataStoreKey, nil];

        [_persistentStoreCoordinator addPersistentStoreWithType:RPKIncrementalStoreType
                                                  configuration:nil
                                                            URL:nil
                                                        options:options
                                                          error:&error];
        if (error != nil) {
            [NSException raise:RPKExceptionAddPersistentStore format:@"Error creating incremental persistent store: %@", error];
        }
        
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)privateContext{
    if (_privateContext == nil) {
        _privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_privateContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [_privateContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _privateContext;
}

- (NSManagedObjectContext *)mainContext{
    if (_mainContext == nil) {
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [_mainContext setParentContext:self.privateContext];
    }
    return _mainContext;
}
@end
