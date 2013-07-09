//
//  RPKRepositoryCenter.m
//  ReposityKit
//
//  Created by Duc Ngo on 6/28/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import "RPKRepositoryCenter.h"

@implementation RPKRepositoryCenter


- (id)repositoryFor:(Class)modelClass{
    id repository = [[RPKRepositoryRegistry sharedRegistry] repositoryFor:[modelClass class]];
    if (!repository) {
        repository = [[RPKGenericRepository alloc] initWithModelClass:modelClass dataContext:self.dataContext storage:self.defaultStorage];
    }
    return repository;
}


@end
