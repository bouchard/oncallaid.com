# TODO: Remove this once they fix the ticket:
# https://github.com/josevalim/active_model_serializers/pull/78
ActiveModel::Serializer.root false

module ActionController::Serialization
  def _render_option_json_with_root_false(json, options)
    _render_option_json_without_root_false(json, options.merge(root: false))
  end
  alias_method_chain :_render_option_json, :root_false
end