#!/bin/bash

# Machine setup script for koad's personal environment
# Run directly: bash command.sh
# Run from internet: curl -sSL https://raw.githubusercontent.com/koad/setup-new-machine/refs/heads/main/command.sh | bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

setup_new_machine() {
    # Exit on error
    set -e

    echo -e "${BOLD}${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║        KOAD'S NEW MACHINE SETUP        ║${NC}"
    echo -e "${BOLD}${BLUE}╚════════════════════════════════════════╝${NC}"
    echo

    # Check prerequisites
    echo -e "${CYAN}➤ Checking prerequisites...${NC}"
    
    if ! command -v git &> /dev/null; then
        echo -e "${RED}✘ Git is required but not installed. Please install git first.${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ Git is installed${NC}"
    fi
    
    # Create a log file
    LOG_FILE="/tmp/koad-setup-$(date +%Y%m%d-%H%M%S).log"
    echo -e "${YELLOW}➤ Logging to ${LOG_FILE}${NC}"
    
    # Install koad:io with full submodules
    echo -e "\n${CYAN}➤ Setting up koad:io...${NC}"
    if [ -d ~/.koad-io ]; then
        echo -e "${YELLOW}! koad:io directory already exists${NC}"
        echo -e "${CYAN}➤ Updating existing koad:io installation...${NC}"
        (cd ~/.koad-io && git pull --recurse-submodules) >> $LOG_FILE 2>&1 || {
            echo -e "${RED}✘ Failed to update koad:io${NC}"
            exit 1
        }
    else
        echo -e "${CYAN}➤ Cloning koad:io repository with submodules...${NC}"
        git clone --recurse-submodules https://github.com/koad/io.git ~/.koad-io >> $LOG_FILE 2>&1 || {
            echo -e "${RED}✘ Failed to clone koad:io${NC}"
            exit 1
        }
    fi
    echo -e "${GREEN}✓ koad:io setup complete${NC}"
    
    # Add to PATH if not already there
    echo -e "\n${CYAN}➤ Configuring PATH...${NC}"
    if ! grep -q "koad-io/bin" ~/.bashrc; then
        echo -e "${CYAN}➤ Adding koad-io/bin to PATH in ~/.bashrc${NC}"
        echo -e "\n\n[ -d ~/.koad-io/bin ] && export PATH=\$PATH:\$HOME/.koad-io/bin\n" >> ~/.bashrc
    else
        echo -e "${YELLOW}! PATH already configured in ~/.bashrc${NC}"
    fi
    
    # Export for current session
    export PATH=$PATH:$HOME/.koad-io/bin
    echo -e "${GREEN}✓ PATH configured${NC}"
    
    # Check if koad-io is available
    if ! command -v koad-io &> /dev/null; then
        echo -e "${RED}✘ koad-io command not found in PATH even after setup${NC}"
        echo -e "${YELLOW}! Please check your installation and try again${NC}"
        exit 1
    fi
    
    # Spawn alice with full submodules
    echo -e "\n${CYAN}➤ Setting up Alice...${NC}"
    if [ -d ~/.alice ]; then
        echo -e "${YELLOW}! alice directory already exists${NC}"
        echo -e "${CYAN}➤ Updating existing alice installation...${NC}"
        (cd ~/.alice && git pull --recurse-submodules) >> $LOG_FILE 2>&1 || {
            echo -e "${RED}✘ Failed to update alice${NC}"
            exit 1
        }
    else
        echo -e "${CYAN}➤ Cloning alice repository with submodules...${NC}"
        git clone --recurse-submodules https://github.com/koad/alice.git ~/.alice >> $LOG_FILE 2>&1 || {
            echo -e "${RED}✘ Failed to clone alice${NC}"
            exit 1
        }
    fi
    
    echo -e "${CYAN}➤ Initializing alice...${NC}"
    koad-io init alice >> $LOG_FILE 2>&1 || {
        echo -e "${RED}✘ Failed to initialize alice${NC}"
        exit 1
    }
    echo -e "${GREEN}✓ alice setup complete${NC}"
    
    # Generate alice keyring
    # echo -e "\n${CYAN}➤ Generating alice keyring...${NC}"
    # alice generate keyring >> $LOG_FILE 2>&1 || {
    #     echo -e "${RED}✘ Failed to generate alice keyring${NC}"
    #     exit 1
    # }
    # echo -e "${GREEN}✓ alice keyring generated${NC}"
    
    # Install foundational tools
    echo -e "\n${CYAN}➤ Installing essential packages...${NC}"
    alice install essentials >> $LOG_FILE 2>&1 || {
        echo -e "${RED}✘ Failed to install essentials${NC}"
        exit 1
    }
    echo -e "${GREEN}✓ Essential packages installed${NC}"
    
    echo -e "\n${CYAN}➤ Installing starship prompt...${NC}"
    alice install starship >> $LOG_FILE 2>&1 || {
        echo -e "${RED}✘ Failed to install starship${NC}"
        exit 1
    }
    echo -e "${GREEN}✓ Starship prompt installed${NC}"
    
    # Final message
    echo -e "\n${GREEN}${BOLD}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║       SETUP COMPLETED SUCCESSFULLY      ║${NC}"
    echo -e "${GREEN}${BOLD}╚════════════════════════════════════════╝${NC}"
    echo -e "\n${CYAN}➤ Please restart your shell or run:${NC}"
    echo -e "${BOLD}   source ~/.bashrc${NC}"
    echo
    echo -e "${YELLOW}➤ Setup log: ${LOG_FILE}${NC}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_new_machine "$@"
fi
