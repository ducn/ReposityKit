//
//  NSManagedObjectContext+Extend.h
//  ReposityKit
//
//  Created by Duc Ngo on 6/30/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSManagedObjectContext(Concurrency)

- (void)saveOnSuccess:(void(^)(void))successBlock onFailure:(void(^)(NSError*))failureBlock;

- (void)callFetchRequest:(NSFetchRequest *)request
                  onSuccess:(void(^)(NSArray*,BOOL))successBlock
                  onFailure:(void(^)(NSError*))failureBlock;

@end
