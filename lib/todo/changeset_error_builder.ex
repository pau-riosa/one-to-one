defmodule Todo.ChangesetErrorBuilder do
  def call(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(&full_messages/3)
    |> Map.values()
    |> interpolate()
  end

  def call(errors), do: errors

  defp interpolate(string) when is_binary(string), do: string

  defp interpolate(map) when map == %{}, do: ""

  defp interpolate(list) when is_list(list) do
    Enum.reduce(list, [], fn x, acc ->
      case interpolate(x) do
        "" -> acc
        val -> [val | acc]
      end
    end)
    |> Enum.join(", ")
  end

  defp interpolate(%{} = map) do
    Map.values(map) |> interpolate()
  end

  defp interpolate(_), do: ""

  defp full_messages(_changeset, _field_name, {message, _variables}) do
    message
  end

  def humanize_schema_field(field_name) when is_atom(field_name) do
    field_name
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
