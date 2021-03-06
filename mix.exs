defmodule NotionRenderer.MixProject do
  use Mix.Project

  def project do
    [
      app: :notion_renderer,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Render Notion.so public API blocks into HTML",
      package: %{
        licenses: ["MIT AND Apache-2.0"],
        links: %{
          github: "https://github.com/cloveapp/notion_renderer"
        }
      }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.0", only: :test}
    ]
  end
end
