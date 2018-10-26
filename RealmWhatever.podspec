Pod::Spec.new do |s|
  s.name         = "RealmWhatever"
  s.version      = "0.0.4-alpha"
  s.summary      = "Persistence abstraction layer for Realm"
  s.description  = <<-EOS
  RealmWhatever abstracts persistence layer using Swift Generics to provide developers
  with more compile-time confidence.
  RxSwift extensions exist as well. Instructions for installation
  are in [the README](https://github.com/xquezme/RealmWhatever).
  EOS
  s.homepage     = "https://github.com/xquezme/RealmWhatever"
  s.license      = { :type => "MIT", :file => "License.md" }
  s.author       = { "Sergey Pimenov" => "pimenov.sergei@gmail.com" }
  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'
  s.source       = { :git => "https://github.com/xquezme/RealmWhatever.git", :tag => s.version }
  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files  = "RealmWhatever/Core", "RealmWhatever/Realm/Core"
    ss.dependency "RealmSwift", "~> 3.11"
    ss.framework  = "Foundation"
  end

  s.subspec "RxSwift" do |ss|
    ss.source_files = "RealmWhatever/Realm/Extensions/Rx", "RealmWhatever/Realm/Extensions/Shared"
    ss.dependency "RealmWhatever/Core"
    ss.dependency "RxSwift", "~> 4.3"
  end

  s.subspec "ReactiveSwift" do |ss|
    ss.source_files = "RealmWhatever/Realm/Extensions/Reactive", "RealmWhatever/Realm/Extensions/Shared"
    ss.dependency "RealmWhatever/Core"
    ss.dependency "ReactiveSwift", "~> 4.0"
  end
end
