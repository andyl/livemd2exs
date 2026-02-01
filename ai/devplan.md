# Livemd2exs Devplan 

Livemd2exs converts Livebook `*.livemd` files to Elixir scripts `*.exs`.

This can be used in a Livebook regression test system.

Note:
- only elixir blocks will be converted 
- other types of blocks (including text blocks) will be thrown away 

## Phase 1 - Initial Development

- [x] Read existing code 
- [x] Suggest fixes for bugs and code style 
- [x] Update TODO items
- [x] Add code documentation 
- [x] Create a library of Livebook files for testing 
- [x] Create tests for the extraction modules
- [x] Update the README documentation

## Phase 2a - An installable livemd2exs script

- [x] Create an installable livemd2exs script
- [x] Update the README documentation with installation instructions:
    - [x] clone the repo
    - [x] install from local directory

## Phase 2b - Documentation 

- [x] Add a "Contributors" section to the README
- [x] Tell them PR's welcome
- [x] Tell contributors to use "Conventional Commits"
- [x] Add a LICENSE file (MIT License)

## Phase 3 - Create an approach for working with secrets

- [x] How to handle API keys?
- [x] How to handle LLM keys?

## Phase 4 - GitOps 

- [x] Add `git_ops` to manage Changelog and update Version

## Phase 5 - GitHub 

- [x] Setup a github repo (manual process)
- [x] Update script installation instructions for access via Github

## Phase 6 - Add an autoreport option

- [ ] Debug - automatically file a bug report if the conversion fails 

## Phase 7 - Automate issue handling 

- [ ] Setup a script to ingest errors
- [ ] Automatically fix errors, update fixtures and tests 
- [ ] Automatically issue PR

## Phase 8 - CI/CD 

- [ ] Setup CI/CD on github:
    - [ ] Add PR linting to only accept Conventional Commits 
- [ ] Auto-push to hex.pm
- [ ] Update script installation instructions for access via hex.pm

