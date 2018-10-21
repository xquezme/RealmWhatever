platform :ios, '9.0'

use_frameworks!
inhibit_all_warnings!

workspace 'RealmWhatever'
project 'RealmWhatever'

target 'RealmWhatever' do
  # Realm
  pod 'RealmSwift', '3.11.1'

  # Rx
  pod 'RxSwift', '4.3.1'

  # Reactive
  pod 'ReactiveSwift', '4.0.0'

  target 'RealmWhateverTests' do
    inherit! :search_paths
    pod 'Nimble', '7.3.1'
    pod 'Quick', '1.3.2'
  end
end
