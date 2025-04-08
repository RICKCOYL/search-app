# Search Analytics App
A real-time search analytics application built with Ruby on Rails and JavaScript that tracks and analyzes user search patterns.

## Features

- Real-time article search
- Per-user search tracking (using IP address)
- Intelligent search tracking that only stores completed searches
- Analytics dashboard showing top searches and user's own search history
- Scalable architecture designed to handle thousands of requests per hour
- RSpec test

## Technical Overview

### Architecture

This application is built with a focus on scalability and performance:

1. **Backend**: Ruby on Rails with PostgreSQL
2. **Frontend**: JavaScript for real-time interaction
3. **Tracking Algorithm**: Intelligent system to detect and store only completed searches

### The Search Tracking Algorithm

The core of this application is its ability to intelligently track what users are searching for without creating a "pyramid problem" (storing every keystroke as a separate search).

The algorithm works as follows:

1. User types in the search box, triggering real-time searches
2. Each keystroke is debounced to prevent excessive API calls
3. After a short pause in typing (1 second), the current query is considered "completed"
4. Completed queries are stored in the database with the user's IP address
5. Analytics are generated from only the completed searches

This approach ensures that we capture the user's actual intent rather than the intermediate steps.

## Setup and Installation

### Prerequisites

- Ruby 3.2.x
- Rails 7.x
- PostgreSQL
- Node.js

### Installation Steps

1. Clone the repository:
```bash
git clone https://github.com/yourusername/search_analytics.git
cd search_app
```

2. Install dependencies:
```bash
bundle install
npm install
```

3. Set up the database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

4. Start the server:
```bash
bin/dev
```

5. `http://localhost:3000`

## Testing

Run tests:

```bash
bundle exec rspec
```
