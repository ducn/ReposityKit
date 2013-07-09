//
//  RPKExtenalStorageProtocol.h
//  ReposityKit
//
//  Created by Duc Ngo on 6/30/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol RPKRemoteStorageProtocol
- (void) query:(RPKRequestParam *)params onSuccess:(RPKResultsSuccessBlock)successBlock onFailure:(RPKFailureBlock)failureBlock;
@end
