@protocol TripInfoDelegate <NSObject>

@required
- (void)popController;
- (void)setSaved:(BOOL)value;

@optional
- (void)saveTripResponse;

@end
