module FlexirailsHelper
  def pagination_first_icon
    return '<svg version="1.2" baseProfile="tiny" id="Navigation_first" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="16px" height="16px" viewBox="0 0 512 512" overflow="inherit" xml:space="preserve"> <path d="M186.178,256.243l211.583,166.934V89.312L186.178,256.243z M112.352,422.512h66.179V89.975h-66.179V422.512z"/> </svg>'
  end
  def pagination_prev_icon
    return '<svg version="1.2" baseProfile="tiny" id="Navigation_left" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="16px" height="16px" viewBox="0 0 512 512" overflow="inherit" xml:space="preserve"> <polygon points="148.584,255.516 360.168,88.583 360.166,422.445 "/> </svg>'
  end
  def pagination_last_icon
    return '<svg version="1.2" baseProfile="tiny" id="Navigation_last" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="16px" height="16px" viewBox="0 0 512 512" overflow="inherit" xml:space="preserve"> <path d="M111.708,424.514l211.581-166.927L111.708,90.654V424.514z M330.935,87.311v332.544h66.173V87.311H330.935z"/> </svg>'
  end
  def pagination_next_icon
    return '<svg version="1.2" baseProfile="tiny" id="Navigation_right" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="16px" height="16px" viewBox="0 0 512 512" overflow="inherit" xml:space="preserve"> <polygon points="360.124,255.513 148.535,422.442 148.537,88.58 "/> </svg>'
  end
  def render_flexirails_view view
    return render partial: '/flexirails/container', locals: { view: view }
  end

  def adjust_path key_path, value = nil
    key_path = key_path.split('.')
    key = key_path[-1]

    scopes = []
    scope = Hash.new(request.query_parameters)

    key_path[0..-2].each do |part|
      scopes << scope
      scope = scope.fetch(part) { Hash.new }
    end

    if value.nil?
      scope.delete key
    else
      scope[key] = value
    end

    key_path[0..-2].reverse.each_with_index do |part|
      parent = scopes.pop
      parent[part] = scope
      scope = parent
    end

    scope
  end
end