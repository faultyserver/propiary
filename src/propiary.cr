abstract class Object
  macro inherited
    Prop_Types = [] of {name: String, type: String}
  end


  macro getter(*names, &block)
    {% if block %}
      {% if names.size != 1 %}
        {{ raise "[Using Propiary]: Only one argument can be passed to `getter` with a block" }}
      {% end %}

      {% name = names[0] %}

      {% if name.is_a?(TypeDeclaration) %}
        {% Prop_Types.push({name: name.var.stringify, type: name.type.stringify}) %}
        @{{name.var.id}} : {{name.type}}?

        def {{name.var.id}}
          if (value = @{{name.var.id}}).nil?
            @{{name.var.id}} = {{yield}}
          else
            value
          end
        end
      {% else %}
        {{ raise "[Using Propiary]: names given to `getter` must be type declarations (e.g. `name : String`)" }}
      {% end %}
    {% else %}
      {% for name in names %}
        {% if name.is_a?(TypeDeclaration) %}
          {% Prop_Types.push({name: name.var.stringify, type: name.type.stringify}) %}
          @{{name}}

          def {{name.var.id}} : {{name.type}}
            @{{name.var.id}}
          end
        {% else %}
          {{ raise "[Using Propiary]: names given to `getter` must be type declarations (e.g. `name : String`)" }}
        {% end %}
      {% end %}
    {% end %}
  end

  macro getter!(*names)
    {% for name in names %}
      {% if name.is_a?(TypeDeclaration) %}
        {% Prop_Types.push({name: name.var.stringify, type: name.type.stringify}) %}
        @{{name}}?
        {% name = name.var %}
      {% else %}
        {{ raise "[Using Propiary]: names given to `getter!` must be type declarations (e.g. `name : String`)" }}
      {% end %}

      def {{name.id}}?
        @{{name.id}}
      end

      def {{name.id}}
        @{{name.id}}.not_nil!
      end
    {% end %}
  end

  macro getter?(*names, &block)
    {% if block %}
      {% if names.size != 1 %}
        {{ raise "[Using Propiary]: Only one argument can be passed to `getter?` with a block" }}
      {% end %}

      {% name = names[0] %}

      {% if name.is_a?(TypeDeclaration) %}
        {% Prop_Types.push({name: name.var.stringify, type: name.type.stringify}) %}
        @{{name.var.id}} : {{name.type}}?

        def {{name.var.id}}?
          if (value = @{{name.var.id}}).nil?
            @{{name.var.id}} = {{yield}}
          else
            value
          end
        end
      {% else %}
        {{ raise "[Using Propiary]: names given to `getter?` must be type declarations (e.g. `name : String`)" }}
      {% end %}
    {% else %}
      {% for name in names %}
        {% if name.is_a?(TypeDeclaration) %}
          {% Prop_Types.push({name: name.var.stringify, type: name.type.stringify}) %}
          @{{name}}

          def {{name.var.id}}? : {{name.type}}
            @{{name.var.id}}
          end
        {% else %}
          {{ raise "[Using Propiary]: names given to `getter?` must be type declarations (e.g. `name : String`)" }}
        {% end %}
      {% end %}
    {% end %}
  end

  macro setter(*names)
    {% for name in names %}
      {% if name.is_a?(TypeDeclaration) %}
        {% Prop_Types.push({name: name.var.stringify, type: name.type.stringify}) %}
        @{{name}}

        def {{name.var.id}}=(@{{name.var.id}} : {{name.type}})
        end
      {% else %}
        {{ raise "[Using Propiary]: names given to `setter` must be type declarations (e.g. `name : String`)" }}
      {% end %}
    {% end %}
  end

  macro property(*names, &block)
    {% if block %}
      {% if names.size != 1 %}
        {{ raise "[Using Propiary]: Only one argument can be passed to `property` with a block" }}
      {% end %}

      {% name = names[0] %}

      setter {{name}}

      {% if name.is_a?(TypeDeclaration) %}
        {% Prop_Types.push({name: name.var.stringify, type: name.type.stringify}) %}
        @{{name.var.id}} : {{name.type}}?

        def {{name.var.id}}
          if (value = @{{name.var.id}}).nil?
            @{{name.var.id}} = {{yield}}
          else
            value
          end
        end
      {% else %}
        {{ raise "[Using Propiary]: names given to `property` must be type declarations (e.g. `name : String`)" }}
      {% end %}
    {% else %}
      {% for name in names %}
        {% if name.is_a?(TypeDeclaration) %}
          {% Prop_Types.push({name: name.var.stringify, type: name.type.stringify}) %}
          @{{name}}

          def {{name.var.id}} : {{name.type}}
            @{{name.var.id}}
          end

          def {{name.var.id}}=(@{{name.var.id}} : {{name.type}})
          end
        {% else %}
          {{ raise "[Using Propiary]: names given to `property` must be type declarations (e.g. `name : String`)" }}
        {% end %}
      {% end %}
    {% end %}
  end

  macro property!(*names)
    getter! {{*names}}

    {% for name in names %}
      {% if name.is_a?(TypeDeclaration) %}
        {% Prop_Types.push({name: name.var.stringify, type: name.type.stringify}) %}
        def {{name.var.id}}=(@{{name.var.id}} : {{name.type}})
        end
      {% else %}
        {{ raise "[Using Propiary]: names given to `property!` must be type declarations (e.g. `name : String`)" }}
      {% end %}
    {% end %}
  end

  macro property?(*names, &block)
    {% if block %}
      {% if names.size != 1 %}
        {{ raise "[Using Propiary]: Only one argument can be passed to `property?` with a block" }}
      {% end %}

      {% name = names[0] %}

      {% if name.is_a?(TypeDeclaration) %}
        {% Prop_Types.push({name: name.var.stringify, type: name.type.stringify}) %}
        @{{name.var.id}} : {{name.type}}?

        def {{name.var.id}}?
          if (value = @{{name.var.id}}).nil?
            @{{name.var.id}} = {{yield}}
          else
            value
          end
        end

        def {{name.var.id}}=(@{{name.var.id}} : {{name.type}})
        end
      {% else %}
        {{ raise "[Using Propiary]: names given to `property?` must be type declarations (e.g. `name : String`)" }}
      {% end %}
    {% else %}
      {% for name in names %}
        {% if name.is_a?(TypeDeclaration) %}
          {% Prop_Types.push({name: name.var.stringify, type: name.type.stringify}) %}
          @{{name}}

          def {{name.var.id}}? : {{name.type}}
            @{{name.var.id}}
          end

          def {{name.var.id}}=(@{{name.var.id}} : {{name.type}})
          end
        {% else %}
          {{ raise "[Using Propiary]: names given to `property?` must be type declarations (e.g. `name : String`)" }}
        {% end %}
      {% end %}
    {% end %}
  end
end
