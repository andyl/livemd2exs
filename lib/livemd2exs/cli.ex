defmodule Livemd2exs.CLI do
  @moduledoc """
  Command-line interface for livemd2exs.

  Converts a Livebook file to an executable Elixir script and writes it to
  stdout or an output file.
  """

  alias Livemd2exs.{Autoreport, Config}

  def main(args) do
    case parse_args(args) do
      {:ok, livemd_path, output_path, opts} ->
        run(livemd_path, output_path, opts)

      :error ->
        usage()
        System.halt(1)
    end
  end

  defp parse_args(args) do
    case OptionParser.parse(args, strict: [o: :string, autoreport: :boolean]) do
      {opts, [livemd_path], []} ->
        output_path = Keyword.get(opts, :o)
        {:ok, livemd_path, output_path, opts}

      _ ->
        :error
    end
  end

  defp run(livemd_path, output_path, opts) do
    unless File.exists?(livemd_path) do
      IO.puts(:stderr, "Error: file not found: #{livemd_path}")
      maybe_autoreport(livemd_path, "File not found: #{livemd_path}", nil, opts)
      System.halt(1)
    end

    try do
      script = Livemd2exs.extract(livemd_path) <> "\n"

      case output_path do
        nil ->
          IO.write(script)

        path ->
          File.write!(path, script)
          IO.puts(:stderr, "Wrote #{path}")
      end
    rescue
      e ->
        error_message = Exception.format(:error, e, __STACKTRACE__)
        IO.puts(:stderr, "Error: conversion failed for #{livemd_path}")
        IO.puts(:stderr, error_message)

        livemd_content =
          case File.read(livemd_path) do
            {:ok, content} -> content
            {:error, _} -> nil
          end

        maybe_autoreport(livemd_path, error_message, livemd_content, opts)
        System.halt(1)
    end
  end

  defp maybe_autoreport(filename, error_message, livemd_content, opts) do
    unless Keyword.get(opts, :autoreport, false), do: :noop

    if Keyword.get(opts, :autoreport, false) do
      cond do
        not Autoreport.gh_available?() ->
          IO.puts(:stderr, "autoreport: `gh` CLI not found. Install it from https://cli.github.com/")

        not Config.autoreport_enabled?() ->
          IO.puts(:stderr, """
          autoreport: content inclusion not enabled.

          To enable, create #{Config.config_path()} with:

              [autoreport_include_content: true]
          """)

        true ->
          IO.puts(:stderr, "autoreport: filing GitHub issue...")

          case Autoreport.file_issue(filename, error_message, livemd_content) do
            {:ok, url} ->
              IO.puts(:stderr, "autoreport: issue filed at #{url}")

            {:error, reason} ->
              IO.puts(:stderr, "autoreport: failed to file issue: #{reason}")
          end
      end
    end
  end

  defp usage do
    IO.puts(:stderr, """
    Usage: livemd2exs <input.livemd> [-o <output.exs>] [--autoreport]

    Converts a Livebook file to an executable Elixir script.

    Options:
      -o <file>      Write output to file instead of stdout
      --autoreport   File a GitHub issue if conversion fails (requires config)

    If -o is not specified, the script is written to stdout.
    """)
  end
end
