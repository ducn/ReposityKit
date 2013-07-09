//
//  RPKRepository.h
//  ReposityKit
//
//  Created by Duc Ngo on 6/27/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPKGenericRepository : NSObject{
}
@property (nonatomic,readonly,getter=remoteStorage) id<RPKRemoteStorageProtocol> remoteStorage;
@property (nonatomic,strong) Class modelClass;
@property (nonatomic,assign) RPKDataContext *dataContext;
- (id) newModel;
- (void) find:(NSString*)query onSuccess:(RPKResultsSuccessBlock)successBlock onFailure:(RPKFailureBlock)failureBlock;
@end
