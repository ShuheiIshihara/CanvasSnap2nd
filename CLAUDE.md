# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**CanvasSnap2nd** is a .NET application (successor to CanvasSnap). The repository is in early setup stage — update this file as the tech stack and architecture are defined.

## Git Workflow

- Default branch: `main`
- Active development branch: `develop`
- Commit messages must be in Japanese (see global CLAUDE.md rules)

## Build & Test Commands

_To be filled in once the project structure is established._

Typical .NET commands (update with actual project paths when `.csproj`/`.sln` files are added):

```bash
dotnet build          # Build the solution
dotnet run            # Run the application
dotnet test           # Run all tests
dotnet test --filter "FullyQualifiedName~TestName"  # Run a single test
dotnet lint           # Lint (if configured via analyzers)
```

## Architecture

_To be documented as the codebase takes shape._

Key decisions to record here when made:
- Target framework (ASP.NET Core, Blazor, WPF, MAUI, etc.)
- Project structure (`/src`, `/tests`, solution layout)
- Database technology and ORM (EF Core, Dapper, etc.)
- Key NuGet dependencies

## tech-term-explainer
  tech_term_output: docs/terms/
