//
//  RPKRequestParam.h
//  ReposityKit
//
//  Created by Duc Ngo on 7/4/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPKRequestParam : NSObject
@property(nonatomic,assign) NSFetchRequest * fetchRequest;
@property(nonatomic,assign) NSIncrementalStore * incrementalStore;
@end
