package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
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

func main() {
	if len(os.Args) != 2 {
		return
	}
	output, _ := exec.Command("hyprctl", "activewindow", "-j").Output()

	var window Window
	err := json.Unmarshal(output, &window)
	if err != nil {
		return
	}

	// Execute new app in current workspace
	exec.Command(os.Args[1], ".").Run()

	// Move previous app to next workspace
	movePid := fmt.Sprintf("pid:%d", window.Pid)
	exec.Command("hyprctl", "dispatch", "movetoworkspace", fmt.Sprintf("%d,%s", window.Workspace.Id+1, movePid)).Run()

	// Focus on the workspace
	exec.Command("hyprctl", "dispatch", "workspace", fmt.Sprintf("%d", window.Workspace.Id)).Run()
}
