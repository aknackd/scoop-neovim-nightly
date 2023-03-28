package main

import (
	"bufio"
	"flag"
	"log"
	"net/http"
	"os"
	"strings"
	"text/template"
	"time"

	_ "embed"
)

var Version = "nightly"
var CommitHash = ""

//go:embed manifest.template.json
var templateManifestJson []byte

var outputPath string

type templateVariables struct {
	Version        string
	CommitHash     string
	SHA256Checksum string
}

func main() {
	flag.StringVar(&outputPath, "output", "", "")
	flag.Parse()

	if outputPath == "" {
		outputPath = "neovim-nightly.json"
	}

	if err := buildManifest(); err != nil {
		log.Fatal(err)
	}

	os.Exit(0)
}

func buildManifest() error {
	log.Println("Building manifest")

	var err error

	checksum, err := fetchNightlyReleaseChecksum()
	if err != nil {
		return err
	}

	variables := templateVariables{
		Version:        Version,
		CommitHash:     CommitHash,
		SHA256Checksum: checksum,
	}

	tmpl, err := template.New("").Parse(string(templateManifestJson))
	if err != nil {
		return err
	}

	outputFile, err := os.Create(outputPath)
	if err != nil {
		return err
	}

	defer outputFile.Close()

	if err := tmpl.Execute(outputFile, variables); err != nil {
		return err
	}

	log.Printf("Manifest written: %s\n", outputPath)

	return nil
}

func fetchNightlyReleaseChecksum() (string, error) {
	log.Println("Fetching release checksum")

	checksumUrl := "https://github.com/neovim/neovim/releases/download/nightly/nvim-win64.zip.sha256sum"

	client := &http.Client{
		Timeout: 5 * time.Second,
	}

	request, err := http.NewRequest("GET", checksumUrl, nil)
	if err != nil {
		return "", err
	}

	response, err := client.Do(request)
	if err != nil {
		return "", err
	}

	defer response.Body.Close()

	scanner := bufio.NewScanner(response.Body)
	scanner.Scan()

	parts := strings.Split(scanner.Text(), "  ")
	checksum := parts[0]

	if err := scanner.Err(); err != nil {
		return "", err
	}

	return checksum, nil
}
