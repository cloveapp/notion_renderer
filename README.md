# NotionRenderer

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `notion_renderer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:notion_renderer, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/notion_renderer](https://hexdocs.pm/notion_renderer).

## Dimensions

Notion's API does not provide any dimensional information. So if a video or image has been resized, then there
is no access to that in the API. So, it will be max width. It's up to you to style via CSS.

## Not supported block types

Have an idea on how to best support these types? Make an issue to discuss:

* child_page
* child_database
* bookmark
* table_of_contents
* column
* column_list
* link_preview
* template
* link_to_page
* unsupported

Some types are supported but have caveats:

* bulleted_list_item (is implemented as a ul, does not follow the same display system as Notion)
* embed (is implemented as a figure containing the source)
* file (is implemented as a figure containing the source)
* pdf (is implemented as a figure containing the source)
* video (is implemented with a few common video providers embed code, but might be missing some. See `Html.VideoEmbed` for the list)
* toggle (is implemented, but is just a <ul>)
* equation (is implemented, but you must use KaTeX to format it in JS)
* synced_block (is implemented, but only if you provide the _children property)

## CSS

```
<style>
  .notion-callout {
    border-radius: 3px;
    padding: 1rem;

    white-space:pre-wrap;
    display:flex;
    gap: 10px;
    background-color: rgba(241, 241, 239, 1);
  }

  .notion-callout-content {
    flex-grow: 1;
  }

  .notion-embed,
  .notion-file,
  .notion-pdf {
    margin: 1.25em 0;
    page-break-inside: avoid;
  }

  .notion-embed .notion-source,
  .notion-file .notion-source,
  .notion-pdf .notion-source {
    border: 1px solid #ddd;
    border-radius: 3px;
    padding: 1.5em;
    word-break: break-all;
  }

  .notion-image {
    border: none;
    margin: 1.5em 0;
    padding: 0;
    border-radius: 0;
    text-align: center;
  }

  .notion-caption {
    opacity: 0.5;
    font-size: 85%;
    margin-top: 0.5em;
  }

  .notion-video-embed-sizer {
    position: relative;
    padding-bottom: calc(9/16 * 100%);
    height: 0;
  }

  .notion-video-embed-sizer iframe,
  .notion-video-embed-sizer video {
    position: absolute;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    border: 0;
    margin: 0;
  }
</style>
```
