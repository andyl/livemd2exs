defmodule Livemd2exs.AutoreportTest do
  use ExUnit.Case

  alias Livemd2exs.Autoreport

  describe "issue_title/1" do
    test "includes the basename of the file" do
      assert Autoreport.issue_title("/path/to/notebook.livemd") ==
               "Conversion failure: notebook.livemd"
    end

    test "handles simple filename" do
      assert Autoreport.issue_title("test.livemd") == "Conversion failure: test.livemd"
    end
  end

  describe "issue_body/3" do
    test "includes filename and error message" do
      body = Autoreport.issue_body("test.livemd", "** (RuntimeError) oops", nil)
      assert body =~ "test.livemd"
      assert body =~ "** (RuntimeError) oops"
    end

    test "includes environment info" do
      body = Autoreport.issue_body("test.livemd", "error", nil)
      assert body =~ "livemd2exs"
      assert body =~ "Elixir"
      assert body =~ "OTP"
      assert body =~ "OS"
    end

    test "includes file content when provided" do
      body = Autoreport.issue_body("test.livemd", "error", "# My Notebook\n\n```elixir\nIO.puts(1)\n```")
      assert body =~ "Input File Content"
      assert body =~ "# My Notebook"
    end

    test "does not include content section when content is nil" do
      body = Autoreport.issue_body("test.livemd", "error", nil)
      refute body =~ "Input File Content"
    end

    test "truncates long content" do
      long_content = String.duplicate("x", 60_000)
      body = Autoreport.issue_body("test.livemd", "error", long_content)
      assert body =~ "truncated at 50000 characters"
    end
  end

  describe "system_info/0" do
    test "returns a map with expected keys" do
      info = Autoreport.system_info()
      assert Map.has_key?(info, :livemd2exs_version)
      assert Map.has_key?(info, :elixir_version)
      assert Map.has_key?(info, :otp_version)
      assert Map.has_key?(info, :os)
    end

    test "versions are non-empty strings" do
      info = Autoreport.system_info()
      assert is_binary(info.livemd2exs_version) and info.livemd2exs_version != ""
      assert is_binary(info.elixir_version) and info.elixir_version != ""
      assert is_binary(info.otp_version) and info.otp_version != ""
      assert is_binary(info.os) and info.os != ""
    end
  end

  describe "gh_available?/0" do
    test "returns a boolean" do
      result = Autoreport.gh_available?()
      assert is_boolean(result)
    end
  end
end
