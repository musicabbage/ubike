use_frameworks!
platform :ios, '12.0'

target 'ubike' do
    pod 'RxSwift', '~> 5.1'
    pod 'RxCocoa', '~> 5.1'
    pod 'SnapKit', '~> 5.0'
    pod 'GradientLoadingBar', '~> 2.0'
end

# enable tracing resources

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'RxSwift'
      target.build_configurations.each do |config|
        if config.name == 'Debug'
          config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
        end
      end
    end
  end
end
