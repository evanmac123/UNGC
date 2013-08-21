module PrinciplesHelper

  def principle_checkbox(prefix, topic, selected_topics_ids=[])
    html = check_box_tag "#{prefix}[principle_ids][]", topic.id, selected_topics_ids.include?(topic.id), :id => "#{prefix}_checkbox_#{topic.id}"
    html += content_tag(:label, topic.name, :style => "width: auto;", :for => "#{prefix}_checkbox_#{topic.id}")
  end
end
