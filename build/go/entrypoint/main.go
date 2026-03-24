package main

import (
	"os"
	"encoding/base64"

	"github.com/11notes/go-eleven"
)

const APP_BIN = "museum"
const APP_ROOT = "/opt/ente"
const APP_CONFIG_ENV string = "ENTE_CONFIG"
const APP_CONFIG string = "/ente/etc/default.yml"

func main() {
	// write env to file if set
	eleven.Container.EnvToFile(APP_CONFIG_ENV, APP_CONFIG)
	eleven.Container.FileContentReplaceEnv(APP_CONFIG)

	// replace default variables
	replaced, err := eleven.Util.FileReplaceStrings(APP_CONFIG, secrets())
	if err != nil {
		eleven.LogFatal("could not set a new default password: %s", err)
	}
	if replaced {
		eleven.Log("INF", "replaced default secrets with custom new secrets!")
	}

	// start app
	os.Chdir(APP_ROOT)
	eleven.Container.Run(APP_ROOT, APP_BIN, []string{})
}

func secrets() map[string]any{
	keyBytes, err := eleven.Util.GenerateRandomBytes(32)
	if err != nil {
		eleven.LogFatal("could not generate random bytes: %s", err)
	}
	hashBytes, err := eleven.Util.GenerateRandomBytes(64)
	if err != nil {
		eleven.LogFatal("could not generate random bytes: %s", err)
	}
	jwtBytes, err := eleven.Util.GenerateRandomBytes(32)
	if err != nil {
		eleven.LogFatal("could not generate random bytes: %s", err)
	}
	return(map[string]any{
		"yvmG/RnzKrbCb9L3mgsmoxXr9H7i2Z4qlbT0mL3ln4w=":base64.StdEncoding.EncodeToString(keyBytes),
		"KXYiG07wC7GIgvCSdg+WmyWdXDAn6XKYJtp/wkEU7x573+byBRAYtpTP0wwvi8i/4l37uicX1dVTUzwH3sLZyw==":base64.StdEncoding.EncodeToString(hashBytes),
		"i2DecQmfGreG6q1vBj5tCokhlN41gcfS2cjOs9Po-u8=":base64.URLEncoding.EncodeToString(jwtBytes),
	})
}