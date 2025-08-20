# Backend Integration

## Table of Contents

- [Workflows](#workflows)
  - [Some Process](#some-process)

- [API Endpoints](#api-endpoints)
  - [Health Check Endpoints](#health-check-endpoints)
    - [`GET /health`](#get-health)
    - [`GET /health/details`](#get-healthdetails)

## Workflows

### Some Process

<details>
  <summary>Click to view Sequence Diagram</summary>

```mermaid
---
version: 0.1
date: 2025-08-19
---
sequenceDiagram
```

</details>

## API Endpoints

### Health Check Endpoints

App monitoring endpoints

#### `GET /health`

Simple health check endpoint that returns the basic status of the service.

**Response:**

```json
{
  "status": "ok"
}
```

#### `GET /health/details`

Detailed health check endpoint that tests connections to Shopify, etc. APIs and
returns a status report with response times.

**Response:**

- **Content-Type:** `text/html`
- **Template:** `health_status.html`
- **Context Variables:**
  - `service_list`: Array of service status objects
  - `app_name`: "Backend Integration"
  - `version`: Current application version

**Service Status Object Structure:**

```json
{
  "name": "string",
  "is_ok": "boolean",
  "speed_ms": "integer (optional)"
}
```
