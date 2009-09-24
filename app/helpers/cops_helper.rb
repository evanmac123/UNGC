module CopsHelper
  def count_all_cops(filter_type=nil)
    234124
  end
  
  def paged_cops(filter_type=nil)
    CommunicationOnProgress.for_filter(filter_type)
  end
end
