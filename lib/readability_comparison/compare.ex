defmodule ReadabilityComparison.Compare do
  defstruct [
    :path,
    :source_html,
    :expected_html,
    :expected_text,
    :expected_metadata,
    :article_html,
    :article_text
  ]

  @type t :: %__MODULE__{
          path: String.t(),
          source_html: String.t(),
          expected_html: String.t(),
          expected_text: String.t(),
          expected_metadata: map(),
          article_html: String.t(),
          article_text: String.t()
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
      %__MODULE__{
        path: path,
        source_html: source_html,
        expected_html: expected_html,
        expected_text: Floki.parse_fragment!(expected_html) |> Floki.text(),
        expected_metadata: expected_metadata
      }
    end
  end

  defp read_metadata(path) do
    with {:ok, content} <- Path.join(path, @metadata_filename) |> File.read(),
         {:ok, json} <- Jason.decode(content) do
      {:ok, json}
    end
  end
end
