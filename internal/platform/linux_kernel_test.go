//go:build linux

package platform

import "testing"

func TestParseKernelVersion(t *testing.T) {
	tests := []struct {
		name        string
		release     string
		wantMajor   int
		wantMinor   int
		expectError bool
	}{
		{
			name:      "CentOS 7 default kernel",
			release:   "3.10.0-1160.el7.x86_64",
			wantMajor: 3,
			wantMinor: 10,
		},
		{
			name:      "CentOS 7 older kernel",
			release:   "3.10.0-693.21.1.el7.x86_64",
			wantMajor: 3,
			wantMinor: 10,
		},
		{
			name:      "CentOS 6 kernel",
			release:   "2.6.32-754.el6.x86_64",
			wantMajor: 2,
			wantMinor: 6,
		},
		{
			name:      "Linux 4.1 first with bytes_acked",
			release:   "4.1.0-custom",
			wantMajor: 4,
			wantMinor: 1,
		},
		{
			name:      "RHEL 8 kernel",
			release:   "4.18.0-305.el8.x86_64",
			wantMajor: 4,
			wantMinor: 18,
		},
		{
			name:      "Ubuntu 22.04 kernel",
			release:   "5.15.0-76-generic",
			wantMajor: 5,
			wantMinor: 15,
		},
		{
			name:      "Debian 12 kernel",
			release:   "6.1.0-18-amd64",
			wantMajor: 6,
			wantMinor: 1,
		},
		{
			name:        "Invalid empty release",
			release:     "",
			expectError: true,
		},
		{
			name:        "Invalid no dot",
			release:     "nonumbers",
			expectError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			major, minor, err := parseKernelVersion(tt.release)
			if tt.expectError {
				if err == nil {
					t.Errorf("parseKernelVersion(%q) expected error, got nil", tt.release)
				}
				return
			}
			if err != nil {
				t.Fatalf("parseKernelVersion(%q) unexpected error: %v", tt.release, err)
			}
			if major != tt.wantMajor || minor != tt.wantMinor {
				t.Errorf("parseKernelVersion(%q) = (%d, %d), want (%d, %d)",
					tt.release, major, minor, tt.wantMajor, tt.wantMinor)
			}
		})
	}
}
