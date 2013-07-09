//
//  ELUnitOfWork.m
//  Englidio
//
//  Created by Duc Ngo on 7/1/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import "RPKUnitOfWork.h"

@implementation RPKUnitOfWork

- (id)init{
    self = [super init];
    if (self) {
        RPKDataContext *ctx = [[RPKDataContext alloc] init];
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Englidio" withExtension:@"momd"];
        NSManagedObjectModel * managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        [ctx setManagedObjectModel:managedObjectModel];
        self.dataContext = ctx;
        
        // Register default remote storage and object mapping handler
        [[RPKRepositoryRegistry sharedRegistry] setDefaultStorageHandler:[[RPKStackMobStorage alloc] init]
                                         withDefaultObjectMappingHandler:[[RPKStackMobObjectMapping alloc] init]];
    }
    return self;
}

-(void)setDefaultStorageHandler:(id)storageHandler withObjectMappingHandler:(id)objectMappingHandler{
    [[RPKRepositoryRegistry sharedRegistry] setDefaultStorageHandler:storageHandler
                                     withDefaultObjectMappingHandler:objectMappingHandler];
}


- (id)repositoryFor:(Class)modelClass{
    id repository = [[RPKRepositoryRegistry sharedRegistry] repositoryHandlerForModelClass:[modelClass class]];
    if (!repository) {
        repository = [[RPKRepositoryRegistry sharedRegistry] registerRepositoryClass:[RPKGenericRepository class]
                                                                       forModelClass:modelClass];
    }
    [repository setDataContext:self.dataContext];
    return repository;
}

- (void)saveChanges:(void(^)(void))onSuccess onFailure:(void(^)(NSError *))onFailure{
}
@end
