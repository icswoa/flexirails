# Flexirails

ORM independent table view for Ruby on Rails.
Has support for partial rendering, turbolinks and i18n as well as basic sorting and filtering facilities.
If you want more abstraction you need to build it yourself.

Look at the bright side: want to use bananadb? Go ahead.<br>
Just wrote your self CSV-In-Memory-DB? No Problem.<br>
Reading each row from /dev/null. Sure, why not?

You are in control. Just need to know how!

### Installation

Add `gem "flexirails"` to your `Gemfile`.

### Usage

Now you need two more steps to get going:

1. subclass `::Flexirails::View` or `::Flexirails::ArrayView`.

    ``` ruby
    class PeopleView < ::Flexirails::View
      def total
        Person.count
      end

      def query offset, limit
        Person.offset(offset).limit(limit)
      end

      def columns
        %w(id name)
      end
    end
    ```

2. instanciate your view class in your controller:

    ``` ruby
    class PeopleController < ApplicationController
      protected
      def people_view
        @people_view ||= PeopleView.new(params)
      end
      helper_method :people_view
    end
    ```

3. render appropriate partials in your views:

    ``` erb
    <%= render :partial => '/flexirails/navigation', :locals => { :view => people_view } %>
    <%= render_flexirails_view(people_view, { :class => 'statics' }) %>
    ```

Columns are translated as `<lang>.<view_as_snake_case>.<column>`, e.g. `de.people_view.name`.

### Advanced Usage

You can pass additional informations to your view - e.g. the current user for complex logic

``` ruby
class PeopleView < ::Flexirails::View
  attr_reader :current_user, :current_project
  def initialize params, user, project
    @current_user = user
    @current_project = project
    super params
  end

  def scoped
    if current_user.admin?
      Person.scoped
    else
      current_project.people
    end
  end

  def total
    scoped.count
  end

  def query offset, limit
    scoped.offset(offset).limit(limit)
  end
end
```

By default attributes are extracted from the current row object. But you can render partials if you want to:
``` ruby
class PeopleView < ::Flexirails::View
  def total
    Person.count
  end

  def query offset, limit
    Person.offset(offset).limit(limit)
  end

  def columns
    %w(id name actions)
  end

  def render_actions person, context
    context.render :partial => "actions", :locals => { :person => person }
  end
end
```

You can sort your data if you want to. `order` and `direction` are sanitized by default, no need to check.
``` ruby
class PeopleView < ::Flexirails::View
  def query offset, limit
    scope = if order_query?
      Person.order("#{order} #{direction}")
    else
      Person
    end
    scope.offset(offset).limit(limit)
  end

  def sortable_columns
    %w(id)
  end
end
```

You can filter your data if you want to:
``` ruby
class PeopleView < ::Flexirails::View
  attr_reader :minimum_id
  def initialize params
    @minimum_id = params.fetch(:minimum_id, nil)

    super params
  end

  def scoped
    if minimum_id.present?
      Person.where(["id > ?", minimum_id])
    else
      Person.scoped
    end
  end

  def total
    scoped.count
  end

  def query offset, limit
    scoped.offset(offset).limit(limit)
  end
end
```

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request