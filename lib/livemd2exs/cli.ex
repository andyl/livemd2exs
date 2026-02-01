defmodule Livemd2exs.CLI do
  @moduledoc """
  Command-line interface for livemd2exs.

  Converts a Livebook file to an executable Elixir script and writes it to
  stdout or an output file.
  """

  def main(args) do
    case parse_args(args) do
      {:ok, livemd_path, output_path} ->
        run(livemd_path, output_path)

      :error ->
        usage()
        System.halt(1)
    end
  end

  defp parse_args([livemd_path]) do
    {:ok, livemd_path, nil}
  end

  defp parse_args([livemd_path, "-o", output_path]) do
    {:ok, livemd_path, output_path}
  end

  defp parse_args(_), do: :error

  defp run(livemd_path, output_path) do
    unless File.exists?(livemd_path) do
      IO.puts(:stderr, "Error: file not found: #{livemd_path}")
      System.halt(1)
    end

    script = Livemd2exs.extract(livemd_path) <> "\n"

    case output_path do
      nil ->
        IO.write(script)

      path ->
        File.write!(path, script)
        IO.puts(:stderr, "Wrote #{path}")
    end
  end

  defp usage do
    IO.puts(:stderr, """
    Usage: livemd2exs <input.livemd> [-o <output.exs>]

    Converts a Livebook file to an executable Elixir script.

    If -o is not specified, the script is written to stdout.
    """)
  end
end
