//
//  RPKIncrementalStore.h
//  SMResponseBlocks
//
//  Created by Duc Ngo on 6/30/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//
@class AFHTTPRequestOperation;

/**
 A success block that returns nothing.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
typedef void (^RPKSuccessBlock)();

/**
 The block parameters expected for a success response which returns an `NSDictionary`.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
typedef void (^RPKResultSuccessBlock)(NSDictionary *result,BOOL isCachedResults);

/**
 The block parameters expected for a success response which returns an `NSArray`.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
typedef void (^RPKResultsSuccessBlock)(NSArray *results,BOOL isCachedResults);

/**
 The block parameters expected for any failure response.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
typedef void (^RPKFailureBlock)(NSError *error);

