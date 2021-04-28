#
#  Be sure to run `pod spec lint SwiftPurchase.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "SwiftPurchase"
  spec.version      = "0.0.7"
  spec.summary      = "SwiftPurchase 是针对iOS内购写的一个工具类"
  spec.description  = <<-DESC
                         包含了获取产品列表，购买，restore，获取验证receipt
                      DESC
  spec.homepage     = "https://github.com/LqDeveloper/SwiftPurchase"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Quan Li" => "1083099465@qq.com" }
  spec.platform     = :ios, "9.0"
  spec.requires_arc = true
  spec.swift_version = '5.0'
  spec.default_subspec = 'Core'
  spec.cocoapods_version = '>= 1.4.0' 
  spec.source       = { :git => "https://github.com/LqDeveloper/SwiftPurchase.git", :tag => "#{spec.version}" }


  spec.subspec  'Core' do |sub|
    sub.source_files  = "SwiftPurchase/Core/**/*.swift"
    sub.frameworks  = "Foundation","StoreKit"
  end

  spec.subspec 'RxSwift' do |sub|
    sub.source_files  = "SwiftPurchase/RxSwiftExtensions/**/*.swift"
    sub.dependency "SwiftPurchase/Core"
    sub.dependency "RxSwift", "~> 5.0"
    sub.dependency "RxCocoa", "~> 5.0"
  end
end
