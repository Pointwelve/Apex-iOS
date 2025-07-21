#!/bin/bash

# Version Bump Script for Apex iOS
# Usage: ./scripts/version-bump.sh [patch|minor|major|set] [version]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INFO_PLIST="$PROJECT_DIR/Apex/Apex/Info.plist"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Function to validate version format
validate_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version format: $version"
        print_info "Expected format: X.Y.Z (e.g., 1.0.0)"
        exit 1
    fi
}

# Function to get current version from Info.plist
get_current_version() {
    if [ ! -f "$INFO_PLIST" ]; then
        print_error "Info.plist not found at: $INFO_PLIST"
        exit 1
    fi
    
    local version=$(plutil -p "$INFO_PLIST" | grep CFBundleShortVersionString | awk '{print $3}' | tr -d '"')
    if [ -z "$version" ]; then
        print_error "Could not read version from Info.plist"
        exit 1
    fi
    echo "$version"
}

# Function to update version in Info.plist
update_version() {
    local new_version=$1
    local build_number=$2
    
    print_info "Updating Info.plist..."
    plutil -replace CFBundleShortVersionString -string "$new_version" "$INFO_PLIST"
    
    if [ -n "$build_number" ]; then
        plutil -replace CFBundleVersion -string "$build_number" "$INFO_PLIST"
        print_success "Updated version to $new_version (build $build_number)"
    else
        print_success "Updated version to $new_version"
    fi
}

# Function to bump version
bump_version() {
    local current_version=$1
    local bump_type=$2
    
    # Parse version components
    IFS='.' read -r major minor patch <<< "$current_version"
    
    case $bump_type in
        major)
            new_version="$((major + 1)).0.0"
            ;;
        minor)
            new_version="$major.$((minor + 1)).0"
            ;;
        patch)
            new_version="$major.$minor.$((patch + 1))"
            ;;
        *)
            print_error "Invalid bump type: $bump_type"
            print_info "Valid options: major, minor, patch"
            exit 1
            ;;
    esac
    
    echo "$new_version"
}

# Function to generate build number
generate_build_number() {
    # Use timestamp-based build number
    date +"%Y%m%d%H%M"
}

# Function to create git tag
create_git_tag() {
    local version=$1
    local build_number=$2
    local tag="v$version"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_warning "Not in a git repository. Skipping tag creation."
        return
    fi
    
    # Check if tag already exists
    if git tag -l "$tag" | grep -q "$tag"; then
        print_warning "Tag $tag already exists. Skipping tag creation."
        return
    fi
    
    # Check if there are uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        print_warning "There are uncommitted changes. Commit them first:"
        git status --porcelain
        return
    fi
    
    # Create annotated tag
    print_info "Creating git tag: $tag"
    git tag -a "$tag" -m "Release $version" -m "Build: $build_number"
    
    print_success "Created tag: $tag"
    print_info "Push with: git push origin $tag"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  patch                 Increment patch version (1.0.0 → 1.0.1)"
    echo "  minor                 Increment minor version (1.0.0 → 1.1.0)"
    echo "  major                 Increment major version (1.0.0 → 2.0.0)"
    echo "  set <version>         Set specific version (e.g., 1.2.3)"
    echo "  current               Show current version"
    echo ""
    echo "Options:"
    echo "  --build <number>      Set specific build number"
    echo "  --auto-build          Auto-generate build number (timestamp)"
    echo "  --tag                 Create git tag after version update"
    echo "  --dry-run             Show what would be changed without making changes"
    echo ""
    echo "Examples:"
    echo "  $0 patch --auto-build --tag"
    echo "  $0 minor --build 123"
    echo "  $0 set 2.0.0 --auto-build"
    echo "  $0 current"
}

# Main logic
main() {
    local command=""
    local target_version=""
    local build_number=""
    local auto_build=false
    local create_tag=false
    local dry_run=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            patch|minor|major|current)
                command=$1
                ;;
            set)
                command=$1
                if [ -n "$2" ] && [[ ! $2 =~ ^-- ]]; then
                    target_version=$2
                    shift
                else
                    print_error "Version required for 'set' command"
                    show_usage
                    exit 1
                fi
                ;;
            --build)
                if [ -n "$2" ] && [[ ! $2 =~ ^-- ]]; then
                    build_number=$2
                    shift
                else
                    print_error "Build number required for --build option"
                    exit 1
                fi
                ;;
            --auto-build)
                auto_build=true
                ;;
            --tag)
                create_tag=true
                ;;
            --dry-run)
                dry_run=true
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown argument: $1"
                show_usage
                exit 1
                ;;
        esac
        shift
    done
    
    # Show current version if requested
    if [ "$command" = "current" ]; then
        current_version=$(get_current_version)
        echo "Current version: $current_version"
        exit 0
    fi
    
    # Validate command
    if [ -z "$command" ]; then
        print_error "No command specified"
        show_usage
        exit 1
    fi
    
    # Get current version
    current_version=$(get_current_version)
    print_info "Current version: $current_version"
    
    # Calculate new version
    case $command in
        patch|minor|major)
            new_version=$(bump_version "$current_version" "$command")
            ;;
        set)
            validate_version "$target_version"
            new_version=$target_version
            ;;
    esac
    
    # Generate build number if requested
    if [ "$auto_build" = true ]; then
        build_number=$(generate_build_number)
    fi
    
    # Show what would be done in dry-run mode
    if [ "$dry_run" = true ]; then
        print_info "DRY RUN - Changes that would be made:"
        echo "  Version: $current_version → $new_version"
        if [ -n "$build_number" ]; then
            echo "  Build: → $build_number"
        fi
        if [ "$create_tag" = true ]; then
            echo "  Git tag: v$new_version (would be created)"
        fi
        exit 0
    fi
    
    # Confirm the change
    print_warning "About to update version:"
    echo "  Current: $current_version"
    echo "  New: $new_version"
    if [ -n "$build_number" ]; then
        echo "  Build: $build_number"
    fi
    
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Aborted"
        exit 0
    fi
    
    # Update version
    update_version "$new_version" "$build_number"
    
    # Create git tag if requested
    if [ "$create_tag" = true ]; then
        create_git_tag "$new_version" "$build_number"
    fi
    
    print_success "Version update completed!"
    
    # Show next steps
    echo ""
    print_info "Next steps:"
    echo "  1. Review changes: git diff"
    echo "  2. Commit changes: git commit -am 'Bump version to $new_version'"
    if [ "$create_tag" = true ]; then
        echo "  3. Push changes: git push origin main && git push origin v$new_version"
    else
        echo "  3. Push changes: git push origin main"
        echo "  4. Create tag: git tag -a v$new_version -m 'Release $new_version'"
    fi
    echo "  5. Trigger release: GitHub Actions will build and deploy"
}

# Run main function with all arguments
main "$@"