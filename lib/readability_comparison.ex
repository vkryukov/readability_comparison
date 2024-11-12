defmodule ReadabilityComparison do
  alias ReadabilityComparison.Compare

  @article_html_filename "article.html"

  def write_article_html(path) do
    with {:ok, comparison} <- Compare.parse(path) do
      File.write(Path.join(path, @article_html_filename), comparison.article_html)
    end
  end

  def testdir(path) do
    Path.join("../readability-js/test/test-pages", path)
  end

  def diff(path) do
    {:ok, comparison} = Compare.parse(path)

    first_diff(
      comparison.expected_htmltree |> normalize_html_whitespace,
      comparison.article_htmltree |> normalize_html_whitespace,
      0
    )
  end

  defp first_diff([a | rest_a], [a | rest_b], n), do: first_diff(rest_a, rest_b, n + 1)
  defp first_diff([a | _], [b | _], n) when a != b, do: %{first: a, second: b, n: n}
  defp first_diff([], [a | _], n), do: %{first: nil, second: a, n: n}
  defp first_diff([a | _], [], n), do: %{first: a, second: nil, n: n}

  defp normalize_html_whitespace(html_tree) do
    Floki.traverse_and_update(html_tree, fn
      {tag, attrs, children} when is_binary(hd(children)) ->
        children =
          Enum.map(children, fn
            text when is_binary(text) -> String.split(text) |> Enum.join(" ")
            other -> other
          end)

        {tag, normalize_attributes(attrs), children}

      other ->
        other
    end)
  end

  defp normalize_attributes(attrs) do
    attrs
    |> transform_attribute("href", &normalize_url/1)
  end

  defp transform_attribute(list, attribute, f) do
    Enum.map(list, fn
      {^attribute, value} -> {attribute, f.(value)}
      other -> other
    end)
  end

  defp normalize_url(url) do
    url
    # Remove fakehost, which is added to baseless URLs by Readability.js
    |> trim_prefix("http://fakehost")
    |> trim_suffix("/")
  end

  defp trim_prefix(string, prefix) do
    case String.starts_with?(string, prefix) do
      true -> String.slice(string, String.length(prefix)..-1//1)
      false -> string
    end
  end

  defp trim_suffix(string, suffix) do
    case String.ends_with?(string, suffix) do
      true -> String.slice(string, 0..-(String.length(suffix) + 1)//1)
      false -> string
    end
  end
end
