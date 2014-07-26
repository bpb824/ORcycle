@protocol TripInfoDelegate <NSObject>

@required
- (void)setSaved:(BOOL)value;

@optional
- (void)saveTripResponse;

@end
