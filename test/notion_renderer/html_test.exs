defmodule NotionRenderer.HtmlTest do
  use ExUnit.Case

  alias NotionRenderer.Html

  test "integration page with many types of content" do
    blocks =
      File.read!("test/examples/blocks/embed-your-hub-3906e00d-c0b7-4bc9-980e-4ecba51a0438.json")
      |> Jason.decode!()

    html = Html.blocks_to_html_string(blocks)

    not_supported = Regex.scan(~r/Renderer not provided: ([^\s]+)/, html)

    assert Enum.map(not_supported, &List.last(&1)) |> Enum.uniq() |> Enum.sort() == [
             "link_to_page",
             "table_of_contents",
             "unsupported"
           ]

    # Colored paragraph
    assert html =~ ~S(<span style="color: #0B6E99;" data-notion-color="blue">)

    # Mention
    assert html =~ ~S(<p >@Stephen Bussey mention</p>)

    # Inline equation
    assert html =~ ~S(<span data-equation="E = m&quot;c^2">E = m&quot;c^2</span>)

    # Ordered list with multiple entries
    assert html =~
             ~S(<ol type="1" start="1"><li>Insert <code>&lt;iframe&gt;</code> into your product</li></ol>)

    assert html =~ ~S(<ol type="1" start="2"><li>Include and initialize clove-embed.js</li></ol>)
    assert html =~ ~S(<ol type="1" start="3">)

    # Ordered list nested
    assert html =~ ~S(<ol type="a" start="2"><li>And item B</li></ol>)

    # Toggle
    assert html =~
             ~S(<details><summary>Toggle list</summary><p >Here’s a block inside of the toggle</p></details>)

    # TODO Item
    assert html =~ ~S(<ul><li>Todo 1</li></ul>)

    # Callout
    assert html =~
             ~S(<figure class="notion-callout"><div class="notion-callout-icon">🔥</div><div class="notion-callout-content">Nice, a callout!<br />Multiple lines</div></figure>)

    # Header
    assert html =~ ~S(<h2>Embed IFrame + JS</h2>)

    # Embedded gist
    assert html =~
             ~S(<figure class="notion-embed"><div class="notion-source"><a href="https://gist.github.com/sb8244/f97f43570643a84860f54502d91b7eec">https://gist.github.com/sb8244/f97f43570643a84860f54502d91b7eec</a></div><figcaption class="notion-caption">Here’s a caption</figcaption></figure>)

    # Embedded PDF (source removed because it's dynamic)
    assert html =~
             ~r(<figure class="notion-pdf"><div class="notion-source"><a href=".+">.+<\/a><\/div><\/figure>)

    # Link to another page
    assert html =~
             ~S(<p ><a href="/8995655e8e7d40d6a6b40f3c66fef8c1">Link to another page</a></p>)
  end

  test "a title can be rendered" do
    block = File.read!("test/examples/blocks/title.json") |> Jason.decode!()

    assert Html.blocks_to_html_string([block]) == "Product Knowledge Base"
  end

  # Link rewriting is useful if you mirror pages in Notion to your application. For example, you can detect
  # a url like /UUID-MINUS-DASHES and check to see if that ID is in your page set. If so, handle it as a
  # special link.
  test "links can be rewritten" do
    blocks =
      File.read!("test/examples/blocks/embed-your-hub-3906e00d-c0b7-4bc9-980e-4ecba51a0438.json")
      |> Jason.decode!()

    rewrite = fn href ->
      new_href = "#{:erlang.unique_integer()}_rewritten"
      send(self(), {:rewrite, href, new_href})
      new_href
    end

    html = Html.blocks_to_html_string(blocks, link_rewriter: rewrite)

    assert_received {:rewrite,
                     "https://gist.github.com/sb8244/f97f43570643a84860f54502d91b7eec?embed=1",
                     replacement}

    assert String.contains?(html, replacement)

    assert_received {:rewrite,
                     "https://gist.github.com/sb8244/89a05c17d4485547be0fc095c43e3567?embed=1",
                     replacement}

    assert String.contains?(html, replacement)

    assert_received {:rewrite,
                     "https://gist.github.com/sb8244/6d9657b0ed9cd5df576eb4447313e614?embed=1",
                     replacement}

    assert String.contains?(html, replacement)

    assert_received {:rewrite, "/8995655e8e7d40d6a6b40f3c66fef8c1", replacement}
    assert String.contains?(html, replacement)
  end
end
