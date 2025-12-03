# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- English documentation

---

## [0.3.0] - 2025-11-25

### Added
- Rocky Linux 9 cloud-init template script (`create-rocky9-template.sh`)

---

## [0.2.0] - 2025-11-18

### Added
- Advanced multi-VM provisioning with `for_each` (`opentofu/multiple_vm/`)
- Static IP address support for VMs
- Individual VM configuration (CPU, RAM, tags per VM)
- VM grouping by node in outputs
- SSH commands output for easy access

### Changed
- Updated main README with multiple_vm documentation
- Minor improvements and cleanup in single_vm configuration

---

## [0.1.0] - 2025-11-17

### Added
- Initial project structure
- OpenTofu configuration for single VM provisioning (`opentofu/single_vm/`)
- Ubuntu 22.04 cloud-init template script
- DHCP-based networking for VMs
- Automatic VM distribution across cluster nodes
- API token authentication for Proxmox
- Comprehensive documentation in Russian
- Git commit message template (`.gitmessage`)

### Fixed
- Timestamp error in cloud-init configuration

---

[Unreleased]: https://github.com/rtxnik/homelab/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/rtxnik/homelab/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/rtxnik/homelab/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/rtxnik/homelab/releases/tag/v0.1.0
