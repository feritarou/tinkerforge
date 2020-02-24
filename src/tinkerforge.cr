require "./bindings/**"

# Crystal wrappers for easy access to TinkerForge components
module TF
end

require "./**"

{% if flag? "libtest-tinkerforge" %}
require "../test"
{% end %}
