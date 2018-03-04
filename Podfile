platform :ios, '9.0'

use_frameworks!
inhibit_all_warnings!

workspace 'RealmWhatever'
project 'RealmWhatever'

target 'RealmWhatever' do
  pod 'RealmSwift', '3.1.0'
  pod 'RxSwift', '4.1.0'
  
  target 'RealmWhateverTests' do
    inherit! :search_paths
    pod 'Nimble', '7.0.3'
    pod 'Quick', '1.2.0'
  end
end
