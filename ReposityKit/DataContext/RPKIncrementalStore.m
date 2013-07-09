//
//  RPKIncrementalStore.m
//  ReposityKit
//
//  Created by Duc Ngo on 6/30/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import "RPKIncrementalStore.h"
@interface RPKIncrementalStore()
@property (nonatomic, strong) __block NSManagedObjectContext *localManagedObjectContext;
@property (nonatomic, strong) __block NSManagedObjectModel *localManagedObjectModel;
@property (nonatomic, strong) __block NSPersistentStoreCoordinator *localPersistentStoreCoordinator;
@end

@implementation RPKIncrementalStore(Utils)

- (NSURL *)getOrCreateStoreURLForFileComponent:(NSString *)fileComponent
{
    
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
    NSString *applicationDocumentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *applicationStorageDirectory = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:applicationName];
    
    NSString *fullFileName = nil;
    if (applicationName != nil)
    {
        fullFileName = [NSString stringWithFormat:@"%@-%@", applicationName, fileComponent];
    } else {
        fullFileName = [NSString stringWithFormat:@"%@",fileComponent];
    }
    
    NSArray *paths = [NSArray arrayWithObjects:applicationDocumentsDirectory, applicationStorageDirectory, nil];
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    for (NSString *path in paths)
    {
        NSString *filepath = [path stringByAppendingPathComponent:fullFileName];
        if ([fm fileExistsAtPath:filepath])
        {
            return [NSURL fileURLWithPath:filepath];
        }
        
    }
    
    NSURL *aURL = [NSURL fileURLWithPath:[applicationStorageDirectory stringByAppendingPathComponent:fullFileName]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathToStore = [aURL URLByDeletingLastPathComponent];
    BOOL isDir;
    BOOL fileExists = [fileManager fileExistsAtPath:[pathToStore path] isDirectory:&isDir];
    if (!fileExists) {
        NSError *error = nil;
        BOOL pathWasCreated = [fileManager createDirectoryAtPath:[pathToStore path] withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (!pathWasCreated) {
            [NSException raise:RPKExceptionAddPersistentStore format:@"Error creating sqlite persistent store: %@", error];
        }
    }

    return aURL;
}

@end

@implementation RPKIncrementalStore

- (BOOL)loadMetadata:(NSError *__autoreleasing *)error{
    NSString* uuid = [[NSProcessInfo processInfo] globallyUniqueString];
    [self setMetadata:[NSDictionary dictionaryWithObjectsAndKeys:
                       RPKIncrementalStoreType, NSStoreTypeKey,
                       uuid, NSStoreUUIDKey,
                       @"Something user defined", @"Some user defined key",
                       nil]];
    return YES;
}
#pragma mark - Constructors
- (NSManagedObjectContext *)localManagedObjectContext
{
    if (_localManagedObjectContext == nil) {
        _localManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_localManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [_localManagedObjectContext setPersistentStoreCoordinator:self.localPersistentStoreCoordinator];
    }
    
    return _localManagedObjectContext;
    
}

- (NSManagedObjectModel *)localManagedObjectModel
{
    if (_localManagedObjectModel == nil) {
        _localManagedObjectModel = self.persistentStoreCoordinator.managedObjectModel;
    }
    
    return _localManagedObjectModel;
}

- (NSPersistentStoreCoordinator *)localPersistentStoreCoordinator
{
    if (_localPersistentStoreCoordinator == nil) {
        
        _localPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.localManagedObjectModel];
        
        NSURL *storeURL = [self getOrCreateStoreURLForFileComponent:RPKSqlDatabaseName];
        NSLog(@"storeURL: %@",storeURL);
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        
        NSError *error = nil;
        [_localPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
        
        if (error != nil) {
        }
    }
    return _localPersistentStoreCoordinator;
}

#pragma mark - Incremental Store events
- (id)executeRequest:(NSPersistentStoreRequest *)request withContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error{
    id result = nil;
    switch (request.requestType) {
        case NSSaveRequestType:
            //result = [self handleSaveRequest:request withContext:context error:error];
            break;
        case NSFetchRequestType:
            result = [self handleFetchRequest:request withContext:context error:error];
            break;
        default:
            [NSException raise:RPKExceptionIncompatibleObject format:@"Unknown request type."];
            break;
    }
    return result;
}


- (NSIncrementalStoreNode *)newValuesForObjectWithID:(NSManagedObjectID *)objectID withContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error{

    NSLog(@"newValuesForObjectWithID: %@ & %@",context, objectID);
    __block NSManagedObject *managedObject = [context objectWithID:objectID];
    __block NSString *managedObjectReferenceID = [self referenceObjectForObjectID:objectID];

    NSManagedObject *localManagedObject = [self getLocalManagedObjectWithID:managedObjectReferenceID
                                                                   entityName:[[managedObject entity] name]
                                               returnManagedObjectIDInsteadManagedObject:FALSE
                                                               createIfNeeded:YES];
    
    // Create dictionary of keys and values for incremental store node
    NSMutableDictionary *dictionaryRepresentationOfCacheObject = [NSMutableDictionary dictionary];
    
    [[localManagedObject dictionaryWithValuesForKeys:[[[localManagedObject entity] attributesByName] allKeys]] enumerateKeysAndObjectsUsingBlock:^(id attributeName, id attributeValue, BOOL *stop) {
        if (attributeValue != [NSNull null]) {
            [dictionaryRepresentationOfCacheObject setObject:attributeValue forKey:attributeName];
        }
    }];
    
    [[localManagedObject dictionaryWithValuesForKeys:[[[localManagedObject entity] relationshipsByName] allKeys]] enumerateKeysAndObjectsUsingBlock:^(id relationshipName, id relationshipValue, BOOL *stop) {
        if (![[[[localManagedObject entity] relationshipsByName] objectForKey:relationshipName] isToMany]) {
            if (relationshipValue == [NSNull null] || relationshipValue == nil) {
                [dictionaryRepresentationOfCacheObject setObject:[NSNull null] forKey:relationshipName];
            } else {
            }
        }
    }];
    
    NSIncrementalStoreNode *node = [[NSIncrementalStoreNode alloc] initWithObjectID:objectID
                                                                         withValues:dictionaryRepresentationOfCacheObject version:1];
    return node;

}

#pragma mark - Save requests
//- (id)handleSaveRequest:(NSPersistentStoreRequest *)request
//             withContext:(NSManagedObjectContext *)context
//                   error:(NSError * __autoreleasing *)error {
//{
//    NSSet *insertedObjects = [request insertedObjects];
//    if ([insertedObjects count] > 0) {
//        BOOL insertSuccess = [self saveObjects:insertedObjects inContext:context  error:error];
//        if (!insertSuccess) {
//            return nil;
//        }
//    }
//    return [NSArray array];
//}
//    
//- (BOOL)saveObjects:(NSSet *)insertedObjects inContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error{
//    return TRUE;
//}

#pragma mark - Fetch requests

- (id)handleFetchRequest:(NSPersistentStoreRequest *)request
                withContext:(NSManagedObjectContext *)context
                      error:(NSError * __autoreleasing *)error {
    
    NSFetchRequest *fetchRequest = (NSFetchRequest *)request;
    switch (fetchRequest.resultType) {
        case NSManagedObjectResultType:
            return [self fetchObjects:fetchRequest withContext:context error:error];
            break;
        case NSManagedObjectIDResultType:
            return [self fetchObjectIDs:fetchRequest withContext:context error:error];
            break;
        case NSDictionaryResultType:
            break;
        case NSCountResultType:
            break;
        default:
            [NSException raise:RPKExceptionIncompatibleObject format:@"Unknown result type requested."];
            break;
    }
    return nil;
}


- (id)fetchObjectIDs:(NSFetchRequest *)fetchRequest withContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error {
    
    NSFetchRequest *fetchCopy = [fetchRequest copy];
    
    [fetchCopy setResultType:NSManagedObjectResultType];
    
    if ([fetchRequest fetchBatchSize] > 0) {
        [fetchCopy setFetchBatchSize:[fetchRequest fetchBatchSize]];
    }
    
    NSArray *objects = [self fetchObjects:fetchCopy withContext:context error:error];
    
    // Error check
    if (*error != nil) {
        return nil;
    }
    
    return [objects map:^(id item) {
        return [item objectID];
    }];
}



- (id) fetchObjects:(NSPersistentStoreRequest *)request
        withContext:(NSManagedObjectContext *)privateContext
              error:(NSError * __autoreleasing *)error {
    
    NSFetchRequest *fetchRequest = (NSFetchRequest *)request;
    
    
    
    // Fetch object from server and wait for response
    id<RPKRemoteStorageProtocol> remoteStorage = [[RPKRepositoryRegistry sharedRegistry]
                                                  storageHandlerForModelClassName:fetchRequest.entityName];
    __block NSArray *fetchObjects;    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    RPKRequestParam *params = [[RPKRequestParam alloc] init];
    [params setFetchRequest:fetchRequest];
    [params setIncrementalStore:self];
    
    [remoteStorage query:params onSuccess:^(NSArray *results,BOOL isCachedResult) {
        fetchObjects = results;
        dispatch_group_leave(group);
    } onFailure:^(NSError *error) {
        dispatch_group_leave(group);
    }];
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
#if !OS_OBJECT_USE_OBJC
    dispatch_release(group);
#endif
    
    // Refresh local objects with fetch object from server
    __block id<RPKObjectMappingProtocol> objectMappingHandler = [[RPKRepositoryRegistry sharedRegistry]
                                                                 objectMappingHandlerForModelClassName:fetchRequest.entityName];
    
    // Now we have fetched objects from server which are dictionary items
    // We need to convert them to managed object entity
    // For each result of the fetch
    // Obtain the primary key for the entity
    __block NSString *primaryKeyField = nil;
    
    primaryKeyField = [objectMappingHandler primaryKeyFieldForEntity:fetchRequest.entity];
    
    // For each result of the fetch, this is not async method
    NSArray *objectsOnPrivateContext = [fetchObjects map:^(id item) {
        
        id remoteID = [item objectForKey:primaryKeyField];
        
        if (!remoteID) {
            [NSException raise:SMExceptionIncompatibleObject format:@"No key for supposed primary key field %@ for item %@", primaryKeyField, item];
        }
        
        // Create a managed object on private contact, and mapping with JSON data
        // Why is private, because the context of caller of this method is Private context
        // and it's going return mo objects on this context
        NSManagedObjectID *privateManagedObjectID = [self newObjectIDForEntity:fetchRequest.entity referenceObject:remoteID];
        NSManagedObject *privateManagedObject = [privateContext objectWithID:privateManagedObjectID];
        // We'd map json data to private manage object here, instead, it just keep its object ID, then
        // When access its property, will will get the value in method newValuesForObjectWithIDs
        
        // But we still have local context, this context for actually saving objects to database
        // So here is the place we save objects to local context and write change to disks
        NSManagedObjectID *localManagedObjectID =[self getLocalManagedObjectWithID:remoteID
                                                                        entityName:fetchRequest.entityName
                                         returnManagedObjectIDInsteadManagedObject:TRUE
                                                                    createIfNeeded:YES];
        NSManagedObject *localManagedObject = [self.localManagedObjectContext objectWithID:localManagedObjectID];
        [objectMappingHandler mapJSON:item toManagedObject:localManagedObject withEntityDescription:fetchRequest.entity];
        return privateManagedObject;
        
    }];
    
    // Save Cache if has changes
    if ([self.localManagedObjectContext hasChanges]) {
        __block BOOL localCacheSaveSuccess;
        [self.localManagedObjectContext performBlockAndWait:^{
          localCacheSaveSuccess = [self.localManagedObjectContext save:error];
        }];
        if (!localCacheSaveSuccess) {
          if (NULL != error) {
              *error = (__bridge id)(__bridge_retained CFTypeRef)*error;
              //NSLog(@"Save db error: %@",error);
          }
        }
    }

    return objectsOnPrivateContext;
}


#pragma mark - Utilities
+ (NSString*) primaryKeyFieldNameForLocalEntity:(NSEntityDescription*)entity{
    return @"identity";//[[entity.name lowercaseString] stringByAppendingString:@"Id"];
}



- (id) getLocalManagedObjectWithID:(NSString *)remoteObjectID
                                             entityName:(NSString *)entityName
             returnManagedObjectIDInsteadManagedObject:(BOOL)returnManagedObjectIDInsteadManagedObject
                                         createIfNeeded:(BOOL)createIfNeeded{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    if (returnManagedObjectIDInsteadManagedObject) {
        [fetchRequest setResultType:NSManagedObjectIDResultType];
    }
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.localManagedObjectContext];

    NSString *primaryKeyField = [RPKIncrementalStore primaryKeyFieldNameForLocalEntity:entityDesc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", primaryKeyField, remoteObjectID];
    NSPredicate *nilReferencePredicate = [NSPredicate predicateWithFormat:@"%K == %@", primaryKeyField, [NSString stringWithFormat:@"%@:nil", remoteObjectID]];
    
    NSArray *predicates = [NSArray arrayWithObjects:predicate, nilReferencePredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    [fetchRequest setPredicate:compoundPredicate];
    
    NSError *fetchError = nil;
    __block NSArray *results = [self.localManagedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError || [results count] > 1) {
        // TODO handle error
    }
    
    __block NSManagedObject *localObject = nil;
    if ([results count] == 0 && createIfNeeded) {
        // Create new cache object
        localObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.localManagedObjectContext];
        NSError *permanentIdError = nil;
        [self.localManagedObjectContext obtainPermanentIDsForObjects:[NSArray arrayWithObject:localObject] error:&permanentIdError];
        if (permanentIdError) {
            [NSException raise:RPKExceptionInsertLocalObjectError format:@"Could not obtain permanent IDs for objects %@ with error %@", localObject, permanentIdError];
        }
    } else {
        // result count == 1
        localObject = [results lastObject];
    }
    return localObject;
}

@end
