//
//  RPKQueryBuilder.h
//  ReposityKit
//
//  Created by Duc Ngo on 7/4/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPKQueryBuilder : NSObject
- (RPKQuery *) queryForRequest:(RPKRequestParam *)requestParam
                              error:(NSError *__autoreleasing *)error;
@end
