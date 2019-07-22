platform :ios, '9.0'

use_frameworks!
inhibit_all_warnings!

workspace 'RealmWhatever'
project 'RealmWhatever'

target 'RealmWhatever' do
  # Realm
  pod 'RealmSwift', '3.17.1'

  # Rx
  pod 'RxSwift', '5.0.0'

  # Reactive
  pod 'ReactiveSwift', '6.0.0'

  target 'RealmWhateverTests' do
    inherit! :search_paths
    pod 'Nimble', '8.0.2'
    pod 'Quick', '2.1.0'
  end
end
