//
//  RPKRepositoryCenter.h
//  ReposityKit
//
//  Created by Duc Ngo on 6/28/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPKRepositoryCenter : NSObject{
    
}
@property(nonatomic,strong) id<RPKExtenalStorageProtocol> defaultStorage;
@property(nonatomic,strong) RPKDataContext* dataContext;
- (id) repositoryFor:(Class)modelClass;
@end
