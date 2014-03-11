Pod::Spec.new do |s|
  s.name         = "PLPartyTime"
  s.version      = "0.0.1"
  s.summary      = "A light wrapper around MultiPeer connectivity framework which allows apps to quickly connect people without invitations."

  s.description  = <<-DESC
                   Instead of dealing with the complexity of MultiPeer connectivity, use this simple API:
                   PLPartyTime *partyTime = [[PLPartyTime alloc] initWithServiceType:@"appServiceType”];
                   [partyTime joinParty];

                   It will automatically join any other app on the same service type. It will then call appropriate delegate methods with updates.
                   DESC

  s.homepage     = "https://github.com/plivesey/PLPartyTime"
  s.license = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "Peter Livesey" => "plivesey453@gmail.com" }

  s.platform     = :ios, '7.0'

  s.source       = { :git => "https://github.com/plivesey/PLPartyTime.git", :tag => "0.0.1" }

  s.source_files  = 'PLPartyTime',
  # s.public_header_files = 'Classes/**/*.h'

  s.framework  = 'MultipeerConnectivity'

  s.requires_arc = true

end
