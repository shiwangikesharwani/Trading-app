
# 021 Trading App

A Flutter trading application built as part of the 021 Trading App assignment.

## Features

### 1. Watchlist

- Create multiple watchlists
- Rename watchlists
- Delete watchlists
- Add stocks from the available stock list
- Remove stocks
- Drag and reorder stocks
- Watchlists persist across app restarts
- Live prices update in watchlists
- Tapping a stock opens the Buy/Sell ticket with the stock pre-filled

### 2. Live Market Prices

- Live mock market-data feed
- 10 supported stocks
- Real-time LTP updates
- Price change and percentage change
- Up/down price indication
- Configurable mock tick rate
- Designed to handle high-frequency updates
- Single market-data source used throughout the application

### 3. Buy/Sell

- Market Buy and Sell orders
- Live LTP on order screen
- Quantity validation
- Balance validation
- Holding quantity validation
- Order value calculated using current LTP
- Wallet balance persistence
- Order history persistence
- Buy orders create/update holdings
- Sell orders reduce/remove holdings

### 4. Holdings

- Current holdings
- Quantity
- Average cost
- Current LTP
- Current value
- P&L in ₹
- P&L percentage
- Sort by P&L, symbol, and current value
- Live P&L updates
- Holdings persist across app restarts
- Buy/Sell ticket can be opened directly from a holding

## Supported Stocks

The application uses these 10 stocks:

- RELIANCE
- TCS
- INFY
- HDFCBANK
- ICICIBANK
- SBIN
- ITC
- LT
- BHARTIARTL
- AXISBANK

## Tech Stack

- Flutter
- Dart
- Riverpod
- Hive
- Equatable

## Architecture

The project follows a layered architecture with separation between:

- Presentation
- Domain
- Data
- Local Storage
- State Management

## Persistence

Hive is used for local persistence of:

- Watchlists
- Wallet balance
- Order history
- Holdings

## Getting Started

### Requirements

- Flutter stable channel
- Dart
- Android Studio or Xcode

### Installation

Clone the repository:

```bash
git clone https://github.com/shiwangikesharwani/Trading-app.git
cd Trading-app
