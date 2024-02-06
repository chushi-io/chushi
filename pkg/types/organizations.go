package types

import "errors"

type OrganizationStatus string

const (
	OrganizationStatusActive   OrganizationStatus = "active"
	OrganizationStatusInactive                    = "inactive"
)

func ToOrganizationStatus(input string) (OrganizationStatus, error) {
	switch input {
	case "active":
		return OrganizationStatusActive, nil
	case "inactive":
		return OrganizationStatusInactive, nil
	default:
		return "", errors.New("invalid organization status provided")
	}
}

func (os OrganizationStatus) String() (string, error) {
	switch os {
	case OrganizationStatusActive:
		return "active", nil
	case OrganizationStatusInactive:
		return "inactive", nil
	default:
		return "", errors.New("invalid organization status provided")
	}
}
