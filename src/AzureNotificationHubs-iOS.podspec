Pod::Spec.new do |s|
  s.name                = "AzureNotificationHubs-iOS"
  s.version             = "NEW_VERSION_NUMBER"
  s.source              = { :git => "https://github.com/Azure/azure-notificationhubs-ios.git", :tag => "#{s.version}" }
  s.source_files        = "src/WindowsAzureMessaging/WindowsAzureMessaging/**/*.{h,m}"
  s.public_header_files = "src/WindowsAzureMessaging/WindowsAzureMessaging/Helpers/SBLocalStorage.h",
                          "src/WindowsAzureMessaging/WindowsAzureMessaging/Helpers/SBStoredRegistrationEntry.h",
                          "src/WindowsAzureMessaging/WindowsAzureMessaging/Helpers/SBTokenProvider.h",
                          "src/WindowsAzureMessaging/WindowsAzureMessaging/SBConnectionString.h",
                          "src/WindowsAzureMessaging/WindowsAzureMessaging/SBNotificationHub.h",
                          "src/WindowsAzureMessaging/WindowsAzureMessaging/SBRegistration.h",
                          "src/WindowsAzureMessaging/WindowsAzureMessaging/WindowsAzureMessaging.h"
  s.platform            = :ios, "6.0"
  s.author              = { "Microsoft" => "http://microsoft.com" }
  s.documentation_url   = "https://docs.microsoft.com/en-us/azure/notification-hubs/"
  s.homepage            = "http://azure.microsoft.com/en-gb/services/notification-hubs/"
  s.license             = { :type => "MIT", :file => "LICENSE"}
  s.requires_arc        = true
  s.summary             = "Push notifications for consumer and enterprise apps – from any backend to any device platform"
  s.description         = <<-DESC
Azure Notification Hubs provide an easy-to-use, multiplatform, scaled-out push infrastructure that enables you to send mobile push notifications from any backend (in the cloud or on-premises) to any mobile platform.
DESC
end
