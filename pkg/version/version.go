// Package version provides version information for the mieru proxy tool.
package version

import (
	"fmt"
	"runtime"
)

const (
	// Major is the major version number.
	Major = 3

	// Minor is the minor version number.
	Minor = 9

	// Patch is the patch version number.
	Patch = 0

	// PreRelease is the pre-release version string.
	// Leave empty for stable releases.
	PreRelease = ""

	// ForkOwner identifies the maintainer of this personal fork.
	ForkOwner = "personal-fork"
)

// AppVersion is the full semantic version string of the application.
var AppVersion = func() string {
	v := fmt.Sprintf("%d.%d.%d", Major, Minor, Patch)
	if PreRelease != "" {
		v = v + "-" + PreRelease
	}
	return v
}()

// BuildInfo holds runtime build metadata.
type BuildInfo struct {
	Version   string
	GoVersion string
	OS        string
	Arch      string
}

// GetBuildInfo returns the current build information.
func GetBuildInfo() BuildInfo {
	return BuildInfo{
		Version:   AppVersion,
		GoVersion: runtime.Version(),
		OS:        runtime.GOOS,
		Arch:      runtime.GOARCH,
	}
}

// String returns a human-readable representation of the build info.
// Example output: "mieru version 3.9.0 (Go go1.22.0, linux/amd64) [fork: personal-fork]"
func (b BuildInfo) String() string {
	return fmt.Sprintf(
		"mieru version %s (Go %s, %s/%s) [fork: %s]",
		b.Version,
		b.GoVersion,
		b.OS,
		b.Arch,
		ForkOwner,
	)
}
