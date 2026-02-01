defmodule Livemd2exs.Config do
  @moduledoc """
  Reads user configuration from `~/.config/livemd2exs/config.exs`.

  The config file is an Elixir keyword list evaluated with `Code.eval_string/1`.
  Missing or malformed files are silently ignored, returning an empty list.
  """

  @config_filename "config.exs"

  @doc "Returns the default config file path."
  def config_path do
    Path.join([System.user_home!(), ".config", "livemd2exs", @config_filename])
  end

  @doc """
  Reads and evaluates the config file at the given path.

  Returns a keyword list on success, or `[]` if the file is missing or malformed.
  """
  def read(path \\ nil) do
    path = path || config_path()

    case File.read(path) do
      {:ok, contents} ->
        try do
          {result, _bindings} = Code.eval_string(contents)

          if Keyword.keyword?(result), do: result, else: []
        rescue
          _ -> []
        end

      {:error, _} ->
        []
    end
  end

  @doc """
  Returns `true` if autoreport content inclusion is enabled in the config.
  """
  def autoreport_enabled?(path \\ nil) do
    read(path) |> Keyword.get(:autoreport_include_content) == true
  end
end
