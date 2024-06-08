package main

import (
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	_ "github.com/lib/pq"
)

type Contact struct {
	ID           int    `json:"id"`
	FirstName    string `json:"first_name"`
	LastName     string `json:"last_name"`
	PhoneNumber  string `json:"phone_number"`
	Email        string `json:"email"`
	Address      string `json:"address"`
	ProfilePhoto string `json:"profile_photo"`
}

var db *sql.DB

// createContact handles the creation of a new contact
func createContact(w http.ResponseWriter, r *http.Request) {
	log.Println("Received request to create contact")
	var contact Contact
	if err := json.NewDecoder(r.Body).Decode(&contact); err != nil {
		log.Printf("Error decoding request body: %v", err)
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	log.Printf("Decoded contact: %+v", contact)

	photoData, err := base64.StdEncoding.DecodeString(contact.ProfilePhoto)
	if err != nil {
		log.Printf("Error decoding profile photo: %v", err)
		http.Error(w, "Invalid profile photo", http.StatusBadRequest)
		return
	}

	query := `INSERT INTO contacts (first_name, last_name, phone_number, email, address, profile_photo) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`
	err = db.QueryRow(query, contact.FirstName, contact.LastName, contact.PhoneNumber, contact.Email, contact.Address, photoData).Scan(&contact.ID)
	if err != nil {
		log.Printf("Error inserting contact into database: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(contact)
}

// getContacts handles retrieving all contacts
func getContacts(w http.ResponseWriter, r *http.Request) {
	log.Println("Received request to get contacts")
	rows, err := db.Query("SELECT id, first_name, last_name, phone_number, email, address, profile_photo FROM contacts")
	if err != nil {
		log.Printf("Error querying contacts: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var contacts []Contact
	for rows.Next() {
		var contact Contact
		var photoData []byte
		if err := rows.Scan(&contact.ID, &contact.FirstName, &contact.LastName, &contact.PhoneNumber, &contact.Email, &contact.Address, &photoData); err != nil {
			log.Printf("Error scanning contact: %v", err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		contact.ProfilePhoto = base64.StdEncoding.EncodeToString(photoData)
		contacts = append(contacts, contact)
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(contacts); err != nil {
		log.Printf("Error encoding response: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// deleteContact handles deleting a contact by ID
func deleteContact(w http.ResponseWriter, r *http.Request) {
	log.Println("Received request to delete contact")

	idStr := r.URL.Query().Get("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		log.Printf("Invalid contact ID: %v", err)
		http.Error(w, "Invalid contact ID", http.StatusBadRequest)
		return
	}

	query := "DELETE FROM contacts WHERE id = $1"
	result, err := db.Exec(query, id)
	if err != nil {
		log.Printf("Error deleting contact from database: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		log.Printf("Error getting rows affected: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	if rowsAffected == 0 {
		log.Println("Contact not found")
		http.Error(w, "Contact not found", http.StatusNotFound)
		return
	}

	w.WriteHeader(http.StatusOK)
	log.Println("Contact deleted successfully")
}

func updateContact(w http.ResponseWriter, r *http.Request) {
	log.Println("Received request to update contact")

	var contact Contact
	if err := json.NewDecoder(r.Body).Decode(&contact); err != nil {
		log.Printf("Error decoding request body: %v", err)
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	log.Printf("Decoded contact: %+v", contact)

	photoData, err := base64.StdEncoding.DecodeString(contact.ProfilePhoto)
	if err != nil {
		log.Printf("Error decoding profile photo: %v", err)
		http.Error(w, "Invalid profile photo", http.StatusBadRequest)
		return
	}

	query := `UPDATE contacts SET first_name=$1, last_name=$2, phone_number=$3, email=$4, address=$5, profile_photo=$6 WHERE id=$7`
	_, err = db.Exec(query, contact.FirstName, contact.LastName, contact.PhoneNumber, contact.Email, contact.Address, photoData, contact.ID)
	if err != nil {
		log.Printf("Error updating contact in database: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{}`)) // Return an empty JSON object
	log.Println("Contact updated successfully")
}

func searchContacts(w http.ResponseWriter, r *http.Request) {
	log.Println("Received request to search contacts")

	name := r.URL.Query().Get("name")
	phone := r.URL.Query().Get("phone")

	query := `SELECT id, first_name, last_name, phone_number, email, address, profile_photo FROM contacts WHERE 1=1`
	var params []interface{}
	i := 1

	if name != "" {
		query += ` AND (first_name ILIKE $` + strconv.Itoa(i) + ` OR last_name ILIKE $` + strconv.Itoa(i) + `)`
		params = append(params, "%"+name+"%")
		i++
	}

	if phone != "" {
		query += ` AND phone_number ILIKE $` + strconv.Itoa(i)
		params = append(params, "%"+phone+"%")
		i++
	}

	rows, err := db.Query(query, params...)
	if err != nil {
		log.Printf("Error querying contacts: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var contacts []Contact
	for rows.Next() {
		var contact Contact
		var photoData []byte
		if err := rows.Scan(&contact.ID, &contact.FirstName, &contact.LastName, &contact.PhoneNumber, &contact.Email, &contact.Address, &photoData); err != nil {
			log.Printf("Error scanning contact: %v", err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		contact.ProfilePhoto = base64.StdEncoding.EncodeToString(photoData)
		contacts = append(contacts, contact)
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(contacts); err != nil {
		log.Printf("Error encoding response: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func main() {
	var err error
	connStr := "user=postgres dbname=contactsdb sslmode=disable password=radar.64 host=localhost port=5432"
	db, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatalf("Error connecting to the database: %v", err)
	}

	err = db.Ping()
	if err != nil {
		log.Fatalf("Error pinging the database: %v", err)
	}

	log.Println("Connected to the database successfully")

	http.HandleFunc("/contacts", createContact)        // Endpoint for creating a new contact
	http.HandleFunc("/getcontacts", getContacts)       // Endpoint for retrieving all contacts
	http.HandleFunc("/deletecontact", deleteContact)   // Endpoint for deleting a contact
	http.HandleFunc("/updatecontact", updateContact)   // Endpoint for updating a contact
	http.HandleFunc("/searchcontacts", searchContacts) // Endpoint for searching contacts
	log.Println("Starting server on :8000")
	if err := http.ListenAndServe(":8000", nil); err != nil {
		log.Fatalf("Error starting server: %v", err)
	}
}
