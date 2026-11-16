# StitchTrack

An operations app for tailoring shops in Nepal. It digitises the order lifecycle, from taking measurements at the counter through cutting, stitching, trial and fitting to delivery, across one or more branches.

Customers don't install anything: shop staff use the app, and customers will get updates by SMS or WhatsApp.

## Roles
- **Admin** — runs the business: branches, staff, customers and reports
- **Counter** — registers customers, takes orders with measurements and hands over finished garments
- **Production worker** — works through a job queue of garments to cut, stitch and prepare for trial

## What's built
- Login with role and branch selection
- Role-based home screens for counter staff, production workers and admins
- Customer registration with a local customer database
- Step-by-step new order wizard: customer → garments → measurements → review
- Local database (Drift) with seed data; also runs on web via WebAssembly
- Camera, barcode, secure storage and connectivity services, ready for the scanning workflow
- English and Nepali (Devanagari) throughout, with a shared design system and widget library

## Coming next
- Barcode scanning to move garments through production stages
- Payments with VAT
- Staff, branch and settings management
- Notifications and the owner's analytics dashboard
- Connection to the Laravel backend API

## Tech Stack
- **Framework** — Flutter (Android, iOS, Web)
- **State management** — Riverpod
- **Local database** — Drift (SQLite)
- **Navigation** — go_router
- **Localization** — easy_localization (English, Nepali)
- **Barcodes** — mobile_scanner, barcode_widget
- **Structure** — feature-first folders (data / domain / presentation) behind repository interfaces

## How it's built
The app is built UI-first against a local Drift database while the backend is developed separately. Every feature talks to a repository interface, so moving from local data to the real API means swapping the repository, not rewriting the screens.

## Getting Started
Requires Flutter 3.38+.

    flutter pub get
    dart run build_runner build --delete-conflicting-outputs
    flutter run

## Status
In active development. The foundation, local database, login, customer registration, the new-order wizard and the role home screens are in place; the production workflow, payments and backend connection are next.

## What I learned
Designing one app around three very different jobs (counter, workshop and owner) taught me to model the order lifecycle first and let each role's screens follow from it. Building against local repositories before the backend existed showed me how much a clean repository boundary pays off.
