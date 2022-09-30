# devlogs
Project based session logging for solo-developers with the option to mirror changes to another directory.

![Maintain non-source controlled logs across various projects with mirroring to a single](./docs/mirroring.png)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'devlogs'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install devlogs

## What is devlogs?

The idea is simple: a personal project logging CLI that uses markdown files co-located in the source code repository. 

```bash
cd my_project

devlogs init

Creating devlogs repository...

What is the project name? Test project
What is the project description? Test project description
What is the project short code (3 letters)? TST
Do you want to mirror these logs? y
Path to mirror directory:  $HOME/src/my_project/devlogs-mirror
Created devlogs repository

```

The above initialization process creates a hidden directory called `.devlogs` inside of the project. Inside the `.devlogs` repository there are a few different files:

```bash
.devlogs/
	issues/
	.devlogs.config.yml
	.devlogs.data.yml
	.issue_template.erb.md
	.log_template.erb.md
	test_project.devlogs.info.md
```

The `.devlogs.config.yml` contains the configuration information provided in the initial setup including `mirror` configuration. The mirroring functionality exists for the use case in which you do not want to commit logging to version control but want to maintain a copy somewhere else on your computer that you backup. For example, I might manage project information inside of an Obsidian project folder, and want to mirror all the logs there for posterity.

The `.devlogs.data.yml` file contains state data required for operating the CLI. At the moment, it is just a store for incrementing the issue index for a new issue. For example `TST-1`, `TST-2`, et cetera.

The `.log_template.erb.md` file is an optionally customizable template file that the `devlogs` CLI will use for creating each log entries. This is useful if you have a custom scheme which you tag notes in your Obsidian vaults or other project management software.

The `.issue_template.erb.md` file is similar to the log template file. It is a customizable template you can use for tracking various issues for your project. I added issue tracking because my logging workflow seemed to always be at the end of my development period (e.g. finishing work for the day) but I wanted to have a way of capturing in-the-moment bugs or other issues that were unrelated to my present task that I didn't want to forget about. 

The `test_project.devlogs.info.md` is just an `.info` file. This is preferential to my workflow in Obsidian containing the project description.


## Using devlogs for logging
When you are done developing for the day you can use the `devlogs new` command to create a new entry. Here is an example below from a project:

```markdown
# LOG: 09-28-2022 15:43
Tags: #dev, #log

- Decided to go ahead and start with importing audio before configuring the ui.
- I was implementing of repository pattern, but not sure if it's the right direction. Need to think a little more about this

NEXT:
- Need to find an ID3Tag reading library. This will help to read the metadata from an MP3 thereby allowing import into the application.

```

As you can see the notes are informal and meant only to capture the context at the time and the top of mind items for your next development session.

You can use the `devlogs ls` command to explore previous log entries or `devlogs last` in order to get the most recent entry:

```bash
devlogs ls

Select a log entry... 
(Press ↑/↓ arrow to move and Enter to select)
‣ 09-28-2022__15h43m_log.md
‣ 09-27-2022__12h41m_log.md
```

## Using devlogs for issues
As mentioned, `devlogs` also helps with local issue tracking. New issues can be created via `devlogs new_issue` which will prompt you for some information, read from the issue template and open the file in an editor for you to confirm and save.

```markdown
# TST-1: There is a problem

## Problem
When I try to use the project it errors out!


## Reproduction Steps
Open the project and run ./bin/run

```

Issues are contained in the `issues` sub directory of `.devlogs`. You can explore the issues via `devlogs ls_issue`

```markdown
Select an issue issue... (Press ↑/↓ arrow to move and Enter to select)

‣ tst-1__there_is_a_problem.md
```

The `devlogs` CLI uses the convention of 3-letter-prefix + index in order to create keys for issues. 

### Custom Templates
Devlogs initializes the log repository with two custom templates that you can edit freely `.log_template.erb.md` and `.issue_template.erb.md`. These are [Embedded Ruby Files](https://en.wikipedia.org/wiki/ERuby) meaning they can access certain variables.

#### Log Template
| Variable Name | Value |
| --- | --- |
| Time | The current date, hour and minute time |

#### Issue Template
| Variable Name | Value |
| --- | --- |
| Time | The current date, hour and minute time |
| Issue Title | The provided issue title input from the issue creation prompt |
| Description | The provided description input from the issue creation prompt |
| Reproduction Steps | The provided input for reproduction steps from the issue creation prompt |

## Development
After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/aquaflamingo/devlogs.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
