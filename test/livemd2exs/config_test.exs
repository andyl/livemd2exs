defmodule Livemd2exs.ConfigTest do
  use ExUnit.Case

  alias Livemd2exs.Config

  @fixtures_dir "test/fixtures/config"

  describe "config_path/0" do
    test "returns path under ~/.config/livemd2exs" do
      path = Config.config_path()
      assert path =~ ".config/livemd2exs/config.exs"
      assert String.starts_with?(path, System.user_home!())
    end
  end

  describe "read/1" do
    test "reads a valid enabled config" do
      result = Config.read(Path.join(@fixtures_dir, "valid_enabled.exs"))
      assert result == [autoreport_include_content: true]
    end

    test "reads a valid disabled config" do
      result = Config.read(Path.join(@fixtures_dir, "valid_disabled.exs"))
      assert result == [autoreport_include_content: false]
    end

    test "returns empty list for missing file" do
      result = Config.read("/nonexistent/path/config.exs")
      assert result == []
    end

    test "returns empty list for malformed file" do
      result = Config.read(Path.join(@fixtures_dir, "malformed.exs"))
      assert result == []
    end
  end

  describe "autoreport_enabled?/1" do
    test "returns true when autoreport_include_content is true" do
      assert Config.autoreport_enabled?(Path.join(@fixtures_dir, "valid_enabled.exs"))
    end

    test "returns false when autoreport_include_content is false" do
      refute Config.autoreport_enabled?(Path.join(@fixtures_dir, "valid_disabled.exs"))
    end

    test "returns false for missing config" do
      refute Config.autoreport_enabled?("/nonexistent/path/config.exs")
    end

    test "returns false for malformed config" do
      refute Config.autoreport_enabled?(Path.join(@fixtures_dir, "malformed.exs"))
    end
  end
end
