platform :ios, '7.1'

inhibit_all_warnings!

pod 'ReactiveCocoa', '~> 2.3'
pod 'ReactiveViewModel', '~> 0.2'
pod 'Mantle', '~> 1.4'
pod 'FXBlurView', '~> 1.6.1'

target :test, :exclusive => true do
    link_with 'ReactiveWeatherTests'
    pod 'Specta', '~> 0.2.1'
    pod 'Expecta', '~> 0.3.0'
    pod 'OCMockito', '~> 1.2.0'
end