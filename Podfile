platform :ios, '9.0'

use_frameworks!
inhibit_all_warnings!

workspace 'RealmWhatever'
project 'RealmWhatever'

target 'RealmWhatever' do
  # Realm
  pod 'RealmSwift', '5.0.0-beta.2'

  # Rx
  pod 'RxSwift', '5.0.1'

  # Reactive
  pod 'ReactiveSwift', '6.2.0'

  target 'RealmWhateverTests' do
    inherit! :search_paths
    pod 'Nimble', '8.0.5'
    pod 'Quick', '2.1.0'
  end

  script_phase :name => 'SwiftFormat', :execution_position => :before_compile, :script =>
  <<-HEREDOC
  if which swiftformat >/dev/null; then
    swiftformat --swiftversion 5.0 --disable redundantSelf ./RealmWhatever
  else
    echo "warning: SwiftFormat not installed, download it from https://github.com/nicklockwood/SwiftFormat"
  fi
  HEREDOC
end
