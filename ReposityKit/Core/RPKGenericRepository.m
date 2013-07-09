//
//  RPKRepository.m
//  ReposityKit
//
//  Created by Duc Ngo on 6/27/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import "RPKGenericRepository.h"

@implementation RPKGenericRepository
- (id<RPKRemoteStorageProtocol>)remoteStorage{
    return [[RPKRepositoryRegistry sharedRegistry] storageHandlerForModelClass:self.modelClass];
}
- (id)newModel{
    return NULL;
}

- (void) find:(NSString*)query onSuccess:(RPKResultsSuccessBlock)successBlock onFailure:(RPKFailureBlock)failureBlock{    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:[_modelClass description]
                                        inManagedObjectContext:[self.dataContext mainContext]]];
    [[self.dataContext mainContext] callFetchRequest:fetchRequest onSuccess:^(NSArray *results, BOOL cached) {
        successBlock(results,cached);
        NSError *error;
        //[[self.dataContext privateContext] save:&error];
        //NSLog(@"%@",error);
    } onFailure:^(NSError *error) {
        failureBlock(error);
    }];
    
}
@end
