//
//  StoreKitDelegate.h
//  Crystals
//
//  Created by Ian Fischer on 9/28/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#if __CC_PLATFORM_IOS
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface StoreKitDelegate : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property NSArray *products;
- (void)validateProductIdentifiers:(NSArray *)productIdentifiers;
@end
#endif