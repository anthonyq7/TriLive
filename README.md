```markdown
# TriLive

> Real-time bus & train arrival times on your iPhone, with favorites, search, and offline support.

Built by Brian Maina & Anthony “Ant” Qin — a full-stack SwiftUI + FastAPI project containerized via Docker.

---

## Table of Contents

1. [Overview](#overview)  
2. [Features](#features)  
3. [Architecture & Tech Stack](#architecture--tech-stack)  
4. [Getting Started](#getting-started)  
   - [Prerequisites](#prerequisites)  
   - [Clone & Configure](#clone--configure)  
   - [Run with Docker (Recommended)](#run-with-docker-recommended)  
   - [Run Locally without Docker](#run-locally-without-docker)  
5. [Testing](#testing)  
6. [Directory Structure](#directory-structure)  
7. [Design Assets](#design-assets)  
8. [Contact](#contact)  

---

## Overview

TriLive delivers live transit ETAs for buses and trains at nearby stops in a sleek SwiftUI interface. We implemented:

- A **FastAPI** backend (Python) with Pydantic-powered request/response models.  
- **PostgreSQL** for persistent stop/route data.  
- **Redis** for in-memory caching of frequent ETA lookups.  
- **Docker Compose** to glue services together, ensuring “it works on my machine” parity.  

---

## Features

- **Live ETAs** auto-refresh every 30 seconds (configurable)  
- **Offline Caching**: last-seen data shows when offline  
- **Favorites**: bookmark your most-used stops and routes  
- **Location-Aware Search** powered by Core Location & autocomplete  
- **Health Checks** and structured API docs via OpenAPI  

---

## Architecture & Tech Stack

```
┌────────┐     HTTPS      ┌───────────┐      ┌───────────┐
│  iOS   │ ──────────────► │  FastAPI  │ ◄────│  iOS App  │
│ SwiftUI│                 │  Backend  │      │  (Swift)  │
└────────┘                 └───────────┘      └───────────┘
                                │
         ┌─────────────┐        │         ┌─────────┐
         │  PostgreSQL │ ◄──────┼───────► │  Redis  │
         └─────────────┘   data │  cache │ (in-mem) │
                                │
                           Docker Compose
```

- **Frontend**: SwiftUI, Combine, Core Location, XCTest  
- **Backend**: FastAPI, Pydantic, SQLAlchemy, Alembic, Uvicorn  
- **Database**: PostgreSQL  
- **Cache**: Redis  
- **Containerization**: Docker & Docker Compose  

---

## Getting Started

### Prerequisites

- macOS with **Xcode 13+**  
- **Docker** & **Docker Compose**  
- (Optional) **Python 3.10+** for manual backend runs  


## Directory Structure

```
TriLive/
├── backend/               # FastAPI server 
│   ├
│   ├── app/               # routes, models, services
│   ├── Dockerfile
│   └── requirements.txt
├── ios-app/               # SwiftUI Xcode project
│   └── TriLive.xcodeproj
├
├── docker-compose.yml
└── TriLive Mockups.pdf    # design wireframes
```

---

## Design Assets

See **TriLive Mockups.pdf** in the repo root for UI/UX wireframes and flow diagrams.

---

## Contact

Brian Maina – https://github.com/brianmmaina – bmmaina@bu.edu 
Anthony Qin – [https://github.com/anthonyq7 – a.j.qin@wustl.edu 
```
