# Claude Code Review Setup

This repository includes automated code review using Claude Code AI. This document explains how to set up and use the Claude Code review workflow.

## Prerequisites

To enable Claude Code reviews, you need to configure the `ANTHROPIC_API_KEY` secret in your GitHub repository.

### Setting up the API Key

1. **Get an Anthropic API Key:**
   - Go to [Anthropic Console](https://console.anthropic.com/)
   - Sign up or sign in to your account
   - Navigate to API Keys section
   - Create a new API key

2. **Add the Secret to GitHub:**
   - Go to your repository on GitHub
   - Click on **Settings** → **Secrets and variables** → **Actions**
   - Click **New repository secret**
   - Name: `ANTHROPIC_API_KEY`
   - Value: Your Anthropic API key
   - Click **Add secret**

## How it Works

The Claude Code review workflow (`.github/workflows/claude-review.yml`) automatically:

1. **Triggers** on pull requests to `main` or `develop` branches
2. **Analyzes** changed Swift files, headers, and configuration files
3. **Reviews** code for:
   - Swift coding conventions and best practices
   - iOS/SwiftUI patterns and performance
   - Security vulnerabilities and crash risks
   - Architecture and maintainability issues
   - Testing and error handling

4. **Posts** a comprehensive review comment on the PR

## Review Focus Areas

The AI reviewer focuses on:

### Code Quality & Best Practices
- Swift idioms and conventions
- iOS development patterns
- Memory management
- Performance considerations

### Architecture & Design
- SOLID principles
- Separation of concerns
- SwiftUI best practices
- Code reusability

### Security & Safety
- Potential vulnerabilities
- Force unwrapping risks
- Input validation
- Data handling

### Testing & Maintainability
- Code testability
- Error handling
- Documentation
- Refactoring opportunities

## Review Output

Each review includes:

- **Overall assessment** summary
- **Specific issues** with line references
- **Positive aspects** worth highlighting
- **Actionable recommendations**
- **Priority levels** (Critical/High/Medium/Low)

## Workflow Permissions

The workflow requires these permissions:
- `contents: read` - To access repository files
- `pull-requests: write` - To comment on PRs
- `issues: write` - To update review comments

## Customization

You can customize the review by modifying:

- **File patterns** in the `changed-files` step
- **Review prompt** in the `review_prompt.md` section
- **Comment behavior** in the GitHub script section

## Troubleshooting

### Common Issues

1. **Missing API Key:**
   - Error: "Claude review failed"
   - Solution: Ensure `ANTHROPIC_API_KEY` is properly set in repository secrets

2. **Permission Errors:**
   - Error: Cannot comment on PR
   - Solution: Check workflow permissions in repository settings

3. **No Reviews Generated:**
   - Check if changed files match the configured patterns
   - Review workflow logs for specific errors

### Disabling Reviews

To temporarily disable Claude reviews:
- Add `[skip claude]` to your PR title or description
- Or disable the workflow in repository settings

## Cost Considerations

- Claude Code reviews consume API credits from your Anthropic account
- Reviews only run on non-draft PRs with relevant file changes
- Consider setting usage limits in your Anthropic console

## Support

For issues related to:
- **Claude Code**: Check [Claude Code documentation](https://docs.anthropic.com/claude/docs)
- **GitHub Actions**: Review workflow logs and GitHub Actions documentation
- **This workflow**: Create an issue in this repository