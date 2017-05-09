DEBUG = 0
PACKAGE_VERSION = 1.0.2
SDKVERSION = 10.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeatherBanners
WeatherBanners_FILES = Tweak.xm
WeatherBanners_LIBRARIES = activator
WeatherBanners_FRAMEWORKS = UIKit CoreLocation
WeatherBanners_PRIVATE_FRAMEWORKS = Weather

include $(THEOS_MAKE_PATH)/tweak.mk