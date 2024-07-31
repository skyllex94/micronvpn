# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'VPNEvo' do
  # Comment the next line if you don't want to use dynamic frameworks
  pod 'CircleProgressBar'
  pod 'KAProgressLabel'
  pod 'MZTimerLabel'

  pod 'AppsFlyerFramework'
  pod 'YandexMobileMetrica'

  pod 'Pastel'
 
  
  use_frameworks!

  # Pods for VPNEvo

  target 'VPNEvoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'VPNEvoUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
