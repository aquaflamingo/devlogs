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

## Usage
### Initialize
Inside your project initialize the `.devlogs` repository:
```bash
$ devlogs init
```

Follow the prompts to setup the project configuration located in the _default_ `.devlogs/.devlogs.config`. (You can optionally set where you want to initialize the repository via --dirpath)

You can setup a mirror directory path in the configuration stage to sync changes to another directory on your machine, for example to Obsidian.md.

Example:

```
myproject
 .devlogs
   >> content
```

```
obsidianvault
  project
    mirror_logs
     >> content mirrored here
```

### Logs 
#### Creating log entries
Once you are done for the day or session run the `new` command:

```bash
devlogs new
```

Your editor will pop up and you can fill in cliff notes.

```
# <DATE HERE>

* Setup Postgresql Database
* Created the Post and User models
* Can't figure out how to connect devise + omniauth yet - need to figure that out
```

Save and if you set a mirror it will sync over!

#### Retrieve previous entry
You can use the `last` command to retrieve the most recent entry

```bash
devlogs last
```

#### List all log entires
You can use the `ls` command to retrieve the most recent entry

```bash
devlogs ls
```

### Issues
Devlogs also allows you to manage issues locally as well. Devlogs creates a separate subdirectory in the `.devlogs` folder which will contain all issues. These files are also synced if the repository is mirrored.

#### Creating an Issue
You can create a new issue via `devlogs new_issue`. You will be prompted to provide some information and then your editor will open and you can fill in some details

```bash
devlogs new_issue
```

#### List all issues
You can use the `ls_issues` command to retrieve the most recent entry

```bash
devlogs ls_issues
```

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
