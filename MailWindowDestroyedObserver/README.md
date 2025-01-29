# Installation

## Prerequisites

### carthage

We use _carthage_ to manage external Swift/Objective-C dependencies (frameworks)

```bash
brew install carthage
```

Alternatively, get it from [GitHub](https://github.com/Carthage/Carthage#installing-carthage)

## Preparations

Move into project directory

```bash
cd MailWindowDestroyedObserver/MailWindowDestroyedObserver
```

Fetch Objective-C/Swift framework dependencies

```bash
carthage bootstrap --use-xcframeworks --platform macOS --cache-builds --configuration Debug
```
