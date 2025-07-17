package main

import (
	"encoding/json"
	"fmt"
	"os/exec"
	"strings"
)

type Window struct {
	Address   string `json:"address"`
	Mapped    bool   `json:"mapped"`
	Hidden    bool   `json:"hidden"`
	At        [2]int `json:"at"`
	Size      [2]int `json:"size"`
	Workspace struct {
		Id   int    `json:"id"`
		Name string `json:"name"`
	} `json:"workspace"`
	Floating         bool     `json:"floating"`
	Pseudo           bool     `json:"pseudo"`
	Monitor          int      `json:"monitor"`
	Class            string   `json:"class"`
	Title            string   `json:"title"`
	InitialClass     string   `json:"initialClass"`
	InitialTitle     string   `json:"initialTitle"`
	Pid              int      `json:"pid"`
	Xwayland         bool     `json:"xwayland"`
	Pinned           bool     `json:"pinned"`
	Fullscreen       int     `json:"fullscreen"`
	FullscreenClient int      `json:"fullscreenClient"`
	Grouped          []string `json:"grouped"`
	Tags             []string `json:"tags"`
	Swallowing       string   `json:"swallowing"`
	FocusHistoryID   int      `json:"focusHistoryID"`
}

const WORKSPACE_NUMBER int = 10

func getWindows() ([]Window, error) {
	// Execute the hyprctl command to get the clients JSON
	cmd := exec.Command("hyprctl", "clients", "-j")
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to execute hyprctl command: %v", err)
	}

	// Unmarshal the JSON into a slice of Window structs
	var windows []Window
	err = json.Unmarshal(output, &windows)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal JSON: %v", err)
	}

	return windows, nil
}

func main() {
	windows, err := getWindows()
	if err != nil {
		panic(err)
	}

	var workspaces [WORKSPACE_NUMBER + 1][]string
	focusedWorkspace := -1

	for _, w := range windows {
		workspaces[w.Workspace.Id] = append(workspaces[w.Workspace.Id], w.Class)
		if focusedWorkspace == -1 && w.FocusHistoryID == 0 {
			focusedWorkspace = w.Workspace.Id
		}
	}

	var output string
	for i, w := range workspaces {
		if len(w) > 0 {
			highlight := "\033[1m"
			if i == focusedWorkspace {
				highlight = "\033[36;1m"
			}
			output += fmt.Sprintf("%sWorkspace %d:\033[0m\n", highlight, i)
			for j, c := range w {
				output += c
				if j < len(w)-1 {
					output += " | "
				}
			}
			output += "\n\n"
		}
	}
	output = strings.TrimSpace(output)
	output += "\n"
	fmt.Print(output)
}
