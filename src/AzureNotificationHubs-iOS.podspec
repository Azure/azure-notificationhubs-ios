Pod::Spec.new do |s|
  s.name                = "AzureNotificationHubs-iOS"
  s.version             = "3.0.0-preview1"
  s.source              = { :http => "https://github.com/Azure/azure-notificationhubs-ios/releases/download/#{s.version}/WindowsAzureMessaging.framework.zip" }
  s.vendored_frameworks = "WindowsAzureMessaging.framework"
  s.platform            = :ios, "8.0"
  s.author              = { "Microsoft" => "http://microsoft.com" }
  s.documentation_url   = "https://docs.microsoft.com/en-us/azure/notification-hubs/"
  s.homepage            = "http://azure.microsoft.com/en-us/services/notification-hubs/"
  s.requires_arc        = true
  s.summary             = "Push notifications for consumer and enterprise apps – from any backend to any device platform"
  s.description         = <<-DESC
Azure Notification Hubs provide an easy-to-use, multiplatform, scaled-out push infrastructure that enables you to send mobile push notifications from any backend (in the cloud or on-premises) to any mobile platform.
DESC
  s.license             = { :type => "Apache 2.0", :file => "License" }
end
