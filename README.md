# Shortener

This is a simple and powerful URL shortener built with Ruby on Rails 8. It provides a robust API to create and manage short links, as well as a convenient command-line interface (CLI) for power users.

## Features

*   **URL Shortening:** Create short, random tokens for any URL.
*   **Permanent Redirects:** Uses `308 Permanent Redirects` for SEO-friendly redirection.
*   **Click Tracking:** Counts the number of clicks for each link.
*   **RESTful API:** A clean and simple API for creating and listing links.
*   **CLI:** A user-friendly command-line interface for managing links.
*   **ASCII Art:** A fun, branded experience in both the CLI and API.
*   **Dashboard:** A basic-auth protected web page showing click statistics for every link.

## Getting Started

### Prerequisites

*   Ruby 3.3.0 or later
*   Bundler
*   SQLite3

### Installation

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/your-username/shortener.git
    cd shortener
    ```

2.  **Install dependencies:**

    ```bash
    bundle install
    ```

3.  **Set up the database:**

    ```bash
    rails db:setup
    ```

4.  **Configure your API key and dashboard login:**

    Create a `.env` file in the root of the project:

    ```
    API_KEY=your_secret_api_key
    DASHBOARD_USERNAME=your_dashboard_username
    DASHBOARD_PASSWORD=your_dashboard_password
    ```

5.  **Start the server:**

    ```bash
    rails server
    ```

## Usage

### API

The API provides several endpoints for interacting with the shortener.

#### Get All Links (JSON)

Returns a JSON array of all shortened links.

*   **Endpoint:** `GET /links`
*   **Authentication:** `Authorization: Token your_api_key`
*   **Example:**

    ```bash
    curl -H "Authorization: Token your_api_key" http://localhost:3000/links
    ```

#### Get All Links (Plain Text Table)

Returns a beautifully formatted plain text table of all shortened links.

*   **Endpoint:** `GET /links`
*   **Authentication:** `Authorization: Token your_api_key`
*   **Headers:** `Accept: text/plain`
*   **Example:**

    ```bash
    curl -H "Authorization: Token your_api_key" -H "Accept: text/plain" http://localhost:3000/links
    ```

#### Create a New Link

Creates a new shortened link.

*   **Endpoint:** `POST /links`
*   **Authentication:** `Authorization: Token your_api_key`
*   **Body:** `original_url=https://your-long-url.com`
*   **Validation:** `original_url` must be a valid `http` or `https` URL (max 2048 characters). Other schemes (e.g. `javascript:`, `data:`) are rejected with a `400` response.
*   **Example:**

    ```bash
    curl -X POST -H "Authorization: Token your_api_key" -d "original_url=https://google.com" http://localhost:3000/links
    ```

#### Get CLI Help

Returns the CLI help message with a fun ASCII art banner.

*   **Endpoint:** `GET /cli`
*   **Example:**

    ```bash
    curl http://localhost:3000/cli
    ```

### Dashboard

A simple statistics page listing every link, its click count, and totals.

*   **Endpoint:** `GET /dashboard`
*   **Authentication:** HTTP Basic Auth using `DASHBOARD_USERNAME` / `DASHBOARD_PASSWORD`
*   **Example:**

    ```bash
    open http://your_dashboard_username:your_dashboard_password@localhost:3000/dashboard
    ```

### Command-Line Interface (CLI)

The CLI provides a set of Rake tasks for managing links from your terminal.

#### Show Help

Displays the main help message with the ASCII art banner.

```bash
rake shortener
```

#### List All Links

Displays all shortened links in a formatted table.

```bash
rake shortener:list
```

#### Create a New Link

Creates a new short link from the command line.

```bash
rake shortener:create[https://your-long-url.com]
```

## Running Tests

```bash
bin/rails test
```