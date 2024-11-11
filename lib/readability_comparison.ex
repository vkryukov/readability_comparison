defmodule ReadabilityComparison do
  alias ReadabilityComparison.Compare

  @article_html_filename "article.html"

  def write_article_html(path) do
    with {:ok, comparison} <- Compare.parse(path) do
      File.write(Path.join(path, @article_html_filename), comparison.article_html)
    end
  end
end
