defmodule ReadabilityComparison.Compare do
  defstruct [
    :path,
    :source_html,
    :expected_html,
    :expected_htmltree,
    :expected_metadata,
    :article_html,
    :article_htmltree
  ]

  @type t :: %__MODULE__{
          path: String.t(),
          source_html: String.t(),
          expected_html: String.t(),
          expected_htmltree: Floki.html_tree(),
          expected_metadata: map(),
          article_html: String.t(),
          article_htmltree: Floki.html_tree()
        }

  @metadata_filename "expected-metadata.json"
  @expected_filename "expected.html"
  @source_filename "source.html"

  @doc """
  Parses a directory with Mozilla's readability test case, runs Elixir's readability on 
  the source, and returns the resulting Compare structure.
  """
  @spec parse(String.t()) :: {:ok, t()} | {:error, term()}
  def parse(path) do
    with {:ok, source_html} <- Path.join(path, @source_filename) |> File.read(),
         {:ok, expected_html} <- Path.join(path, @expected_filename) |> File.read(),
         {:ok, expected_metadata} <- read_metadata(path) do
      article_html = source_html |> Readability.article() |> Readability.readable_html()

      {:ok,
       %__MODULE__{
         path: path,
         source_html: source_html,
         expected_html: expected_html,
         expected_htmltree: expected_html |> normalize_htmltree(),
         expected_metadata: expected_metadata,
         article_html: article_html,
         article_htmltree: article_html |> normalize_htmltree()
       }}
    end
  end

  defp read_metadata(path) do
    with {:ok, content} <- Path.join(path, @metadata_filename) |> File.read(),
         {:ok, json} <- Jason.decode(content) do
      {:ok, json}
    end
  end

  defp normalize_htmltree(html) do
    html
    |> Floki.parse_fragment!()
    |> remove_container_tag()
  end

  defp remove_container_tag(html_tree) do
    case html_tree do
      [{_tag, _attrs, children}] -> remove_container_tag(children)
      _ -> html_tree
    end
  end
end
