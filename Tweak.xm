#import "../CC.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <libactivator/libactivator.h>

@interface CLLocation : NSObject 
@end

@interface WeatherPreferences : NSObject
+ (id)sharedPreferences;
- (BOOL)isCelsius;
@end

@interface WFTemperature : NSObject
@property (nonatomic) double celsius;
@property (nonatomic) double fahrenheit;
@end

@interface City : NSObject
@property (nonatomic, retain) WFTemperature *temperature;
@property(nonatomic) unsigned long long conditionCode;
@property (nonatomic, copy) CLLocation *location;
- (NSDate *)updateTime;
- (NSString *)displayName;
- (WFTemperature *)temperature;
@end

@interface WAForecastModel : NSObject
@property (nonatomic, retain) City *city;
- (City *)city;
@end

@interface WATodayModel : NSObject
@end

@interface WATodayAutoupdatingLocationModel : WATodayModel
+ (id)alloc;
- (id)init;
- (WAForecastModel *)forecastModel;
- (void)setPreferences:(id)arg1;
@end

@interface TWCCityUpdater : NSObject
@end

@interface TWCLocationUpdater : TWCCityUpdater
+ (id)sharedLocationUpdater;
- (void)updateWeatherForLocation:(id)arg1 city:(id)arg2 withCompletionHandler:(id)arg3;
@end

WATodayAutoupdatingLocationModel *todayModel;
WeatherPreferences *prefs;
WFTemperature *temp;
long conditionCode;
City *city;

@interface WeatherBannerActivatorListener : NSObject <LAListener>
@end

@implementation WeatherBannerActivatorListener

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event 
{
    event.handled = YES;
    prefs = [%c(WeatherPreferences) sharedPreferences];
    todayModel = [[%c(WATodayAutoupdatingLocationModel) alloc] init];
    [todayModel setPreferences:prefs];
    city = todayModel.forecastModel.city;
    [[%c(TWCLocationUpdater) sharedLocationUpdater] updateWeatherForLocation:city.location city:city withCompletionHandler:^{
                temp = [city temperature];
                conditionCode = [city conditionCode];
                [self presentBannerForTemperature:temp city:city usesCelcius:[prefs isCelsius]];
    }];
}

- (void)presentBannerForTemperature:(WFTemperature *)temperature city:(City *)city usesCelcius:(BOOL)celsius
{
     if (!city) {
             [[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"Weather" message:@"Please select a city." bundleID:@"com.apple.weather"];
     } else {
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    conditionCode = [city conditionCode];
                    NSString *condition = [NSString stringWithFormat:@"%ld", conditionCode];
                    NSString *result = @"";
                        switch ([condition intValue])
                        {
                            case 0:
                                result = @"Tornado Watch";
                                break;
                            case 1:
                                result = @"Tropical Storm Watch";
                                break;
                            case 2:
                                result = @"Hurricane Watch";
                                break;
                            case 3:
                                result = @"Severe Thunderstorms";
                                break;
                            case 4:
                                result = @"Thunderstorms";
                                break;
                            case 37:
                            case 38:
                                result = @"Scattered Thunderstorms";
                                break;
                            case 39:
                                result = @"Scattered Showers";
                                break;
                            case 45:
                                result = @"Heavy Rain";
                                break;
                            case 47:
                                result = @"Isolated Thunderstorms";
                                break;
                            case 5:
                                result = @"Mixed Rain with Snow";
                                break;
                            case 15:
                            case 16:
                                result = @"Snow";
                                break;
                            case 6:
                                result = @"Mixed Rain with Sleet";
                                break;
                            case 7:
                                result = @"Mixed Snow with Sleet";
                                break;
                            case 18:
                                result = @"Sleet";
                                break;
                            case 8:
                                result = @"Freezing Drizzle";
                                break;
                            case 10:
                                result = @"Freezing Rain";
                                break;
                            case 9:
                                result = @"Drizzle";
                                break;
                            case 11:
                                result = @"Showers";
                                break;
                            case 12:
                                result = @"Rain";
                                break;
                            case 13:
                                result = @"Flurries";
                                break;
                            case 14:
                                result = @"Snow Showers";
                                break;
                            case 17:
                                result = @"Hail";
                                break;
                            case 35:
                                result = @"Mixed Rainfall";
                                break;
                            case 19:
                                result = @"Dust";
                                break;
                            case 20:
                                result = @"Fog";
                                break;
                            case 21:
                                result = @"Haze";
                                break;
                            case 22:
                                result = @"Smoke";
                                break;
                            case 23:
                                result = @"Breezy"; 
                                break;
                            case 24:
                                result = @"Windy";
                                break;
                            case 25:
                                result = @"Frigid";
                                break;
                            case 26:
                                result = @"Cloudy";
                                break;
                            case 27:
                            case 28:
                                result = @"Mostly Cloudy";
                                break;
                            case 29:
                            case 30:
                                result = @"Partly Cloudy";
                                break;
                            case 31:
                                result = @"Clear";
                                break;
                            case 32:
                                result = @"Sunny";
                                break;
                            case 33:
                                result = @"Mostly Clear";
                                break;
                            case 34:
                                result = @"Mostly Sunny";
                                break;
                            case 36:
                                result = @"Hot";
                                break;
                            case 40:
                            case 41:
                                result = @"Scattered Snow Showers";
                                break;
                            case 42:
                                result = @"Heavy Snow"; 
                                break;
                            case 43:
                                result = @"Blizzard";
                                break;
                            case 46:
                                result = @"Snowy";
                                break;
                            case 44:
                            case 3200:
                            default:
                                result = @"Not Available";
                                break;
                        }
                        NSString *title = [city displayName];
                        NSString *message = celsius ? [NSString stringWithFormat: @"The current weather is %.0f°C, %@.", temperature.celsius, result] : [NSString stringWithFormat:  @"The current weather is %.0f°F, %@.", temperature.fahrenheit, result];
                        [[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:title message:message bundleID:@"com.apple.weather"];
                });
     }
}

- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName 
{
    return [NSArray arrayWithObjects:@"springboard", @"lockscreen", @"application",  nil];
}

+ (void)load 
{
    @autoreleasepool 
    {
        WeatherBannerActivatorListener *listener = [[WeatherBannerActivatorListener alloc] init];
        [[LAActivator sharedInstance] registerListener:listener forName:@"com.cabralcole.weatherbanners"];
    }
}

@end