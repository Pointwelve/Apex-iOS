#!/bin/bash

# Test Impact Analysis Script for Apex iOS
# Determines which tests to run based on changed files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

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

# Configuration
UNIT_TEST_TARGET="ApexTests"
UI_TEST_TARGET="ApexUITests"
PROJECT_PATH="Apex/Apex.xcodeproj"
SCHEME="Apex"

# Test mapping configuration file
TEST_MAPPING_FILE="$PROJECT_DIR/.github/test-mapping.yml"

# Function to create default test mapping if it doesn't exist
create_default_test_mapping() {
    if [ ! -f "$TEST_MAPPING_FILE" ]; then
        print_info "Creating default test mapping configuration..."
        mkdir -p "$(dirname "$TEST_MAPPING_FILE")"
        
        cat > "$TEST_MAPPING_FILE" << 'EOF'
# Test Impact Analysis Mapping
# Maps file patterns to test targets that should be executed

# File patterns and their corresponding test targets
patterns:
  # Core app files - run both unit and UI tests
  - pattern: "Apex/Apex/**/*.swift"
    tests:
      - ApexTests
      - ApexUITests
    reason: "Core app logic changes"
  
  # UI specific files - run UI tests
  - pattern: "Apex/Apex/**/ContentView.swift"
    tests:
      - ApexUITests
    reason: "UI component changes"
  
  - pattern: "Apex/Apex/**/Views/**/*.swift"
    tests:
      - ApexUITests
    reason: "View layer changes"
  
  # Model/Business logic - run unit tests primarily
  - pattern: "Apex/Apex/**/Models/**/*.swift"
    tests:
      - ApexTests
    reason: "Business logic changes"
  
  - pattern: "Apex/Apex/**/Services/**/*.swift"
    tests:
      - ApexTests
      - ApexUITests
    reason: "Service layer changes"
  
  # Configuration files - run all tests
  - pattern: "Apex/Apex/**/*.plist"
    tests:
      - ApexTests
      - ApexUITests
    reason: "Configuration changes"
  
  - pattern: "Apex/Apex/**/*.entitlements"
    tests:
      - ApexTests
      - ApexUITests
    reason: "Entitlements changes"
  
  # Test files themselves
  - pattern: "Apex/ApexTests/**/*.swift"
    tests:
      - ApexTests
    reason: "Unit test changes"
  
  - pattern: "Apex/ApexUITests/**/*.swift"
    tests:
      - ApexUITests
    reason: "UI test changes"
  
  # Build configuration - run all tests
  - pattern: "Apex/Apex.xcodeproj/**"
    tests:
      - ApexTests
      - ApexUITests
    reason: "Build configuration changes"
  
  # CI/CD changes - run all tests
  - pattern: ".github/workflows/**"
    tests:
      - ApexTests
      - ApexUITests
    reason: "CI/CD pipeline changes"
  
  - pattern: ".swiftlint.yml"
    tests:
      - ApexTests
      - ApexUITests
    reason: "Code quality rules changes"

# Special cases
special_cases:
  # Always run all tests for these patterns
  always_run_all:
    - "fastlane/**"
    - "scripts/**"
    - "Package.swift"
    - "Package.resolved"
  
  # Never trigger tests for these patterns
  skip_tests:
    - "README.md"
    - "docs/**/*.md"
    - ".gitignore"
    - "CLAUDE.md"
    - "LICENSE"
    - "*.png"
    - "*.jpg"
    - "*.jpeg"
    - "*.gif"

# Thresholds
thresholds:
  # Maximum number of changed files before running all tests
  max_changed_files: 20
  
  # If more than this percentage of files changed, run all tests
  max_change_percentage: 30
EOF
        print_success "Created default test mapping at $TEST_MAPPING_FILE"
    fi
}

# Function to get changed files
get_changed_files() {
    local base_ref="${1:-HEAD~1}"
    local head_ref="${2:-HEAD}"
    
    if [ -n "$GITHUB_EVENT_NAME" ]; then
        case "$GITHUB_EVENT_NAME" in
            "pull_request")
                # For PR, compare against target branch
                base_ref="origin/$GITHUB_BASE_REF"
                head_ref="HEAD"
                ;;
            "push")
                # For push, use the before commit
                if [ -n "$GITHUB_EVENT_BEFORE" ] && [ "$GITHUB_EVENT_BEFORE" != "0000000000000000000000000000000000000000" ]; then
                    base_ref="$GITHUB_EVENT_BEFORE"
                else
                    base_ref="HEAD~1"
                fi
                head_ref="HEAD"
                ;;
        esac
    fi
    
    print_info "Analyzing changes between $base_ref and $head_ref"
    
    # Get changed files, handling the case where base_ref might not exist
    if git rev-parse --verify "$base_ref" >/dev/null 2>&1; then
        git diff --name-only "$base_ref" "$head_ref" 2>/dev/null || {
            print_warning "Could not get diff, falling back to recent changes"
            git diff --name-only HEAD~1 HEAD 2>/dev/null || echo ""
        }
    else
        print_warning "Base ref $base_ref not found, using recent changes"
        git diff --name-only HEAD~1 HEAD 2>/dev/null || {
            print_info "No previous commit found, assuming all files changed"
            find Apex -name "*.swift" -type f | head -10
        }
    fi
}

