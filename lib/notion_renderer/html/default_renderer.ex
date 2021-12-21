defmodule NotionRenderer.Html.DefaultRenderer do
  # Blocks

  def paragraph(block, {next, _self, _child}, opts) do
    class =
      case opts[:parent_block] do
        %{"type" => "paragraph"} -> "class=\"notion-indented\""
        _ -> ""
      end

    "<p #{class}>#{next.(block)}</p>"
  end

  def numbered_list_item(block, {next, _self, _child}, opts) do
    start =
      case opts[:list_context] do
        {"numbered_list_item", start} -> start
        _ -> 1
      end

    type =
      case opts[:parent_list_context] do
        {"numbered_list_item", _} -> "a"
        _ -> "1"
      end

    "<ol type=\"#{type}\" start=\"#{start}\"><li>#{next.(block)}</li></ol>"
  end

  def bulleted_list_item(block, {next, _self, _child}, _opts) do
    "<ul><li>#{next.(block)}</li></ul>"
  end

  def toggle(block, {_next, self, child}, _opts) do
    "<details><summary>#{self.(block)}</summary>#{child.(block)}</details>"
  end

  def quote(block, {next, _self, _child}, _opts) do
    "<blockquote>#{next.(block)}</blockquote>"
  end

  def callout(block, {next, _self, _child}, opts) do
    full_block = Keyword.fetch!(opts, :full_block)
    # TODO: There's different icon types
    icon = full_block["callout"]["icon"]["emoji"]

    "<figure class=\"notion-callout\"><div class=\"notion-callout-icon\">#{icon}</div><div class=\"notion-callout-content\">#{next.(block)}</div></figure>"
  end

  def heading_1(block, {next, _self, _child}, _opts) do
    "<h1>#{next.(block)}</h1>"
  end

  def heading_2(block, {next, _self, _child}, _opts) do
    "<h2>#{next.(block)}</h2>"
  end

  def heading_3(block, {next, _self, _child}, _opts) do
    "<h3>#{next.(block)}</h3>"
  end

  def divider(_block, _next_fns, _opts) do
    "<hr>"
  end

  def synced_block(block, {_next, _self, child}, _opts) do
    child.(block)
  end

  def embed(block, {_next, _self, caption}, opts) do
    full_block = Keyword.fetch!(opts, :full_block)
    url = full_block["embed"]["url"]
    no_params = URI.parse(url) |> Map.put(:query, nil) |> URI.to_string()

    content = "<div class=\"notion-source\"><a href=\"#{url}\">#{no_params}</a></div>"

    caption_content =
      case caption.(block) do
        "" -> ""
        caption -> "<figcaption class=\"notion-caption\">#{caption}</figcaption>"
      end

    "<figure class=\"notion-embed\">#{content}#{caption_content}</figure>"
  end

  def file(block, {_next, _self, caption}, opts) do
    full_block = Keyword.fetch!(opts, :full_block)
    url = file_url(full_block["file"])
    no_params = URI.parse(url) |> Map.put(:query, nil) |> URI.to_string()

    content = "<div class=\"notion-source\"><a href=\"#{url}\">#{no_params}</a></div>"

    caption_content =
      case caption.(block) do
        "" -> ""
        caption -> "<figcaption class=\"notion-caption\">#{caption}</figcaption>"
      end

    "<figure class=\"notion-file\">#{content}#{caption_content}</figure>"
  end

  def pdf(block, {_next, _self, caption}, opts) do
    full_block = Keyword.fetch!(opts, :full_block)
    url = file_url(full_block["pdf"])
    no_params = URI.parse(url) |> Map.put(:query, nil) |> URI.to_string()

    content = "<div class=\"notion-source\"><a href=\"#{url}\">#{no_params}</a></div>"

    caption_content =
      case caption.(block) do
        "" -> ""
        caption -> "<figcaption class=\"notion-caption\">#{caption}</figcaption>"
      end

    "<figure class=\"notion-pdf\">#{content}#{caption_content}</figure>"
  end

  def image(block, {_next, _self, caption}, opts) do
    full_block = Keyword.fetch!(opts, :full_block)
    url = file_url(full_block["image"])

    content = "<img src=\"#{url}\" />"

    caption_content =
      case caption.(block) do
        "" -> ""
        caption -> "<figcaption class=\"notion-caption\">#{caption}</figcaption>"
      end

    "<figure class=\"notion-image\">#{content}#{caption_content}</figure>"
  end

  def video(block, {_next, _self, caption}, opts) do
    full_block = Keyword.fetch!(opts, :full_block)
    url = file_url(full_block["video"])

    content = NotionRenderer.Html.VideoEmbed.embed_code_for(url)

    caption_content =
      case caption.(block) do
        "" -> ""
        caption -> "<figcaption class=\"notion-caption\">#{caption}</figcaption>"
      end

    "<figure class=\"notion-video\">#{content}#{caption_content}</figure>"
  end

  def title(block, {next, _, _}, _opts) do
    next.(block)
  end

  def text(block, _fns, opts) do
    text =
      block["content"]
      |> NotionRenderer.HtmlEscape.html_escape()
      |> String.replace("\n", "<br />")

    case block["link"] do
      nil ->
        text

      %{"url" => href} ->
        href =
          case Keyword.get(opts, :link_rewriter) do
            nil -> href
            rewrite -> rewrite.(href)
          end

        "<a href=\"#{href}\">#{text}</a>"
    end
  end

  def equation(block, _fns, opts) do
    # Notion uses LaTeX for its equation rendering, via KaTeX library
    # Hook into data-equation to enhance equations
    full_block = Keyword.fetch!(opts, :full_block)
    text = full_block["plain_text"] |> NotionRenderer.HtmlEscape.html_escape()
    expression = block["expression"] |> NotionRenderer.HtmlEscape.html_escape()

    "<span data-equation=\"#{expression}\">#{text}</span>"
  end

  def mention(_block, _fns, opts) do
    # Mentions are completely ignored because we are outside of the notion context
    # This requires accessing the full block to get the parent attribute
    block = Keyword.fetch!(opts, :full_block)
    block["plain_text"]
  end

  # Annotations

  def annotation_bold(value, true, _opts) do
    "<b>#{value}</b>"
  end

  def annotation_code(value, true, _opts) do
    "<code>#{value}</code>"
  end

  def annotation_color(value, color, _opts) do
    style =
      case color do
        "default" -> nil
        "gray" -> "color: #9B9A97;"
        "gray_background" -> "background-color: #EBECED;"
        "brown" -> "color: #64473A;"
        "brown_background" -> "background-color: #E9E5E3;"
        "orange" -> "color: #D9730D;"
        "orange_background" -> "background-color: #FAEBDD;"
        "yellow" -> "color: #DFAB01;"
        "yellow_background" -> "background-color: #FBF3DB;"
        "green" -> "color: #0F7B6C;"
        "green_background" -> "background-color: #DDEDEA;"
        "blue" -> "color: #0B6E99;"
        "blue_background" -> "background-color: #DDEBF1;"
        "purple" -> "color: #6940A5;"
        "purple_background" -> "background-color: #EAE4F2;"
        "pink" -> "color: #AD1A72;"
        "pink_background" -> "background-color: #F4DFEB;"
        "red" -> "color: #E03E3E;"
        "red_background" -> "background-color: #FBE4E4;"
        _ -> nil
      end

    if style do
      "<span style=\"#{style}\" data-notion-color=\"#{color}\">#{value}</span>"
    else
      value
    end
  end

  def annotation_italic(value, true, _opts) do
    "<i>#{value}</i>"
  end

  def annotation_strikethrough(value, true, _opts) do
    "<span style=\"text-decoration: line-through;\">#{value}</span>"
  end

  def annotation_underline(value, true, _opts) do
    "<u>#{value}</u>"
  end

  defp file_url(%{"file" => %{"url" => url}}), do: url
  defp file_url(%{"external" => %{"url" => url}}), do: url
  defp file_url(_), do: nil
end
