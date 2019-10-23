#import <Batch/Batch.h>
#import <Batch/BatchEventDispatcher.h>

@interface BatchFirebaseDispatcher : NSObject <BatchEventDispatcherDelegate>

+ (nonnull instancetype)instance;

@end
