module ApplicationHelper

  def javascript_doc_ready(&block)
    content = capture(&block)
    javascript_tag("jQuery(document).ready(function(){#{content}});")
  end


  def bootstrap_class_for(flash_type)
    case flash_type
      when "success"
        "alert-success"   # Green
      when "error"
        "alert-danger"    # Red
      when "alert"
        "alert-warning"   # Yellow
      when "notice"
        "alert-info"      # Blue
      else
        "alert-danger"
    end
  end

end