# Function to parse YAML (simple parser for our use case)
parse_test_mapping() {
    local file="$1"
    if [ ! -f "$file" ]; then
        print_error "Test mapping file not found: $file"
        return 1
    fi
    
    # Determine which Python to use
    local python_cmd="python3"
    if [ -f "$PROJECT_DIR/venv/bin/python" ]; then
        python_cmd="$PROJECT_DIR/venv/bin/python"
        print_info "Using virtual environment Python"
    elif command -v python3 >/dev/null 2>&1; then
        python_cmd="python3"
    elif command -v python >/dev/null 2>&1; then
        python_cmd="python"
    else
        print_error "No Python interpreter found"
        echo "RUN_ALL_TESTS"
        return 0
    fi
    
    # Check if PyYAML is available
    if ! $python_cmd -c "import yaml" >/dev/null 2>&1; then
        print_warning "PyYAML not available, falling back to run all tests"
        echo "RUN_ALL_TESTS"
        return 0
    fi
    
    # Extract patterns and their tests (simplified YAML parsing)
    # This is a basic implementation - for production, consider using yq or similar
    $python_cmd -c "
import yaml
import sys
import fnmatch

try:
    with open('$file', 'r') as f:
        config = yaml.safe_load(f)
    
    changed_files = sys.argv[1].split('\n') if sys.argv[1] else []
    changed_files = [f for f in changed_files if f.strip()]
    
    if not changed_files:
        print('NO_CHANGES')
        sys.exit(0)
    
    # Check special cases first
    special = config.get('special_cases', {})
    thresholds = config.get('thresholds', {})
    
    # Check if we should skip tests
    skip_patterns = special.get('skip_tests', [])
    all_skip = True
    for file in changed_files:
        file_should_skip = False
        for pattern in skip_patterns:
            if fnmatch.fnmatch(file, pattern):
                file_should_skip = True
                break
        if not file_should_skip:
            all_skip = False
            break
    
    if all_skip:
        print('SKIP_TESTS')
        sys.exit(0)
    
    # Check if we should run all tests
    always_run_all = special.get('always_run_all', [])
    for file in changed_files:
        for pattern in always_run_all:
            if fnmatch.fnmatch(file, pattern):
                print('RUN_ALL_TESTS')
                sys.exit(0)
    
    # Check thresholds
    max_files = thresholds.get('max_changed_files', 20)
    if len(changed_files) > max_files:
        print('RUN_ALL_TESTS')
        sys.exit(0)
    
    # Determine which tests to run based on patterns
    tests_to_run = set()
    matched_patterns = []
    
    patterns = config.get('patterns', [])
    for file in changed_files:
        file_matched = False
        for pattern_config in patterns:
            pattern = pattern_config['pattern']
            tests = pattern_config['tests']
            reason = pattern_config.get('reason', 'File pattern match')
            
            if fnmatch.fnmatch(file, pattern):
                tests_to_run.update(tests)
                matched_patterns.append(f'{file} -> {pattern} ({reason})')
                file_matched = True
        
        # If file doesn't match any pattern, run all tests
        if not file_matched:
            print('RUN_ALL_TESTS')
            sys.exit(0)
    
    if tests_to_run:
        print('TESTS=' + ','.join(sorted(tests_to_run)))
        print('\n# Test Impact Analysis Results:')
        for match in matched_patterns:
            print(f'# {match}')
    else:
        print('RUN_ALL_TESTS')

except ImportError:
    print('RUN_ALL_TESTS')  # Fallback if PyYAML not available
except Exception as e:
    print(f'RUN_ALL_TESTS')  # Fallback on any error
" "$*"
}

# Function to determine which tests to run
determine_tests_to_run() {
    local changed_files="$1"
    
    if [ -z "$changed_files" ]; then
        echo "NO_CHANGES"
        return 0
    fi
    
    print_info "Analyzing impact of changed files..."
    
    # Count changed files
    local file_count
    file_count=$(echo "$changed_files" | wc -l)
    print_info "Changed files count: $file_count"
    
    # Show changed files
    echo "Changed files:"
    echo "$changed_files" | sed 's/^/  /'
    echo
    
    # Parse test mapping and determine tests
    local result
    result=$(parse_test_mapping "$TEST_MAPPING_FILE" "$changed_files")
    
    echo "$result"
}

