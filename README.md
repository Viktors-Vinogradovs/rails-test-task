# Ruby on Rails Test Task

A minimal Ruby on Rails application for the take-home test.

## Stack

- **Ruby**: 3.4.8
- **Rails**: 7.1.6
- **Database**: SQLite3 (logically stateless - no data persistence required)
- **Testing**: RSpec

## How to Run Locally (Windows 11 + Cursor)

### Prerequisites

1. **Ruby 3.4.x** - Install via [RubyInstaller for Windows](https://rubyinstaller.org/) (with DevKit)
   - After installation, run `ridk install` and select option 3 (MSYS2 and MINGW development toolchain)
2. **Bundler** - Run `gem install bundler` after Ruby is installed
3. **Git** - For cloning the repository

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd "Ruby on Rails Test Task"
   ```

2. **Open terminal in Cursor**
   - Press `Ctrl+`` (backtick) or go to **View → Terminal**
   - Ensure you're in the project root directory

3. **Install dependencies**
   ```bash
   bundle install
   ```

### Running the Server

```bash
bin/rails server
```

Visit [http://localhost:3000](http://localhost:3000) in your browser.

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run with verbose output
bundle exec rspec --format documentation

# Run a specific file
bundle exec rspec spec/requests/example_spec.rb
```

## Project Structure

```
├── app/
│   ├── controllers/    # Request handlers
│   ├── models/         # Business logic (currently empty)
│   └── views/          # HTML templates
├── config/             # Rails configuration
├── spec/               # RSpec tests
│   ├── rails_helper.rb
│   └── spec_helper.rb
├── Gemfile             # Ruby dependencies
└── README.md           # This file
```

## Notes

- Provider API calls will be stubbed in tests (using WebMock, to be added later)
- No external API calls are made in the current state
- Database is SQLite for simplicity; no migrations are required for this task
