# Weather Forecast API

A Ruby on Rails application for the take-home coding test. Fetches weather data from an external provider and returns forecast information.

## Requirements / What's Implemented

- [x] Rails application scaffolding (Sprint 0)
- [x] RSpec test framework configured
- [ ] Weather forecast endpoint (Sprint 1 - pending)
- [ ] External provider integration (Sprint 1 - pending)

## Tech Stack

| Component | Version |
|-----------|---------|
| Ruby | 3.4.8 |
| Rails | 7.1.x |
| Database | SQLite (default) |
| Testing | RSpec |

## Setup

```bash
git clone <repository-url>
cd "Ruby on Rails Test Task"
bundle install
bin/rails db:prepare
```

## Run

```bash
bin/rails server
```

Server starts at [http://localhost:3000](http://localhost:3000).

## Test

```bash
bundle exec rspec
```

## Useful Commands

```bash
bin/rails routes      # List all routes
bin/rails console     # Interactive Rails console
bin/rails db:migrate  # Run pending migrations
```
