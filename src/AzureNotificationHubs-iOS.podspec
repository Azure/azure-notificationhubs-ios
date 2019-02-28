Pod::Spec.new do |s|
  s.name                = "AzureNotificationHubs-iOS"
  s.version             = "NEW_VERSION_NUMBER"
  s.source              = { :http => "https://github.com/Azure/azure-notificationhubs-ios/releases/download/#{s.version}/WindowsAzureMessaging.framework.zip" }
  s.vendored_frameworks = "WindowsAzureMessaging.framework"
  s.platform            = :ios, "6.0"
  s.author              = { "Microsoft" => "http://microsoft.com" }
  s.documentation_url   = "https://docs.microsoft.com/en-us/azure/notification-hubs/"
  s.homepage            = "http://azure.microsoft.com/en-gb/services/notification-hubs/"
  s.requires_arc        = true
  s.summary             = "Push notifications for consumer and enterprise apps – from any backend to any device platform"
  s.description         = <<-DESC
Azure Notification Hubs provide an easy-to-use, multiplatform, scaled-out push infrastructure that enables you to send mobile push notifications from any backend (in the cloud or on-premises) to any mobile platform.
DESC
  s.license             = { :type => "MIT", :text => <<-LICENSE
MIT License

Copyright (c) Microsoft Corporation. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE
LICENSE
                          }
end
