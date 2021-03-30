package main

import (
	"context"
	"encoding/json"
	"net/http"
)

func getConfig(w http.ResponseWriter, r *http.Request) {
	var announcementText string
	var announcementLink string
	var isUnderMaintenance bool
	var maintenanceText string
	var updateVersion int
	var updateText string

	err := pool.QueryRow(context.Background(), "select announcement_text, announcement_link, under_maintenance_at is not null, maintenance_text, update_version, update_text from config limit 1;").Scan(&announcementText, &announcementLink, &isUnderMaintenance, &maintenanceText, &updateVersion, &updateText)
	handleError(err)

	mapper := map[string]interface{}{
		"announcementText":   announcementText,
		"announcementLink":   announcementLink,
		"isUnderMaintenance": isUnderMaintenance,
		"maintenanceText":    maintenanceText,
		"updateVersion":      updateVersion,
		"updateText":         updateText,
	}
	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
