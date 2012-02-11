require 'redmine'
require 'letter_eater/mailer_patch'

Redmine::Plugin.register :redmine_letter_eater do
  name 'Redmine Letter Eater plugin'
  author 'OZAWA Yasuhiro'
  description 'Setting deny and allow e-mails.'
  version '0.0.1'
  url 'https://github.com/ameya86/redmine_letter_eater'

  settings :partial => 'letter_eaters/settings',
    :default => {
      'deny' => nil,
      'allow' => nil
    }
end
