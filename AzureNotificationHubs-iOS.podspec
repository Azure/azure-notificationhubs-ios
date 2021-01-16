Pod::Spec.new do |s|
  s.name                = "AzureNotificationHubs-iOS"
  s.version             = "3.1.2"

  s.summary             = "Push notifications for consumer and enterprise apps – from any backend to any device platform"
  s.description         = <<-DESC
                          Azure Notification Hubs provide an easy-to-use, multiplatform, scaled-out push infrastructure that enables you to send mobile push notifications from any backend (in the cloud or on-premises) to any mobile platform.
                          DESC

  s.author              = { "Microsoft" => "http://microsoft.com" }
  s.license             = { :type => "Apache 2.0", :file => "WindowsAzureMessaging-SDK-Apple/LICENSE" }
  s.documentation_url   = "https://docs.microsoft.com/en-us/azure/notification-hubs/"
  s.homepage            = "http://azure.microsoft.com/en-us/services/notification-hubs/"

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.9"
  s.tvos.deployment_target = "11.0"
  s.source              = { :http => "https://github.com/Azure/azure-notificationhubs-ios/releases/download/#{s.version}/WindowsAzureMessaging-SDK-Apple-XCFramework-#{s.version}.zip" }
  s.preserve_path       = "WindowsAzureMessaging-SDK-Apple/README.md"

  s.frameworks          = "Foundation", "SystemConfiguration"
  s.ios.frameworks      = "UIKit"
  s.tvos.frameworks     = "UIKit"
  s.osx.frameworks      = "AppKit"
  s.ios.weak_frameworks = "UserNotifications" 
  s.tvos.weak_frameworks = "UserNotifications" 
  s.osx.weak_frameworks = "UserNotifications" 
  s.ios.vendored_frameworks = "WindowsAzureMessaging-SDK-Apple/WindowsAzureMessaging.xcframework"
  s.tvos.vendored_frameworks = "WindowsAzureMessaging-SDK-Apple/WindowsAzureMessaging.xcframework"
  s.osx.vendored_frameworks = "WindowsAzureMessaging-SDK-Apple/WindowsAzureMessaging.xcframework"

end
