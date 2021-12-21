defmodule NotionRenderer.Html do
  alias NotionRenderer.Config

  def blocks_to_html_string(blocks, opts \\ []) do
    opts = Keyword.put_new(opts, :config, NotionRenderer.Config.html())

    block_to_string(blocks, opts)
  end

  defp block_to_string(blocks, opts) when is_list(blocks) do
    {html, _opts} =
      Enum.reduce(blocks, {"", opts}, fn block, {html, opts} ->
        opts = set_list_context(opts, block["type"])
        html = html <> block_to_string(block, opts)

        {html, opts}
      end)

    html
  end

  defp block_to_string(block = %{"type" => type}, opts) do
    inner_block =
      case Map.fetch!(block, type) do
        # Notion sometimes wraps a block inside of a parent element. As far as I can tell, it's not used
        %{"text" => blocks} -> blocks
        leaf_block -> leaf_block
      end

    self_block_fn = fn blocks ->
      block_to_string(blocks, opts)
    end

    child_block_fn = fn _blocks ->
      # Some block types have captions. Those types shouldn't have children (in theory), so we will treat it as the child block
      caption =
        case block do
          %{^type => %{"caption" => caption}} -> caption
          _ -> []
        end

      children = Map.get(block, "_children", []) ++ caption

      child_opts = set_parent_list_context(opts)
      child_opts = Keyword.put(child_opts, :parent_block, block)
      block_to_string(children, child_opts)
    end

    next_block_fn = fn blocks ->
      self_block_fn.(blocks) <> child_block_fn.(blocks)
    end

    html =
      case Config.get_renderer(opts[:config], type) do
        nil ->
          "<!-- Renderer not provided: #{type} -->"

        render_fn ->
          opts = Keyword.put(opts, :full_block, block)
          render_fn.(inner_block, {next_block_fn, self_block_fn, child_block_fn}, opts)
      end

    maybe_apply_annotations(html, block, opts)
  end

  defp maybe_apply_annotations(html, %{"annotations" => annotations}, opts) do
    Enum.reduce(annotations, html, fn {type, value}, html ->
      case value do
        false ->
          html

        value ->
          annotation_fn = Config.get_annotation(opts[:config], type)
          annotation_fn.(html, value, opts)
      end
    end)
  end

  defp maybe_apply_annotations(html, _, _opts) do
    html
  end

  defp set_list_context(opts, type) do
    previous = Keyword.get(opts, :list_context)

    next_context =
      case {type, previous} do
        {nil, _} -> nil
        {type, {^type, order}} -> {type, order + 1}
        {type, _previous} -> {type, 1}
      end

    Keyword.put(opts, :list_context, next_context)
  end

  defp set_parent_list_context(opts) do
    Keyword.merge(opts, list_context: nil, parent_list_context: opts[:list_context])
  end
end
