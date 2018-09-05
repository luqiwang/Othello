defmodule OthelloWeb.Helpers do
  def page_name(mm, tt) do
    modu = String.replace(to_string(mm), ~r/^.*\./, "")
    tmpl = String.replace(to_string(tt), ~r/\..*$/, "")
    "#{modu}/#{tmpl}"
  end
end
