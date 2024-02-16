package installer

import (
	"archive/zip"
	"github.com/hashicorp/go-version"
	"io"
	"net/http"
	"os"
	"path/filepath"
)

type Installer struct {
}

// Install a given version of OpenTofu
func Install(v *version.Version, binDir string) (string, error) {
	// TODO: Build this dynamically given the environment we run on
	downloadUrl := "https://github.com/opentofu/opentofu/releases/download/v1.6.1/tofu_1.6.1_linux_amd64.zip"
	pkgFile, err := os.CreateTemp(os.TempDir(), "tofu")
	if err != nil {
		return "", err
	}
	defer pkgFile.Close()

	client := http.Client{}
	req, err := http.NewRequest("GET", downloadUrl, nil)
	if err != nil {
		return "", err
	}

	res, err := client.Do(req)
	if err != nil {
		return "", err
	}

	_, err = io.Copy(pkgFile, res.Body)
	if err != nil {
		return "", err
	}
	r, err := zip.OpenReader(pkgFile.Name())
	if err != nil {
		return "", err
	}
	defer r.Close()
	for _, f := range r.File {
		if f.Name != "tofu" {
			continue
		}

		srcFile, err := f.Open()
		if err != nil {
			return "", err
		}

		absPath, err := filepath.Abs(binDir)
		if err != nil {
			return "", err
		}
		dstPath := filepath.Join(absPath, f.Name)
		dstFile, err := os.Create(dstPath)
		if err != nil {
			return "", err
		}
		_, err = io.Copy(dstFile, srcFile)
		if err != nil {
			return "", err
		}
		srcFile.Close()
		dstFile.Close()

		// Make file executable
		err = os.Chmod(dstPath, 0o700)
		if err != nil {
			return "", err
		}

		return dstPath, nil
	}
	return "", nil
}
