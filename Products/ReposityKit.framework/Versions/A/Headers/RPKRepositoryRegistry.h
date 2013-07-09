//
//  RPKRepositoryRegistry.h
//  ReposityKit
//
//  Created by Duc Ngo on 6/30/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSString *RPKDefaultStorageHandlerKey;
extern const NSString *RPKDefaultObjectMappingHandlerKey;
@class RPKRepositoryRegistryItem;

@interface RPKRepositoryRegistry : NSObject{
    NSMutableDictionary *_repositoryTable;
    /*
        key: <model class name>
        value: <repository instance>
     */
    NSMutableDictionary *_storageHandlerTable;
    /*
        key: <model class name>, always have default key is RPKDefaultStorageHandlerKey
        value: <storage handler instance>, register default storage handler
     */
    NSMutableDictionary *_objectMappingTable;
    /*
        key: <model class name>, always have default key is RPKDefaultObjectMappingHandlerKey
        value: <object mapping handler instance> register default object mapping handler
     */
}

#pragma mark - Set methods
- (void) setDefaultStorageHandler:(id<RPKRemoteStorageProtocol>)storagehandler withDefaultObjectMappingHandler:(id<RPKObjectMappingProtocol>)objectMappingHandler;

- (id) registerRepositoryClass:(Class)repositoryClass
                 forModelClass:(Class)modelClass;

- (id) registerRepositoryClass:(Class)repositoryClass
                 forModelClass:(Class)modelClass
       withStorageHandlerClass:(Class)storageHandlerClass;

- (id) registerRepositoryClass:(Class)repositoryClass
                 forModelClass:(Class)modelClass
       withStorageHandlerClass:(Class)storageHandlerClass
 withObjectMappingHandlerClass:(Class)objectMappingHandlerClass;



#pragma mark - Get methods
+ (RPKRepositoryRegistry*) sharedRegistry;

- (id) repositoryHandlerForModelClass:(Class) modelClass;

- (id) storageHandlerForModelClass:(Class) modelClass;
- (id) storageHandlerForModelClassName:(NSString*)modelClassName;

- (id) objectMappingHandlerForModelClassName:(NSString*)modelClassName;
@end

