// Code generated by gorm.io/gen. DO NOT EDIT.
// Code generated by gorm.io/gen. DO NOT EDIT.
// Code generated by gorm.io/gen. DO NOT EDIT.

package model

const TableNameTAllAuthxRule = "t_all_authx_rules"

// TAllAuthxRule mapped from table <t_all_authx_rules>
type TAllAuthxRule struct {
	ID    int64  `gorm:"column:id;type:bigint;primaryKey;autoIncrement:true" json:"id"`
	Ptype string `gorm:"column:ptype;type:character varying(100)" json:"ptype"`
	V0    string `gorm:"column:v0;type:character varying(100)" json:"v0"`
	V1    string `gorm:"column:v1;type:character varying(100)" json:"v1"`
	V2    string `gorm:"column:v2;type:character varying(100)" json:"v2"`
	V3    string `gorm:"column:v3;type:character varying(100)" json:"v3"`
	V4    string `gorm:"column:v4;type:character varying(100)" json:"v4"`
	V5    string `gorm:"column:v5;type:character varying(100)" json:"v5"`
}

// TableName TAllAuthxRule's table name
func (*TAllAuthxRule) TableName() string {
	return TableNameTAllAuthxRule
}
