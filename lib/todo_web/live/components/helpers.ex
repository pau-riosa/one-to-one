defmodule TodoWeb.Components.Helpers do
  def build_path(current_path, params) do
    current_path
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(params))
    |> URI.to_string()
  end

  def class_list(items) do
    items
    |> Enum.reject(&(elem(&1, 1) == false))
    |> Enum.map(&elem(&1, 0))
    |> Enum.join(" ")
  end
end
