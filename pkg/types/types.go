package types

import "github.com/google/uuid"

type Type int64

const (
	Uuid Type = iota
	String
)

type UuidOrString struct {
	Type        Type
	UuidValue   uuid.UUID
	StringValue string
}

func (uos UuidOrString) String() string {
	if uos.Type == Uuid {
		return uos.UuidValue.String()
	} else {
		return uos.StringValue
	}
}

func FromUuid(input uuid.UUID) *UuidOrString {
	return &UuidOrString{
		Type:        Uuid,
		UuidValue:   input,
		StringValue: input.String(),
	}
}

func FromString(input string) (*UuidOrString, error) {
	uid, err := uuid.Parse(input)
	if err != nil {
		return nil, err
	}
	return &UuidOrString{
		Type:        String,
		StringValue: uid.String(),
		UuidValue:   uid,
	}, nil
}
