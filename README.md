# NotionRenderer

**This project's author has no affiliation with Notion**

Want to render notion API blocks into HTML? This library is for you.

## Installation

This package can be installed by adding `notion_renderer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:notion_renderer, "~> 0.1.0"}
  ]
end
```

## TODO

- [ ] Better testing strategy and exhaustive testing
- [ ] Hex documentation (currently documentation is in this file)

## Usage

Retrieving blocks via the API is not something this library handles. You need to do that and then provide blocks
to `NotionRenderer.block_to_html/1,2`. In order to render child content, you also need to provide the `_children`
attribute which is a list of blocks. Basically, you can recursively hit the API to build up the blocks list.

Blocks are expected to be a string-based map. The blocks are taken as-is from the API, with the
added support of `_children`.

```elixir
# Retrieving blocks is up to you
blocks = retrieve_blocks_from_api()

# Then just pass them in!
html = NotionRenderer.block_to_html(blocks)

# or pass options
rewriter = fn href -> "modified #{href}" end
html = NotionRenderer.block_to_html(blocks, [link_rewriter: rewriter])
```

## Options

You can provide `link_rewriter` option to rewrite all link hrefs. This option is useful to rewrite page links
into your platform's patterns.

All of the HTML renderers are replaceable via the `config` property. It's undocumented at this time.

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
* synced_block (is implemented, but only if you provide the `_children` property)

## CSS

Rather than inlining styles, this code tries to use CSS classes whenever reasonable. You can overwrite these classes
as needed, but the following stylesheet is a great start.

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

  .notion-video {
    margin: 0;
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
