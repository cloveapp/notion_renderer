defmodule NotionRenderer.Config do
  alias NotionRenderer.Html.DefaultRenderer

  @enforce_keys [
    :annotations,
    :renderers
  ]

  defstruct @enforce_keys

  def html do
    %__MODULE__{
      annotations: %{
        "bold" => &DefaultRenderer.annotation_bold/3,
        "code" => &DefaultRenderer.annotation_code/3,
        "color" => &DefaultRenderer.annotation_color/3,
        "italic" => &DefaultRenderer.annotation_italic/3,
        "strikethrough" => &DefaultRenderer.annotation_strikethrough/3,
        "underline" => &DefaultRenderer.annotation_underline/3
      },
      renderers: %{
        "paragraph" => &DefaultRenderer.paragraph/3,
        "heading_1" => &DefaultRenderer.heading_1/3,
        "heading_2" => &DefaultRenderer.heading_2/3,
        "heading_3" => &DefaultRenderer.heading_3/3,
        "bulleted_list_item" => &DefaultRenderer.bulleted_list_item/3,
        "numbered_list_item" => &DefaultRenderer.numbered_list_item/3,
        "to_do" => &DefaultRenderer.bulleted_list_item/3,
        "toggle" => &DefaultRenderer.toggle/3,
        "embed" => &DefaultRenderer.embed/3,
        "image" => &DefaultRenderer.image/3,
        "video" => &DefaultRenderer.video/3,
        "file" => &DefaultRenderer.file/3,
        "pdf" => &DefaultRenderer.pdf/3,
        "callout" => &DefaultRenderer.callout/3,
        "quote" => &DefaultRenderer.quote/3,
        "divider" => &DefaultRenderer.divider/3,
        "synced_block" => &DefaultRenderer.synced_block/3,
        "title" => &DefaultRenderer.title/3,
        # Text node types
        "equation" => &DefaultRenderer.equation/3,
        "mention" => &DefaultRenderer.mention/3,
        "text" => &DefaultRenderer.text/3
      }
    }
  end

  def get_renderer(%{renderers: renderers}, type) do
    Map.get(renderers, type)
  end

  def get_annotation(%{annotations: annotations}, type) do
    Map.get(annotations, type)
  end
end
