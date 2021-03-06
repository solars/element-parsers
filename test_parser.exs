
defmodule Platform.Parsing.Behaviour do
  # Empty modules so tests work so far.

  defmacro __using__(_) do
    quote do

      # Helper functions for data structure access in parsers.
      # DO NOT REMOVE
      def get(meta, access, default \\ nil)
      def get(meta, [], _) do
        meta
      end
      def get(meta, [atom | rest], default) when is_atom(atom) and is_map(meta) do
        get(Map.get(meta, atom, Map.get(meta, to_string(atom), default)), rest, default)
      end
      def get(meta, [int | rest], default) when is_integer(int) and is_list(meta) do
        get(Enum.at(meta, int, default), rest, default)
      end
      def get(_, _, default) do
        default
      end

      # TODO: Add needed callbacks here.
    end
  end

end

defmodule TestParser do

  def test_parser_from_file(file) do
    file
    |> Code.require_file
    |> get_tests_from_parser
    |> run_tests
    |> exit_program
  end

  defp get_tests_from_parser([{parser_module, _}|_]) do
    {parser_module, apply(parser_module, :tests, [])}
  end

  defp run_tests({parser_module, tests}) do
    Enum.map(tests, fn({:parse_hex = test_type, payload_hex, meta, expected_result}) ->
      payload_binary = Base.decode16!(payload_hex)
      actual_result = apply(parser_module, :parse, [payload_binary, meta])

      case actual_result do
        ^expected_result ->
          IO.puts("[#{test_type}] Test payload #{inspect payload_hex} matches expected_result")
          :ok
        _ ->
          IO.puts("[#{test_type}] Test payload #{inspect payload_hex} DID NOT MATCH expected_result")
          IO.inspect(expected_result, label: "EXPECTED")
          IO.inspect(actual_result, label: "ACTUAL")
          :error
      end
    end)
  end

  defp exit_program(results) do
    if Enum.member?(results, :error) do
      System.halt(1)
    else
      System.halt(0)
    end
  end
end

[parser_file] = System.argv()

TestParser.test_parser_from_file(parser_file)
