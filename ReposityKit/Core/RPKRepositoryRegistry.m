//
//  RPKRepositoryRegistry.m
//  ReposityKit
//
//  Created by Duc Ngo on 6/30/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import "RPKRepositoryRegistry.h"

@implementation RPKRepositoryRegistry

const NSString *RPKDefaultStorageHandlerKey = @"RPKDefaultStorageHandlerKey";
const NSString *RPKDefaultObjectMappingHandlerKey=@"RPKDefaultObjectMappingHandlerKey";


+ (RPKRepositoryRegistry*)sharedRegistry{
    static RPKRepositoryRegistry *registry = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        registry = [[RPKRepositoryRegistry alloc] init];
    });
    return registry;
}

- (id)init{
    self = [super init];
    if (self) {
        _repositoryTable = [[NSMutableDictionary alloc] initWithCapacity:1];
        _storageHandlerTable    = [[NSMutableDictionary alloc] initWithCapacity:1];
        _objectMappingTable = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}

- (void)setDefaultStorageHandler:(id<RPKRemoteStorageProtocol>)storagehandler withDefaultObjectMappingHandler:(id<RPKObjectMappingProtocol>)objectMappingHandler{
    [_storageHandlerTable setObject:storagehandler forKey:RPKDefaultStorageHandlerKey];
    [_objectMappingTable setObject:objectMappingHandler forKey:RPKDefaultObjectMappingHandlerKey];
}

- (id)registerRepositoryClass:(__unsafe_unretained Class)repositoryClass
                forModelClass:(__unsafe_unretained Class)modelClass{
    return [self registerRepositoryClass:repositoryClass forModelClass:modelClass withStorageHandlerClass:nil];
}

- (id)registerRepositoryClass:(__unsafe_unretained Class)repositoryClass
                forModelClass:(__unsafe_unretained Class)modelClass
      withStorageHandlerClass:(__unsafe_unretained Class)storageHandlerClass{
    return [self registerRepositoryClass:repositoryClass forModelClass:modelClass withStorageHandlerClass:storageHandlerClass withObjectMappingHandlerClass:nil];
}

- (id)registerRepositoryClass:(__unsafe_unretained Class)repositoryClass
                forModelClass:(__unsafe_unretained Class)modelClass
      withStorageHandlerClass:( __unsafe_unretained Class)storageHandlerClass
withObjectMappingHandlerClass:(__unsafe_unretained Class)objectMappingHandlerClass{
    
    id repository = [[repositoryClass alloc] init];
    [repository setModelClass:modelClass];
    [_repositoryTable setObject:repository forKey:[modelClass description]];

    if (storageHandlerClass) {
        id storageHandler = [[storageHandlerClass alloc] init];
        [_storageHandlerTable setObject:storageHandler forKey:[modelClass description]];
    }
    
    if (objectMappingHandlerClass) {
        id objectMappingHandler = [[objectMappingHandlerClass alloc] init];
        [_objectMappingTable setObject:objectMappingHandler forKey:[modelClass description]];
    }
    return repository;
}


- (id)repositoryHandlerForModelClass:(Class)modelClass{
    return [_repositoryTable objectForKey:[modelClass description]];
}


- (id)storageHandlerForModelClass:(Class)modelClass{
    return [self storageHandlerForModelClassName:[modelClass description]];
}


- (id)storageHandlerForModelClassName:(NSString*)modelClassName{
    id storageHandler =  [_storageHandlerTable objectForKey:modelClassName];
    // If there is no specific storage handle for this model, use default storage handler
    if (!storageHandler) {
        storageHandler = [_storageHandlerTable objectForKey:RPKDefaultStorageHandlerKey];
    }
    return storageHandler;
}

- (id) objectMappingHandlerForModelClassName:(NSString*)modelClassName{
    id mappingHandler =  [_objectMappingTable objectForKey:modelClassName];
    // If there is no specific mapping handle for this model, use default mapping handler
    if (!mappingHandler) {
        mappingHandler = [_objectMappingTable objectForKey:RPKDefaultObjectMappingHandlerKey];
    }
    return mappingHandler;

}
@end
