defmodule NotionRenderer.Html.VideoEmbed do
  @gdrive ~r/https:\/\/drive\.google\.com\/file\/d\/(.+)\/view/
  @vidyard ~r/https:\/\/share\.vidyard\.com\/watch\/([a-zA-Z0-9]+)/
  @loom ~r/https:\/\/www\.loom\.com\/share\/([a-zA-Z0-9]+)/
  @youtube ~r/https:\/\/www\.youtube\.com\/watch\?v=([a-zA-Z0-9]+)/

  # https://drive.google.com/file/d/1xOi8RrgpFZRNMnSpsDqqED5KzPJVLhfN/view?usp=sharing
  # https://share.vidyard.com/watch/R2Fz6PzCXDEbH57tHCEPS7
  # https://www.loom.com/share/e9a84ffeb2f846739c8ce26913d1086d
  # https://www.youtube.com/watch?v=vjjshcZoQxw

  @matchers [
    %{regex: @gdrive, fn: &__MODULE__.gdrive_embed/2},
    %{regex: @vidyard, fn: &__MODULE__.vidyard_embed/2},
    %{regex: @loom, fn: &__MODULE__.loom_embed/2},
    %{regex: @youtube, fn: &__MODULE__.youtube_embed/2}
  ]

  def embed_code_for(nil), do: nil

  def embed_code_for(url) do
    match = Enum.find(@matchers, fn %{regex: rx} -> Regex.match?(rx, url) end)

    html =
      case match do
        %{regex: rx, fn: func} -> String.trim(func.(url, rx))
        nil -> String.trim(fallback_embed(url))
      end

    String.replace(html, "\n", " ")
  end

  def fallback_embed(url) do
    """
    <div class="notion-video-embed">
      <div class="notion-video-embed-sizer">
        <video playsinline controls src="#{url}" />
      </div>
    </div>
    """
  end

  def gdrive_embed(url, rx) do
    [_match, id] = Regex.run(rx, url)

    """
    <div class="notion-video-embed">
      <div class="notion-video-embed-sizer">
        <iframe frameborder="0"
                webkitallowfullscreen mozallowfullscreen allowfullscreen
                src="https://drive.google.com/file/d/#{id}/preview"></iframe>
      </div>
    </div>
    """
  end

  def youtube_embed(url, rx) do
    [_match, id] = Regex.run(rx, url)

    """
    <div class="notion-video-embed">
      <div class="notion-video-embed-sizer">
        <iframe src="https://www.youtube.com/embed/#{id}"
                frameborder="0"
                webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
      </div>
    </div>
    """
  end

  def vidyard_embed(url, rx) do
    [_match, id] = Regex.run(rx, url)

    """
    <script type="text/javascript" async src="https://play.vidyard.com/embed/v4.js"></script>

    <div class="notion-video-embed">
      <div style="width: 100%">
        <img
          style="width: 100%; margin: auto; display: block;"
          class="vidyard-player-embed"
          src="https://play.vidyard.com/#{id}.jpg"
          data-uuid="#{id}"
          data-v="4"
          data-type="inline"
        />
      </div>
    </div>
    """
  end

  def loom_embed(url, rx) do
    [_match, id] = Regex.run(rx, url)

    """
    <div class="notion-video-embed">
      <div class="notion-video-embed-sizer">
        <iframe src="https://www.loom.com/embed/#{id}"
                frameborder="0"
                webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
      </div>
    </div>
    """
  end
end
