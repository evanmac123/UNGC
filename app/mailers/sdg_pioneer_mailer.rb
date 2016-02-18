class SdgPioneerMailer < ApplicationMailer

  def nomination_submitted(other_id)
    @other = SdgPioneer::Other.find(other_id)

    mail to: 'sdgpioneers@unglobalcompact.org',
         subject: 'A SDG Pioneer nomination was received'
  end

end
