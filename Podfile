# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'CalPal' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CalPal
	pod 'TesseractOCRiOS', '4.0.0'

  target 'CalPalTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end
