class GraceLetter
  # Grace letters are currently part of the CommunicationOnProgress table
  # this class is currently just a collection of class methods to consolidate grace
  # letter concerns. This may become it's own active record class in the future.

  TYPE = CopFile::TYPES[:grace_letter]

  def self.new(params={})
    CommunicationOnProgress.new(DEFAULTS.merge(params))
  end

  def self.create(params={})
    CommunicationOnProgress.create(DEFAULTS.merge(params))
  end

  def self.create!(params={})
    CommunicationOnProgress.create!(DEFAULTS.merge(params))
  end

  def self.find(id)
    grace_letters.find(id)
  end

  private

    def self.grace_letters
      CommunicationOnProgress.where(format:TYPE)
    end

    DEFAULTS = {
      format: TYPE,
      title: 'Grace Letter',
      cop_type: 'grace'
    }

end