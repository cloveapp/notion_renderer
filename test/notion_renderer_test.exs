defmodule NotionRendererTest do
  use ExUnit.Case

  # See the HTML test for more in-depth testing
  test "html is rendered" do
    blocks =
      File.read!("test/examples/blocks/embed-your-hub-3906e00d-c0b7-4bc9-980e-4ecba51a0438.json")
      |> Jason.decode!()

    assert is_list(blocks)
    html = NotionRenderer.block_to_html(blocks)
    assert String.length(html) > 1000
  end

  test "a page title can be rendered" do
    title = File.read!("test/examples/blocks/title.json") |> Jason.decode!()

    assert is_map(title)
    assert NotionRenderer.block_to_html(title) == "Product Knowledge Base"
  end
end
