module Propiary
  macro included
    Prop_Types = [] of {name: String, type: String}
  end


  macro getter(*names, &block)
    {% if block %}
      {% if names.size != 1 %}
        {{ raise "Only one argument can be passed to `getter` with a block" }}
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
        def {{name.id}}
          if (value = @{{name.id}}).nil?
            @{{name.id}} = {{yield}}
          else
            value
          end
        end
      {% end %}
    {% else %}
      {% for name in names %}
        {% if name.is_a?(TypeDeclaration) %}
          {% Prop_Types.push({name: name.var.stringify, type: name.type.stringify}) %}
          @{{name}}

          def {{name.var.id}} : {{name.type}}
            @{{name.var.id}}
          end
        {% elsif name.is_a?(Assign) %}
          @{{name}}

          def {{name.target.id}}
            @{{name.target.id}}
          end
        {% else %}
          def {{name.id}}
            @{{name.id}}
          end
        {% end %}
      {% end %}
    {% end %}
  end

  macro getter!(*names)
    {% for name in names %}
      {% if name.is_a?(TypeDeclaration) %}
        {% Prop_Types.push({name: name.var.stringify, type: "#{name.type}?"}) %}
        @{{name}}?
        {% name = name.var %}
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
        {{ raise "Only one argument can be passed to `getter?` with a block" }}
      {% end %}

      {% name = names[0] %}

      {% if name.is_a?(TypeDeclaration) %}
        {% Prop_Types.push({name: name.var.stringify, type: "#{name.type}?"}) %}
        @{{name.var.id}} : {{name.type}}?

        def {{name.var.id}}?
          if (value = @{{name.var.id}}).nil?
            @{{name.var.id}} = {{yield}}
          else
            value
          end
        end
      {% else %}
        def {{name.id}}?
          if (value = @{{name.id}}).nil?
            @{{name.id}} = {{yield}}
          else
            value
          end
        end
      {% end %}
    {% else %}
      {% for name in names %}
        {% if name.is_a?(TypeDeclaration) %}
          {% Prop_Types.push({name: name.var.stringify, type: name.type.stringify}) %}
          @{{name}}

          def {{name.var.id}}? : {{name.type}}
            @{{name.var.id}}
          end
        {% elsif name.is_a?(Assign) %}
          @{{name}}

          def {{name.target.id}}?
            @{{name.target.id}}
          end
        {% else %}
          def {{name.id}}?
            @{{name.id}}
          end
        {% end %}
      {% end %}
    {% end %}
  end

  macro setter(*names, withTrackedProp=true)
    {% for name in names %}
      {% if name.is_a?(TypeDeclaration) %}
        {% if withTrackedProp %}
          {% Prop_Types.push({name: name.var.stringify, type: name.type.stringify}) %}
        {% end %}
        @{{name}}

        def {{name.var.id}}=(@{{name.var.id}} : {{name.type}})
        end
      {% elsif name.is_a?(Assign) %}
        @{{name}}

        def {{name.target.id}}=(@{{name.target.id}})
        end
      {% else %}
        def {{name.id}}=(@{{name.id}})
        end
      {% end %}
    {% end %}
  end

  macro property(*names, &block)
    {% if block %}
      {% if names.size != 1 %}
        {{ raise "Only one argument can be passed to `property` with a block" }}
      {% end %}

      {% name = names[0] %}

      setter {{name}}, withTrackedProp: false

      {% if name.is_a?(TypeDeclaration) %}
        {% Prop_Types.push({name: name.var.stringify, type: "#{name.type}?"}) %}
        @{{name.var.id}} : {{name.type}}?

        def {{name.var.id}}
          if (value = @{{name.var.id}}).nil?
            @{{name.var.id}} = {{yield}}
          else
            value
          end
        end
      {% else %}
        def {{name.id}}
          if (value = @{{name.id}}).nil?
            @{{name.id}} = {{yield}}
          else
            value
          end
        end
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
        {% elsif name.is_a?(Assign) %}
          @{{name}}

          def {{name.target.id}}
            @{{name.target.id}}
          end

          def {{name.target.id}}=(@{{name.target.id}})
          end
        {% else %}
          def {{name.id}}
            @{{name.id}}
          end

          def {{name.id}}=(@{{name.id}})
          end
        {% end %}
      {% end %}
    {% end %}
  end

  macro property!(*names)
    # `getter!` handles setting Prop_Types
    getter! {{*names}}

    {% for name in names %}
      {% if name.is_a?(TypeDeclaration) %}
        def {{name.var.id}}=(@{{name.var.id}} : {{name.type}})
        end
      {% else %}
        def {{name.id}}=(@{{name.id}})
        end
      {% end %}
    {% end %}
  end

  macro property?(*names, &block)
    {% if block %}
      {% if names.size != 1 %}
        {{ raise "Only one argument can be passed to `property?` with a block" }}
      {% end %}

      {% name = names[0] %}

      {% if name.is_a?(TypeDeclaration) %}
        {% Prop_Types.push({name: name.var.stringify, type: "#{name.type}?"}) %}
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
        def {{name.id}}?
          if (value = @{{name.id}}).nil?
            @{{name.id}} = {{yield}}
          else
            value
          end
        end

        def {{name.id}}=(@{{name.id}})
        end
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
        {% elsif name.is_a?(Assign) %}
          @{{name}}

          def {{name.target.id}}?
            @{{name.target.id}}
          end

          def {{name.target.id}}=(@{{name.target.id}})
          end
        {% else %}
          def {{name.id}}?
            @{{name.id}}
          end

          def {{name.id}}=(@{{name.id}})
          end
        {% end %}
      {% end %}
    {% end %}
  end
end
