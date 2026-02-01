defmodule Livemd2exs.Autoreport do
  @moduledoc """
  Automatically files GitHub issues via the `gh` CLI when conversion fails.

  Requires `gh` to be installed and authenticated. File content is included
  only when the user has opted in via `~/.config/livemd2exs/config.exs`.
  """

  @repo "andyl/livemd2exs"
  @max_content_chars 50_000

  @doc """
  Files a GitHub issue for a conversion failure.

  Returns `{:ok, url}` on success or `{:error, reason}` on failure.
  """
  def file_issue(filename, error_message, livemd_content) do
    title = issue_title(filename)
    body = issue_body(filename, error_message, livemd_content)

    case System.cmd("gh", ["issue", "create", "--repo", @repo, "--title", title, "--body", body],
           stderr_to_stdout: true
         ) do
      {output, 0} -> {:ok, String.trim(output)}
      {output, _} -> {:error, String.trim(output)}
    end
  end

  @doc "Generates an issue title from the filename."
  def issue_title(filename) do
    "Conversion failure: #{Path.basename(filename)}"
  end

  @doc "Formats the issue body with error details and optional file content."
  def issue_body(filename, error_message, livemd_content) do
    info = system_info()

    content_section =
      if livemd_content do
        truncated = String.slice(livemd_content, 0, @max_content_chars)

        suffix =
          if String.length(livemd_content) > @max_content_chars,
            do: "\n\n*(truncated at #{@max_content_chars} characters)*",
            else: ""

        """

        ## Input File Content

        <details>
        <summary>#{Path.basename(filename)}</summary>

        ```
        #{truncated}
        ```
        #{suffix}
        </details>
        """
      else
        ""
      end

    """
    ## Conversion Failure Report

    **File**: `#{filename}`

    ## Error

    ```
    #{error_message}
    ```

    ## Environment

    - **livemd2exs**: #{info.livemd2exs_version}
    - **Elixir**: #{info.elixir_version}
    - **OTP**: #{info.otp_version}
    - **OS**: #{info.os}
    #{content_section}\
    ---
    *Auto-filed by `livemd2exs --autoreport`*
    """
  end

  @doc "Gathers system version and OS information."
  def system_info do
    {os_family, os_name} = :os.type()

    %{
      livemd2exs_version: Livemd2exs.version(),
      elixir_version: System.version(),
      otp_version: :erlang.system_info(:otp_release) |> List.to_string(),
      os: "#{os_family}/#{os_name}"
    }
  end

  @doc "Returns `true` if the `gh` CLI is available on the system."
  def gh_available? do
    System.find_executable("gh") != nil
  end
end
