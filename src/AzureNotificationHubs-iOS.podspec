Pod::Spec.new do |s|
  s.name           = "AzureNotificationHubs-iOS"
  s.version        = "0.0.1"
  s.source         = { :git => "https://github.com/Azure/azure-notificationhubs-ios.git", :tag => "#{s.version}" }
  s.source_files   = "src/WindowsAzureMessaging/WindowsAzureMessaging/**/*.{h,m}"
  s.platform       = :ios, "6.0"
  s.author         = { "Microsoft" => "http://microsoft.com" }
  s.homepage       = "http://azure.microsoft.com/en-gb/services/notification-hubs/"
  s.license        = { :type => "MIT", :file => "LICENSE"}
  s.requires_arc   = true
  s.summary        = "Push notifications for consumer and enterprise apps – from any backend to any device platform"
  s.description    = <<-DESC
Azure Notification Hubs provide an easy-to-use, multiplatform, scaled-out push infrastructure that enables you to send mobile push notifications from any backend (in the cloud or on-premises) to any mobile platform.
                     DESC
end
