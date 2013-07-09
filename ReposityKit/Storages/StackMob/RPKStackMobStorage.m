//
//  RPKStackMobDataContext.m
//  ReposityKit
//
//  Created by Duc Ngo on 6/29/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import "RPKStackMobStorage.h"

@implementation RPKStackMobStorage

- (id)init{
    self = [super init];
    if (self) {
        self.client = [[SMClient alloc] initWithAPIVersion:@"0" publicKey:@"18fc739f-0c08-4fec-b6de-9cbc203b93f4"];
    }
    return self;
}
- (SMIncrementalStore *)incrementalStoreFromStore:(NSIncrementalStore*)store{
    if (!_smIncrementalStore) {
        _smIncrementalStore = [[SMIncrementalStore alloc] initWithPersistentStoreCoordinator:store.persistentStoreCoordinator configurationName:store.configurationName URL:store.URL options:store.options];
    }
    return _smIncrementalStore;
}
- (void)query:(RPKRequestParam*)params onSuccess:(RPKResultsSuccessBlock)successBlock onFailure:(RPKFailureBlock)failureBlock{
    SMIncrementalStore *smIncrementalStore = [self incrementalStoreFromStore:params.incrementalStore];
    NSError *error;
    SMQuery *query = [smIncrementalStore queryForFetchRequest:params.fetchRequest error:&error];
    
    [[self.client dataStore] performQuery:query onSuccess:^(NSArray *results) {
        successBlock(results,FALSE);
    } onFailure:^(NSError *error) {
        failureBlock(error);
    }];
     
}
@end
