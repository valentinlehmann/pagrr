# Pagrr

<p align="center">
  <img src="docs/app-icon.png" width="160" height="160" alt="Pagrr app icon" />
</p>

<p align="center">
  Get push notifications from your services, without the hassle.
</p>

---

## What is Pagrr?

Pagrr is an iOS app that turns your services into clean, actionable push notifications.
Create a channel, grab its API key, and send messages from anywhere. Pagrr delivers them
to your phone with titles, descriptions, and an optional urgent badge.

## Why it exists

When logs, jobs, and deployments need to reach you, email is too slow and dashboards are too noisy.
Pagrr keeps the signal high: one channel per system, one message per event, right on your lock screen.

## Core features

- Channel-based notifications with shared ownership.
- Simple API key per channel, plus a ready-to-copy cURL snippet.
- Urgent flag for messages that should stand out.
- Sign in with Apple and device-level push delivery.
- Lightweight list UI for browsing recent alerts.

## How it works (quick flow)

1. Sign in and create a channel.
2. Copy the the provided cURL command.
3. Send a message payload from your service.
4. Pagrr receives it and pushes it to your device.

## Built with

- SwiftUI
- Firebase Auth
- Firestore
- Firebase Cloud Messaging

---

If you are building a service that needs a human to notice it, Pagrr is the shortcut.