# Function to generate xcodebuild test command
generate_test_command() {
    local tests_to_run="$1"
    local destination="${2:-platform=iOS Simulator,name=iPhone 16 Pro,OS=18.0}"
    
    local base_command="xcodebuild test -project $PROJECT_PATH -scheme $SCHEME -destination '$destination'"
    
    case "$tests_to_run" in
        "NO_CHANGES")
            print_info "No changes detected, skipping tests"
            echo "# No tests to run"
            return 0
            ;;
        "SKIP_TESTS")
            print_info "Only documentation/non-code files changed, skipping tests"
            echo "# No tests to run - documentation changes only"
            return 0
            ;;
        "RUN_ALL_TESTS")
            print_warning "Running all tests due to significant changes or safety fallback"
            echo "$base_command"
            return 0
            ;;
        TESTS=*)
            local test_targets
            test_targets=$(echo "$tests_to_run" | sed 's/TESTS=//')
            print_success "Running targeted tests: $test_targets"
            
            # Generate individual test commands
            IFS=',' read -ra TARGETS <<< "$test_targets"
            for target in "${TARGETS[@]}"; do
                echo "$base_command -only-testing:$target"
            done
            return 0
            ;;
        *)
            print_warning "Unknown test determination result, running all tests as safety fallback"
            echo "$base_command"
            return 0
            ;;
    esac
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  analyze [base_ref] [head_ref]  Analyze changed files and determine tests to run"
    echo "  command [base_ref] [head_ref]  Generate xcodebuild test commands"
    echo "  init                           Create default test mapping configuration"
    echo "  validate                       Validate test mapping configuration"
    echo ""
    echo "Options:"
    echo "  --destination DEST            Override test destination"
    echo "  --verbose                     Show detailed analysis"
    echo ""
    echo "Examples:"
    echo "  $0 analyze                    # Analyze changes since last commit"
    echo "  $0 analyze HEAD~3 HEAD        # Analyze changes in last 3 commits"
    echo "  $0 command                    # Generate test commands for recent changes"
    echo "  $0 init                       # Create default configuration"
}

# Main function
main() {
    local command=""
    local base_ref="HEAD~1"
    local head_ref="HEAD"
    local destination="platform=iOS Simulator,name=iPhone 16 Pro,OS=18.0"
    local verbose=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            analyze|command|init|validate)
                command=$1
                ;;
            --destination)
                if [ -n "$2" ]; then
                    destination=$2
                    shift
                else
                    print_error "Destination required for --destination option"
                    exit 1
                fi
                ;;
            --verbose)
                verbose=true
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            -*)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                if [ -z "$command" ]; then
                    command="analyze"
                fi
                if [ "$command" = "analyze" ] || [ "$command" = "command" ]; then
                    if [ -z "$base_ref" ] || [ "$base_ref" = "HEAD~1" ]; then
                        base_ref=$1
                    elif [ -z "$head_ref" ] || [ "$head_ref" = "HEAD" ]; then
                        head_ref=$1
                    fi
                fi
                ;;
        esac
        shift
    done
    
    # Default to analyze if no command specified
    if [ -z "$command" ]; then
        command="analyze"
    fi
    
    case $command in
        init)
            create_default_test_mapping
            print_success "Test mapping configuration initialized"
            ;;
        validate)
            if [ -f "$TEST_MAPPING_FILE" ]; then
                # Determine which Python to use
                local python_cmd="python3"
                if [ -f "$PROJECT_DIR/venv/bin/python" ]; then
                    python_cmd="$PROJECT_DIR/venv/bin/python"
                    print_info "Using virtual environment Python for validation"
                elif command -v python3 >/dev/null 2>&1; then
                    python_cmd="python3"
                elif command -v python >/dev/null 2>&1; then
                    python_cmd="python"
                else
                    print_error "No Python interpreter found for validation"
                    exit 1
                fi
                
                # Check if PyYAML is available
                if ! $python_cmd -c "import yaml" >/dev/null 2>&1; then
                    print_error "PyYAML not available. Install with: pip install PyYAML"
                    exit 1
                fi
                
                $python_cmd -c "
import yaml
try:
    with open('$TEST_MAPPING_FILE', 'r') as f:
        yaml.safe_load(f)
    print('✅ Test mapping configuration is valid')
except Exception as e:
    print(f'❌ Invalid YAML: {e}')
    exit(1)
" && print_success "Test mapping configuration is valid" || exit 1
            else
                print_error "Test mapping configuration not found"
                exit 1
            fi
            ;;
        analyze)
            create_default_test_mapping
            
            cd "$PROJECT_DIR"
            changed_files=$(get_changed_files "$base_ref" "$head_ref")
            
            if [ "$verbose" = true ]; then
                print_info "Base ref: $base_ref"
                print_info "Head ref: $head_ref"
                print_info "Changed files:"
                echo "$changed_files" | sed 's/^/  /'
                echo
            fi
            
            result=$(determine_tests_to_run "$changed_files")
            echo "$result"
            ;;
        command)
            create_default_test_mapping
            
            cd "$PROJECT_DIR"
            changed_files=$(get_changed_files "$base_ref" "$head_ref")
            result=$(determine_tests_to_run "$changed_files")
            
            # Filter out comment lines for command generation
            filtered_result=$(echo "$result" | grep -v '^#' | head -1)
            generate_test_command "$filtered_result" "$destination"
            ;;
        *)
            print_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"