//
//  ELUnitOfWork.h
//  Englidio
//
//  Created by Duc Ngo on 7/1/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RPKUnitOfWork : NSObject
@property(nonatomic,strong) RPKDataContext *dataContext;

- (void) setDefaultStorageHandler:(id<RPKRemoteStorageProtocol>) storageHandler
         withObjectMappingHandler:(id<RPKObjectMappingProtocol>) objectMappingHandler;

- (void) saveChanges:(void(^)(void))onSuccess onFailure:(void(^)(NSError*))onFailure;
- (id) repositoryFor:(Class)modelClass;
@end
