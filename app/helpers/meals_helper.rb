module MealsHelper

  def meal_photo(meal)
    content_tag(:div, class: "meal-photo") do
      image_tag(meal.photo, id: "photo") << meal_photo_credit(meal)
    end
  end

  def meal_photo_credit(meal)
    if meal.photo_credit.blank?
      ""
    else
      linked = meal.photo_credit.gsub(%r{(https?://[^ ]+)}){ link_to("Link", $1) }.html_safe
      content_tag(:div, linked, class: "credit")
    end
  end

end