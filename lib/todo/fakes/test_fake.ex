defmodule Todo.TestFake do
  @moduledoc """
  A macro for test-fakes. It uses an agent to store requests and deliver responses.
  """
  defmacro __using__(_opts) do
    quote do
      def init() do
        if not initialized?(),
          do: {:ok, _agent} = Agent.start_link(fn -> {[], []} end, name: __MODULE__)
      end

      def add_response(response) do
        if Process.whereis(__MODULE__) do
          Agent.update(__MODULE__, fn {input, responses} ->
            responses =
              [response | Enum.reverse(responses)]
              |> Enum.reverse()

            {input, responses}
          end)
        end
      end

      def add_request(tuple) do
        if Process.whereis(__MODULE__) do
          Agent.update(__MODULE__, fn {input, output} ->
            {[tuple | input], output}
          end)
        end
      end

      def pop_response(function_name \\ nil) do
        if Process.whereis(__MODULE__) do
          Agent.get_and_update(__MODULE__, fn state ->
            case state do
              {_args, []} -> {nil, state}
              {args, [response | responses]} -> {response, {args, responses}}
            end
          end)
        end
        |> case do
          nil -> nil_response(function_name)
          other -> other
        end
      end

      defp nil_response(_), do: nil_response()
      defp nil_response(), do: {:ok, %{status_code: 200, body: "{}"}}

      defp initialized?(), do: Process.whereis(__MODULE__) != nil

      defoverridable nil_response: 0, nil_response: 1
    end
  end
end
