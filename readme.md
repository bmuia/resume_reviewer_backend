# AI Resume Website Analyzer - API

This repository contains the backend services for the AI Resume Website Analyzer. Built with **Django** and containerized using **Docker**, it handles resume and job description processing, AI analysis with **Google Gemini**, and provides a robust API for the frontend.

---

## Table of Contents

* [Features](#features)
* [How It Works](#how-it-works)
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Configuration](#configuration)
* [API Endpoints](#api-endpoints)
* [Running the Backend](#running-the-backend)
* [Contributing](#contributing)
* [License](#license)

---

## Features

* **Django Framework:** A robust and scalable web framework for handling business logic.
* **Dockerized Environment:** Ensures consistent development, testing, and deployment.
* **File Upload Handling:** Securely receives resume and optional job description files in various formats.
* **AI Integration with Google Gemini:** Leverages Google's powerful Gemini model for in-depth content analysis.
* **Resume Analysis:** Extracts key information, identifies strengths, weaknesses, and areas for improvement based on resume content.
* **Job Description Alignment:** Compares resume content against job descriptions to provide tailored and relevant feedback.
* **RESTful API:** Offers a clean and well-defined API (`/api/resume-review/`) for seamless frontend communication.
* **Database Integration:** Configured to connect to a PostgreSQL database (e.g., Neon.tech).

---

## How It Works

The Django backend is the core processing unit of the application. When a user uploads their resume and an optional job description via the frontend, these files are sent to the backend's designated API endpoint. The backend then:

1.  Receives the uploaded files as `multipart/form-data`.
2.  Parses the content of the resume and job description using appropriate libraries.
3.  Feeds the extracted text to the configured **Google Gemini** AI model.
4.  Processes the AI's output, structuring it into clear categories: strengths, weaknesses, and actionable improvement suggestions.
5.  Sends this structured JSON analysis back to the frontend for display.

---

## Prerequisites

Before you can set up and run the backend, make sure you have the following installed:

* **Docker Desktop:** Essential for containerizing and running the application. This includes Docker Compose.
* **Google Gemini API Key:** You'll need a valid API key from Google AI Studio to interact with the Gemini model.
* **(Optional) System-level PDF Parsers:** If your Django application directly processes PDF files outside of a library that bundles its own PDF parser, you might need `poppler-utils` (e.g., on Linux: `sudo apt-get install poppler-utils`). However, many Python PDF libraries handle this internally or expect the environment to be set up in the Dockerfile.

---

## Installation

Follow these steps to get the Django backend up and running using Docker:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/bmuia/resume_reviewer_backend.git
    cd resume_reviewer_backend 
    ```
2.  **Ensure Docker Desktop is running** on your machine. # note you can use docker CLI if you don't have docker desktop

---

## Configuration

You'll need to set up environment variables for the backend to connect to the database and use the AI service.

1.  **Create a `.env` file** in the root of your project directory (the same level as your `compose.yml` file).
2.  **Add the following configuration variables** to this `.env` file:
    ```dotenv
    DB_NAME=your_production_db_name
    DB_USER=your_production_db_user
    DB_PASSWORD=your_production_db_password
    DB_HOST=_your_production_db_host
    DB_PORT=5432
    DATABASE_SSL=true

    AI_PROVIDER='gemini'

    # Uncomment the AI provider you are using. For Gemini:
    # CHATGPT_API_KEY=your_chatgpt_api_key
    GEMINI_API_KEY=your_gemini_api_key

    DJANGO_SECRET_KEY=your_django_secret_key

    ENV='development'
    ```
    **Important:** Always add `.env` to your `.gitignore` file to prevent sensitive credentials from being committed to version control.
                   I highly recommend using Neon as your database—it's easy to set up,free to use and great for production.


---

## API Endpoints

The primary API endpoint for resume analysis is:

* **`POST /api/resume-review/`**
    * **Description:** Accepts a resume file and an optional job description text for AI-powered analysis.
    * **Request Type:** `multipart/form-data`
    * **Request Body Fields:**
        * `resume`: (File, **Required**) The applicant's resume pdf file (e.g., `resume.pdf`).
        * `job_description`: (Text, *Optional*).
    * **Success Response (`200 OK`):**
        ```json
        {
            "strengths": [
                "Clearly highlighted relevant technical skills.",
                "Quantifiable achievements provided for previous roles."
            ],
            "weaknesses": [
                "Inconsistent formatting in the education section.",
                "Lack of a tailored summary for the specific job."
            ],
            "improvements": [
                "Standardize font sizes and spacing across sections.",
                "Craft a concise professional summary that aligns with the job description's keywords and requirements.",
                "Add more action verbs to describe responsibilities."
            ]
        }
        ```
    * **Error Responses:**
        * `400 Bad Request`: Missing required files or invalid file formats.
        * `500 Internal Server Error`: An unexpected issue occurred during processing or AI communication.

---

## Running the Backend

To build and run your Django backend using Docker Compose:

1.  From the root of your project directory (where `compose.yml` is located), execute:
    ```bash
    docker-compose up --build
    ```
    This command will build your Docker images (if they're not up-to-date) and start your containers, including the Django application and any configured database services.
2.  Your Django backend service will typically be accessible at `http://localhost:8000`.

---

## Contributing

We welcome contributions to improve the AI Resume Website Analyzer backend! Please follow these steps:

1.  Fork this repository.
2.  Create a new branch for your feature or bug fix: `git checkout -b feature/your-feature-name` or `bugfix/fix-something`.
3.  Make your changes, ensuring code quality, proper error handling.
4.  Write clear and concise commit messages.
5.  Push your changes to your forked repository.
6.  Open a Pull Request to the `main` branch of this repository, describing your changes in detail.

---

## License

This project is licensed under the [MIT License](LICENSE).