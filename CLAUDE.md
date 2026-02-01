# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Livemd2exs is an Elixir library that converts Livebook markdown files (`.livemd`) to executable Elixir scripts (`.exs`). The converter extracts Elixir code blocks from Livebook files and generates standalone scripts with a shebang header, discarding text blocks and other non-code content.

**Core Functionality**: The main module `Livemd2exs` at lib/livemd2exs.ex provides the `extract/1` function that:
1. Parses `.livemd` files using the Earmark markdown parser
2. Filters the AST for `<pre>` tags (code blocks)
3. Extracts nested code content via double-mapping pattern
4. Joins code blocks with blank line separators
5. Prepends a generated header with timestamp and source file path

## Development Commands

### Core Workflow
```bash
# Install dependencies
mix deps.get

# Compile project
mix compile

# Run tests
mix test

# Run specific test file
mix test test/livemd2exs_test.exs

# Run with specific test line
mix test test/livemd2exs_test.exs:5

# Format code (respects .formatter.exs config)
mix format
```

### REPL/Interactive Development
```bash
# Start IEx with project compiled
iex -S mix

# In IEx, test extraction:
# Livemd2exs.extract("priv/llmdb.livemd")
```

## Architecture Notes

### Data Flow Pattern
The extraction logic in lib/livemd2exs.ex:16-23 uses a specific nested structure:
- Earmark AST produces: `{"pre", _, [{"code", _, [actual_code], _}], _}`
- Two consecutive `Enum.map` calls navigate this nesting
- First map extracts inner tuple: `{_, _, [code], _}`
- Second map extracts string content: `{_, _, [code], _}`

This double-extraction pattern is intentional for Earmark's nested code block representation.

### Dependencies
- **Earmark 1.4**: Markdown parsing to AST. Handles standard markdown with code fences.
- No runtime OTP application configured (library only, no supervision tree).

## Testing Strategy

The test suite (test/livemd2exs_test.exs) is minimal and contains a placeholder test that references a non-existent `hello/0` function. When adding tests:
- Use priv/llmdb.livemd as a sample input fixture
- Test extraction preserves code block ordering
- Verify header generation includes timestamp and source path
- Validate that only Elixir code blocks are extracted (not text/markdown)

## Development Roadmap

See notes/devplan.md for the multi-phase development plan. Key upcoming work:
- **Phase 1**: Bug fixes, documentation, comprehensive test coverage
- **Phase 2**: Installable escript with CLI interface
- **Phase 3**: Secret/API key handling for converted scripts
- **Phase 4**: Optional text-to-comments conversion
- **Future**: CI/CD setup, hex.pm publishing automation

## File Organization

- `lib/livemd2exs.ex` - Core extraction module (single public function)
- `priv/llmdb.livemd` - Example Livebook file for testing (LLMDB library demo)
- `notes/devplan.md` - Project roadmap and feature backlog
- `test/` - Test suite (needs expansion per Phase 1 goals)
