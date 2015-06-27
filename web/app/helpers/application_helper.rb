module ApplicationHelper
  def menu_item(controller, action, text)
    li_class =
      current_page?(controller: controller, action: action) ? :active : nil
    content_tag :li, class: li_class do
      content_tag :a, href: url_for(controller: controller, action: action) do
        text
      end
    end
  end
end
