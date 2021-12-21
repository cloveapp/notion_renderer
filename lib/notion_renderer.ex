defmodule NotionRenderer do
  @moduledoc """
  TODO
  """

  def block_to_html(block, opts \\ []) do
    blocks = List.wrap(block)
    NotionRenderer.Html.blocks_to_html_string(blocks, opts)
  end
end
