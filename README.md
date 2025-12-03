[![License](https://img.shields.io/github/license/anthonyq7/trilive)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/anthonyq7/trilive)](https://github.com/anthonyq7/trilive/commits/main)
[![Stars](https://img.shields.io/github/stars/anthonyq7/trilive?style=social)](https://github.com/anthonyq7/trilive/stargazers)
[![Issues](https://img.shields.io/github/issues/anthonyq7/trilive)](https://github.com/anthonyq7/trilive/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/anthonyq7/trilive)](https://github.com/anthonyq7/trilive/pulls)
[![Top Language](https://img.shields.io/github/languages/top/anthonyq7/trilive)](https://github.com/anthonyq7/trilive)
[![Repo Size](https://img.shields.io/github/repo-size/anthonyq7/trilive)](https://github.com/anthonyq7/trilive)
[![Code Size](https://img.shields.io/github/languages/code-size/anthonyq7/trilive)](https://github.com/anthonyq7/trilive)

[![SwiftUI](https://img.shields.io/badge/Frontend-SwiftUI-FA7343?logo=swift)](https://developer.apple.com/xcode/swiftui/)
[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi)](https://fastapi.tiangolo.com/)
[![Python](https://img.shields.io/badge/Language-Python-3776AB?logo=python)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-336791?logo=postgresql)](https://www.postgresql.org/)
[![Redis](https://img.shields.io/badge/Cache-Redis-DC382D?logo=redis)](https://redis.io/)

<p align="center">
  <img src="ios-app/TriLive/Assets.xcassets/TriLiveLogo.imageset/TriLiveLogo.png" width="250" alt="TriLive Logo">
</p>

# TriLive

TriLive is a real-time iOS transit tracker that shows live bus & train ETAs and search by location. Built as a summer project by Anthony “Ant” Qin and Brian Maina "B.M.M", we plan to deploy it as an App Store release. Powered by SwiftUI + Core Location and a Docker-containerized FastAPI + PostgreSQL + Redis backend.

TriLive is currently undergoing closed beta testing through TestFlight. To get involved, please contact us or join our beta directly:

**Try it on the App Store!**: [Download](https://apps.apple.com/us/app/trilive-real-time-transit-app/id6749755575)

---

## Table of Contents

1. [Overview](#overview)  
2. [Features](#features)  
3. [Architecture & Tech Stack](#architecture--tech-stack)  
4. [Production](#production)  
   - [Prerequisites](#prerequisites)
   - [Backend & Frontend Intergration](#Backend--Frontend-Intergration)
5. [Potential Updates](#potential-updates)
6. [Changelog](#changelog)
7. [Feedback & Issues](#feedback--issues) 
8. [Design Assets](#design-assets)  
9. [Contact](#contact)  

---

## Overview

TriLive delivers live transit ETAs for buses and trains at nearby stops in a sleek SwiftUI interface. We paired a FastAPI backend with PostgreSQL for persistence and Redis for low-latency caching, all orchestrated via Docker Compose. 

---

## Features

- **Stop Search**: Enter a stop name (e.g. “NE 28th & Powell”) or stop ID (e.g. 12345) and get instant matches. Fuzzy matching handles “&” vs. “and” and minor typos. 
- **Live Arrivals**: Display the upcoming vehicles in the next ~60 minutes for your chosen stop, updated every 10 seconds. ETAs show both scheduled and real‑time adjusted times.  
- **Map Tracking**: Tap an arrival to follow that bus on the map. A polylined path shows where it’s been; a moving icon tracks its current position.
- **Push Notifications**: Opt in to receive alerts when your bus is within 5 minutes or at departure. Perfect for when you’re cooking breakfast or grabbing coffee.

---

## Architecture & Tech Stack
- **Frontend**: SwiftUI, Combine, Core Location
- **Backend**: FastAPI, Pydantic, SQLAlchemy, Uvicorn  
- **Database**: PostgreSQL  
- **Cache**: Redis  
- **Containers**: Docker 
---

## Production

### Prerequisites

- macOS with **Xcode 13+**  
- **Docker** & **Docker Compose**  
- (Optional) **Python 3.10+** for manual backend runs

### Backend & Frontend Intergration

Our Dockerized FastAPI backend (Pydantic, SQLAlchemy) runs on Render with managed PostgreSQL and Redis, automatically building and deploying on each push to main. The SwiftUI front end calls the secure REST API for live ETAs, favorites syncing, and location-aware search.

## Potential Updates
- User accounts & cross-device sync
- Custom themes
- WatchOS companion app

---
## Changelog
v0.1.0

---
## Feedback & Issues
Found a bug or have an idea? Please open an issue:
https://github.com/anthonyq7/TriLive/issues

---
## Design Assets
See TriLive Mockups.pdf in the repo root for UI/UX wireframes.

---
## Contact

Brian Maina – github.com/brianmmaina – bmmaina@bu.edu

Anthony Qin – github.com/anthonyq7 – a.j.qin@wustl.edu

---

