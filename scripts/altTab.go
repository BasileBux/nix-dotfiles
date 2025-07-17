package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"strconv"
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
	Fullscreen       bool     `json:"fullscreen"`
	FullscreenClient int      `json:"fullscreenClient"`
	Grouped          []string `json:"grouped"`
	Tags             []string `json:"tags"`
	Swallowing       string   `json:"swallowing"`
	FocusHistoryID   int      `json:"focusHistoryID"`
}

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

	argInt := 1
	if len(os.Args) == 2 {
		argInt, _ = strconv.Atoi(os.Args[1])
	}
	nextWindow := windows[0]
	for _, window := range windows {
		if window.FocusHistoryID == argInt {
			nextWindow = window
			break
		}
	}
	windowIdentifier := fmt.Sprintf("pid:%d", nextWindow.Pid)
	exec.Command("hyprctl", "dispatch", "focuswindow", windowIdentifier).Run()
}
