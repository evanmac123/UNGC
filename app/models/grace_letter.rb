class GraceLetter
  # Grace letters are currently part of the CommunicationOnProgress table
  # this class is currently just a collection of class methods to consolidate grace
  # letter concerns. This may become it's own active record class in the future.

  def self.new(params={})
    CommunicationOnProgress.new(DEFAULTS.merge(params))
  end

  private

    DEFAULTS = {
      format: CopFile::TYPES[:grace_letter],
      title: 'Grace Letter',
    }

end