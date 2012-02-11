require_dependency 'mailer'

module LetterEaterMailerPatch
  def self.included(base)
    base.send(:include, LetterEaterMailerPatchMethod)

    base.class_eval do
      unloadable

      alias_method_chain :create_mail, :letter_eater
    end
  end
end

module LetterEaterMailerPatchMethod
  # Check deny and allow
  def create_mail_with_letter_eater
    @block_mails = []
    recipients.reject!{|mail| deny_or_allow(mail)}
    cc.reject!{|mail| deny_or_allow(mail)} if cc
    bcc.reject!{|mail| deny_or_allow(mail)} if bcc

    mylogger.info "Blocking email: #{@block_mails.join(', ')}" if mylogger && !@block_mails.empty?

    create_mail_without_letter_eater
  end

  def deny_or_allow(mail)
    deny = nil
    allow = nil

    # Deny
    unless deny_mail_address.empty?
      deny = deny_mail_address.detect{|deny| mail.match(deny)}
    end

    # Allow
    if !allow_mail_address.empty? && !deny
      allow = allow_mail_address.detect{|allow| mail.match(allow)}
    end

    if deny || !allow
      @block_mails << mail
      return true
    end

    return false
  end

  # Create deny list
  def deny_mail_address
    if @deny_mail_address.nil?
      if !Setting.plugin_redmine_letter_eater['deny'].empty?
        @deny_mail_address = Setting.plugin_redmine_letter_eater['deny'].split(/\r\n|\n/)
      else
        @deny_mail_address = []
      end
    end

    return @deny_mail_address
  end

  # Create allow list
  def allow_mail_address
    if @allow_mail_address.nil?
      if !Setting.plugin_redmine_letter_eater['allow'].empty?
      @allow_mail_address = Setting.plugin_redmine_letter_eater['allow'].split(/\r\n|\n/)
      else
        @allow_mail_address = []
      end
    end

    return @allow_mail_address
  end
end

Mailer.send(:include, LetterEaterMailerPatch)
